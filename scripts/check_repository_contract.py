from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    ROOT / "README.md",
    ROOT / "LICENSE",
    ROOT / "AGENTS.md",
    ROOT / "docs" / "GOVERNANCE.md",
]
FORBIDDEN_NAMES = {".env", ".env.production", "credentials.yml.enc"}


def main() -> None:
    missing = [str(path.relative_to(ROOT)) for path in REQUIRED if not path.is_file()]
    if missing:
        raise SystemExit(f"missing repository contract files: {', '.join(missing)}")

    forbidden = []
    for path in ROOT.rglob("*"):
        if ".git" in path.parts:
            continue
        if path.is_file() and path.name in FORBIDDEN_NAMES:
            forbidden.append(str(path.relative_to(ROOT)))

    if forbidden:
        raise SystemExit(f"forbidden sensitive file names committed: {', '.join(forbidden)}")


if __name__ == "__main__":
    main()
