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


def envelope(length: int, attack: float = 0.01, decay: float = 0.0, release: float = 0.05) -> np.ndarray:
    """Generate an ADSR-ish envelope (no sustain param — sustain = 1.0 between attack and release)."""
    env = np.ones(length, dtype=np.float64)
    att_samples = int(attack * SAMPLE_RATE)
    rel_samples = int(release * SAMPLE_RATE)
    if att_samples > 0:
        env[:att_samples] = np.linspace(0, 1, att_samples)
    if rel_samples > 0:
        env[-rel_samples:] = np.linspace(1, 0, rel_samples)
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
    # Add a bit of harmonics
    sig += np.sin(phase * 2) * 0.2
    sig += np.sin(phase * 3) * 0.1
    # Sharp attack, quick decay
    env = np.exp(-t * 12) * envelope(n, attack=0.005, release=0.02)
    return sig * env


def gen_missile() -> np.ndarray:
    """Rising whoosh with low rumble."""
    duration = 1.0
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    # Low rumble — filtered noise
    rng = np.random.default_rng(42)
    noise = rng.normal(0, 1, n)
    # Simple low-pass via cumulative averaging
    rumble = np.zeros(n)
    alpha = 0.005
    rumble[0] = noise[0] * alpha
    for i in range(1, n):
        rumble[i] = rumble[i - 1] * (1 - alpha) + noise[i] * alpha
    rumble = rumble / (np.max(np.abs(rumble)) + 1e-9) * 0.5
    # Rising tone sweep 80 Hz -> 600 Hz
    freq = np.linspace(80, 600, n)
    phase = np.cumsum(freq / SAMPLE_RATE) * 2 * np.pi
    tone = np.sin(phase) * 0.4
    # Whoosh — band-passed noise rising in pitch (simple approach: modulated noise)
    whoosh_freq = np.linspace(200, 2000, n)
    whoosh_phase = np.cumsum(whoosh_freq / SAMPLE_RATE) * 2 * np.pi
    whoosh = np.sin(whoosh_phase) * noise * 0.3
    sig = (rumble + tone + whoosh)
    env = envelope(n, attack=0.1, release=0.15)
    # Crescendo
    env *= np.linspace(0.3, 1.0, n)
    return sig * env


def gen_probe() -> np.ndarray:
    """Electronic ping/sonar pulse."""
    duration = 0.6
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    # Main ping at 1200 Hz
    sig = np.sin(2 * np.pi * 1200 * t) * 0.5
    # Second harmonic ping slightly detuned
    sig += np.sin(2 * np.pi * 1807 * t) * 0.3
    # Third — very high shimmer
    sig += np.sin(2 * np.pi * 3600 * t) * 0.1
    # Sharp attack, long exponential decay
    env = np.exp(-t * 6) * envelope(n, attack=0.003, release=0.05)
    # Add a second smaller ping echo
    echo_start = int(0.2 * SAMPLE_RATE)
    echo_env = np.zeros(n)
    remaining = n - echo_start
    echo_env[echo_start:] = np.exp(-np.linspace(0, duration * 6, remaining)) * 0.4
    return sig * (env + echo_env)


def gen_explosion() -> np.ndarray:
    """Noise burst with decay — space explosion."""
    duration = 0.8
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    rng = np.random.default_rng(99)
    noise = rng.normal(0, 1, n)
    # Low-pass filter the noise progressively more over time for "boom" feel
    filtered = np.zeros(n)
    for i in range(1, n):
        # Alpha decreases over time — more filtering as sound decays
        a = 0.15 * math.exp(-t[i] * 3)
        filtered[i] = filtered[i - 1] * (1 - a) + noise[i] * a
    filtered = filtered / (np.max(np.abs(filtered)) + 1e-9)
    # Add a low thump
    thump = np.sin(2 * np.pi * 60 * t) * np.exp(-t * 8) * 0.6
    sig = filtered * 0.7 + thump
    env = np.exp(-t * 4) * envelope(n, attack=0.005, release=0.1)
    return sig * env


def gen_hit() -> np.ndarray:
    """Short metallic impact."""
    duration = 0.3
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    # Multiple inharmonic frequencies for metallic timbre
    freqs = [440, 587, 831, 1120, 1487]
    sig = np.zeros(n)
    for i, f in enumerate(freqs):
        sig += np.sin(2 * np.pi * f * t) * (0.4 / (i + 1))
    # Noise transient at start
    rng = np.random.default_rng(77)
    noise = rng.normal(0, 1, n) * np.exp(-t * 80) * 0.5
    sig += noise
    env = np.exp(-t * 15) * envelope(n, attack=0.001, release=0.02)
    return sig * env


def gen_click() -> np.ndarray:
    """Crisp UI click."""
    duration = 0.05
    n = int(SAMPLE_RATE * duration)
    t = np.linspace(0, duration, n, endpoint=False)
    # Very short sine burst
    sig = np.sin(2 * np.pi * 1000 * t) * 0.6
    # Add a click transient
    sig += np.sin(2 * np.pi * 4000 * t) * 0.3
    env = np.exp(-t * 100) * envelope(n, attack=0.001, release=0.005)
    return sig * env


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
