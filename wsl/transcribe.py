#!/usr/bin/env python3
"""Transcribe an audio or video file locally with faster-whisper. Nothing leaves the machine
except the one-time model download from Hugging Face.

Usage: transcribe.py [--lang he|en|auto] [--model NAME] [--out FILE.md] [--no-timestamps] INPUT

Default model for Hebrew: ivrit-ai/whisper-large-v3-turbo-ct2 (Apache-2.0, Hebrew fine-tune).
Default model for English and auto: deepdml/faster-whisper-large-v3-turbo-ct2.
Runs on CPU with int8 weights; a 3 minute memo takes about a minute on a laptop, an hour of
meeting takes 20 to 40 minutes. Start it and keep working.
"""
import argparse
import datetime as dt
import os
import sys
import time
from pathlib import Path

HE_MODEL = "ivrit-ai/whisper-large-v3-turbo-ct2"
GEN_MODEL = "deepdml/faster-whisper-large-v3-turbo-ct2"


def hms(seconds: float) -> str:
    s = int(seconds)
    return f"{s // 3600:02d}:{s % 3600 // 60:02d}:{s % 60:02d}"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", type=Path)
    ap.add_argument("--lang", default="he", help="he (default), en, or auto")
    ap.add_argument("--model", default=None, help="faster-whisper / CTranslate2 model id or local path")
    ap.add_argument("--out", type=Path, default=None, help="output markdown (default: next to the input)")
    ap.add_argument("--no-timestamps", action="store_true", help="plain paragraphs only")
    ap.add_argument("--threads", type=int, default=max(1, (os.cpu_count() or 4) - 1))
    a = ap.parse_args()

    if not a.input.is_file():
        print(f"not a file: {a.input}", file=sys.stderr)
        return 2
    try:
        from faster_whisper import WhisperModel
    except ImportError:
        print("faster-whisper is not installed; run transcribe.sh, which creates the venv", file=sys.stderr)
        return 3

    lang = None if a.lang == "auto" else a.lang
    model_id = a.model or (HE_MODEL if lang == "he" else GEN_MODEL)
    out = a.out or a.input.with_suffix(".md")

    t0 = time.time()
    print(f"model {model_id} (cpu, int8, {a.threads} threads); first run downloads it", file=sys.stderr)
    model = WhisperModel(model_id, device="cpu", compute_type="int8", cpu_threads=a.threads)
    segments, info = model.transcribe(
        str(a.input),
        language=lang,
        beam_size=5,
        vad_filter=True,
        vad_parameters={"min_silence_duration_ms": 700},
        condition_on_previous_text=False,
    )

    lines = []
    plain = []
    for seg in segments:
        text = seg.text.strip()
        if not text:
            continue
        plain.append(text)
        lines.append(f"- `{hms(seg.start)}` {text}")
        print(f"\r{hms(seg.end)} / {hms(info.duration)}", end="", file=sys.stderr, flush=True)
    print(file=sys.stderr)

    rtl = (info.language == "he")
    body = ("\n".join(lines) if not a.no_timestamps else "\n\n".join(plain))
    header = (
        f"# Transcript: {a.input.name}\n\n"
        f"- Source: `{a.input}` ({hms(info.duration)})\n"
        f"- Transcribed: {dt.datetime.now():%Y-%m-%d %H:%M}, locally, model `{model_id}`, "
        f"language {info.language} (p={info.language_probability:.2f})\n"
        f"- Auto-transcribed: names and numbers can be wrong; verify before filing facts.\n\n"
    )
    if rtl:
        body = f'<div dir="rtl">\n\n{body}\n\n</div>\n'
    out.write_text(header + body + "\n", encoding="utf-8")
    print(f"wrote {out} ({len(plain)} segments, {time.time() - t0:.0f}s)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
