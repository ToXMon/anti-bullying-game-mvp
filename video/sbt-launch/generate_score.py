"""Generate an original, quiet, narration-free tonal bed for the local concept preview."""
import math
import struct
import wave
from pathlib import Path

RATE = 44100
DURATION = 21
CHORDS = [(196, 246.94, 293.66), (174.61, 220, 261.63),
          (196, 246.94, 293.66), (164.81, 207.65, 261.63),
          (196, 246.94, 293.66)]
BOUNDARIES = (0, 3, 7, 12, 16, 21)
path = Path(__file__).parent / "assets" / "score.wav"
with wave.open(str(path), "wb") as out:
    out.setnchannels(1)
    out.setsampwidth(2)
    out.setframerate(RATE)
    frames = bytearray()
    for sample in range(RATE * DURATION):
        t = sample / RATE
        n = next(i for i in range(5) if t < BOUNDARIES[i + 1])
        notes = CHORDS[n]
        # Rounded chord changes, gentle tremolo, and full-track fade.
        mix = 0.0
        for j, freq in enumerate(notes):
            mix += math.sin(2 * math.pi * freq * t + j * 0.6) / (j + 2)
        envelope = min(1, t / 1.5, (DURATION - t) / 1.8)
        level = 0.065 * max(0, envelope) * (0.92 + 0.08 * math.sin(2 * math.pi * 0.7 * t))
        frames.extend(struct.pack("<h", int(32767 * level * mix)))
    out.writeframes(frames)
print(path)
