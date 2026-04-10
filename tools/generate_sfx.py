#!/usr/bin/env python3
"""Procedurally generate 6 sci-fi sound effects as .ogg files."""

import math
import os
import struct
import subprocess
import wave

import numpy as np

SAMPLE_RATE = 44100
OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "sfx")
TEMP_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "sfx", "_tmp_wav")


def write_wav(filename: str, samples: np.ndarray) -> str:
    """Write mono float samples (-1..1) to a 16-bit WAV file. Returns path."""
    path = os.path.join(TEMP_DIR, filename)
    # Clip and convert to int16
    clipped = np.clip(samples, -1.0, 1.0)
    int_samples = (clipped * 32767).astype(np.int16)
    with wave.open(path, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        wf.writeframes(int_samples.tobytes())
    return path


def convert_to_ogg(wav_path: str, ogg_name: str) -> str:
    """Convert wav to ogg using ffmpeg."""
    ogg_path = os.path.join(OUTPUT_DIR, ogg_name)
    subprocess.run(
        ["ffmpeg", "-y", "-i", wav_path, "-ar", str(SAMPLE_RATE), "-ac", "1",
         "-c:a", "libvorbis", "-q:a", "4", ogg_path],
        check=True, capture_output=True,
    )
    return ogg_path


def smooth_envelope(length: int, attack: float = 0.02, release: float = 0.08) -> np.ndarray:
    """Cosine-smoothed attack/release envelope — no clicks or jarring edges."""
    env = np.ones(length, dtype=np.float64)
    att_samples = max(int(attack * SAMPLE_RATE), 1)
    rel_samples = max(int(release * SAMPLE_RATE), 1)
    # Cosine ease-in (0 -> 1)
    env[:att_samples] = 0.5 * (1.0 - np.cos(np.linspace(0, np.pi, att_samples)))
    # Cosine ease-out (1 -> 0)
    env[-rel_samples:] = 0.5 * (1.0 + np.cos(np.linspace(0, np.pi, rel_samples)))
    return env


def gen_laser() -> np.ndarray:
    """Short high-frequency sweep downward — pew pew laser."""
    duration = 0.25
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    # Frequency sweeps from 2500 Hz down to 300 Hz
    freq = np.linspace(2500, 300, n)
    phase = np.cumsum(freq / SAMPLE_RATE) * 2 * np.pi
    sig = np.sin(phase) * 0.7
    sig += np.sin(phase * 2) * 0.2
    sig += np.sin(phase * 3) * 0.1
    # Exponential decay with smooth envelope
    env = np.exp(-t * 12) * smooth_envelope(n, attack=0.008, release=0.04)
    return sig * env * 0.6


def gen_missile() -> np.ndarray:
    """Whoosh launch — low rumble with filtered noise, no tonal sweep."""
    duration = 0.8
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(42)
    noise = rng.normal(0, 1, n)

    # Low rumble — heavily filtered noise
    rumble = np.zeros(n)
    alpha = 0.005
    rumble[0] = noise[0] * alpha
    for i in range(1, n):
        rumble[i] = rumble[i - 1] * (1 - alpha) + noise[i] * alpha
    rumble = rumble / (np.max(np.abs(rumble)) + 1e-9) * 0.5

    # Whoosh — band-passed noise, no rising tone
    whoosh_freq = np.linspace(200, 1200, n)
    whoosh_phase = np.cumsum(whoosh_freq / SAMPLE_RATE) * 2 * np.pi
    whoosh = np.sin(whoosh_phase) * noise * 0.35

    sig = rumble + whoosh
    # Crescendo shape that peaks at ~60% then decays
    vol_shape = np.sin(np.linspace(0, np.pi, n)) ** 0.5
    env = smooth_envelope(n, attack=0.06, release=0.15) * vol_shape
    return sig * env * 0.55


def gen_probe() -> np.ndarray:
    """Ethereal woosh — soft sweep with airy texture."""
    duration = 0.7
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(55)

    # Soft frequency sweep 300 -> 600 -> 300 Hz (arc shape)
    freq = 300 + 300 * np.sin(np.linspace(0, np.pi, n))
    phase = np.cumsum(freq / SAMPLE_RATE) * 2 * np.pi
    tone = np.sin(phase) * 0.25

    # Airy filtered noise layer
    noise = rng.normal(0, 1, n)
    airy = np.zeros(n)
    alpha = 0.02
    airy[0] = noise[0] * alpha
    for i in range(1, n):
        airy[i] = airy[i - 1] * (1 - alpha) + noise[i] * alpha
    airy = airy / (np.max(np.abs(airy)) + 1e-9) * 0.3

    # Gentle shimmer — high frequency, very quiet
    shimmer = np.sin(2 * np.pi * 2400 * t) * 0.05 * np.sin(np.linspace(0, np.pi, n))

    sig = tone + airy + shimmer
    env = smooth_envelope(n, attack=0.1, release=0.2) * np.sin(np.linspace(0, np.pi, n)) ** 0.6
    return sig * env * 0.5


def gen_explosion() -> np.ndarray:
    """Noise burst with decay — space explosion, smoothed edges."""
    duration = 0.9
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(99)
    noise = rng.normal(0, 1, n)
    # Low-pass filter the noise progressively more over time for "boom" feel
    filtered = np.zeros(n)
    for i in range(1, n):
        a = 0.15 * math.exp(-t[i] * 3)
        filtered[i] = filtered[i - 1] * (1 - a) + noise[i] * a
    filtered = filtered / (np.max(np.abs(filtered)) + 1e-9)
    # Low thump
    thump = np.sin(2 * np.pi * 50 * t) * np.exp(-t * 6) * 0.6
    sig = filtered * 0.6 + thump
    # Smooth attack to avoid jarring start
    env = np.exp(-t * 3.5) * smooth_envelope(n, attack=0.02, release=0.15)
    return sig * env * 0.55


def gen_hit() -> np.ndarray:
    """Impact thud — lower frequency, more of a punchy hit than metallic ring."""
    duration = 0.35
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(77)

    # Low-mid impact tone
    sig = np.sin(2 * np.pi * 120 * t) * 0.5 * np.exp(-t * 10)
    # Mid crunch layer
    sig += np.sin(2 * np.pi * 250 * t) * 0.3 * np.exp(-t * 15)
    # Noise burst for texture
    noise = rng.normal(0, 1, n) * np.exp(-t * 30) * 0.35
    # Filter the noise a bit
    filtered_noise = np.zeros(n)
    alpha = 0.08
    for i in range(1, n):
        filtered_noise[i] = filtered_noise[i - 1] * (1 - alpha) + noise[i] * alpha
    filtered_noise = filtered_noise / (np.max(np.abs(filtered_noise)) + 1e-9) * 0.3
    sig += filtered_noise

    env = smooth_envelope(n, attack=0.005, release=0.06)
    return sig * env * 0.6


def gen_click() -> np.ndarray:
    """Low, soft keyboard/mouse click."""
    duration = 0.06
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    # Low-frequency click — like a key bottoming out
    sig = np.sin(2 * np.pi * 300 * t) * 0.5
    # Subtle second harmonic
    sig += np.sin(2 * np.pi * 600 * t) * 0.15
    # Very fast decay
    env = np.exp(-t * 80) * smooth_envelope(n, attack=0.001, release=0.015)
    return sig * env * 0.5


def main():
    os.makedirs(TEMP_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    sounds = {
        "laser": gen_laser,
        "missile": gen_missile,
        "probe": gen_probe,
        "explosion": gen_explosion,
        "hit": gen_hit,
        "click": gen_click,
    }

    for name, gen_fn in sounds.items():
        print(f"Generating {name}...")
        samples = gen_fn()
        wav_path = write_wav(f"{name}.wav", samples)
        ogg_path = convert_to_ogg(wav_path, f"{name}.ogg")
        print(f"  -> {ogg_path}")

    # Cleanup temp wav files
    import shutil
    shutil.rmtree(TEMP_DIR, ignore_errors=True)
    print("\nDone! All 6 .ogg files generated.")


if __name__ == "__main__":
    main()
