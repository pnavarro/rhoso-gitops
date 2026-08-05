#!/usr/bin/env python3
"""Check docs.redhat.com links in the validatedpatterns/docs repository.

Scans rhoso-gitops AsciiDoc files for docs.redhat.com URLs, verifies each
is reachable, and outputs a JSON report of broken links.
"""

import json
import os
import re
import sys
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urldefrag
from urllib.request import Request, urlopen

DOCS_DIRS = [
    "content/patterns/rhoso-gitops",
    "modules/rhoso-gitops",
]
URL_PATTERN = re.compile(r"https://docs\.redhat\.com[^\[\]() \"]*")
REQUEST_TIMEOUT = 30


def find_links(base_path: Path) -> list[dict]:
    """Extract all docs.redhat.com URLs with file and line context."""
    matches = []
    for docs_dir in DOCS_DIRS:
        search_path = base_path / docs_dir
        if not search_path.is_dir():
            continue
        for adoc_file in search_path.rglob("*.adoc"):
            rel_path = adoc_file.relative_to(base_path)
            text = adoc_file.read_text().splitlines()
            for line_num, line in enumerate(text, 1):
                for m in URL_PATTERN.finditer(line):
                    matches.append(
                        {
                            "url": m.group(),
                            "file": str(rel_path),
                            "line": line_num,
                        }
                    )
    return matches


def check_url(url: str, retries: int = 2) -> tuple[int, str]:
    """Check a URL and return (status_code, error_message).

    Returns (200, "") on success. Retries on transient failures.
    """
    headers = {
        "User-Agent": "rhoso-gitops-link-checker/1.0",
        "Accept": "text/html,application/xhtml+xml",
    }
    for attempt in range(retries + 1):
        req = Request(url, method="GET", headers=headers)
        try:
            with urlopen(req, timeout=REQUEST_TIMEOUT) as resp:
                return resp.status, ""
        except HTTPError as e:
            if e.code < 500 and e.code != 429:
                return e.code, str(e.reason)
            if attempt < retries:
                time.sleep(5)
                continue
            return e.code, str(e.reason)
        except (URLError, TimeoutError) as e:
            if attempt < retries:
                time.sleep(5)
                continue
            reason = str(e.reason) if isinstance(e, URLError) else "timeout"
            return 0, reason
    return 0, "max retries exceeded"


def check_all_links(matches: list[dict]) -> list[dict]:
    """Check each unique base URL and return broken link details."""
    url_to_matches: dict[str, list[dict]] = {}
    for m in matches:
        base_url, _ = urldefrag(m["url"])
        url_to_matches.setdefault(base_url, []).append(m)

    broken = []
    for base_url, entries in url_to_matches.items():
        status, error = check_url(base_url)
        if status >= 400 or status == 0:
            for entry in entries:
                broken.append(
                    {
                        **entry,
                        "status": status,
                        "error": error,
                    }
                )
            print(f"  BROKEN: {base_url} (HTTP {status}: {error})")
        else:
            print(f"  OK: {base_url}")

    return broken


def main():
    docs_path = Path(os.environ.get("DOCS_PATH", "."))
    github_output = os.environ.get("GITHUB_OUTPUT")

    print(f"Scanning for docs.redhat.com links in {docs_path}...")
    matches = find_links(docs_path)

    if not matches:
        print("No docs.redhat.com URLs found.")
        sys.exit(0)

    unique_count = len({urldefrag(m["url"])[0] for m in matches})
    print(f"Found {len(matches)} link(s) ({unique_count} unique base URLs)")
    print("Checking links...")
    broken = check_all_links(matches)

    if not broken:
        print("All links are healthy.")
        sys.exit(0)

    print(f"\n{len(broken)} broken link(s) found.")

    if github_output:
        with open(github_output, "a") as f:
            f.write(f"broken={json.dumps(broken)}\n")
    else:
        print(json.dumps(broken, indent=2))
        sys.exit(1)


if __name__ == "__main__":
    main()
