"""
G1 Ready — automated verification script.

Run this from inside your local g1_ready git clone:
    python verify_g1_ready.py

This repo stores questions as Dart source (lib/data/question_data.dart),
not a JSON pool, and publishes its web content under docs/ (GitHub Pages)
rather than a top-level privacy/ folder. Checks below are adapted to that
actual layout:

  1. lib/data/question_data.dart exists and parses into question blocks
  2. Question IDs are unique and sequential within each set (N_1, N_2, ...)
  3. Every question has exactly 4 options and a correctIndex in 0-3
  4. No duplicate question text
  5. Sets are numbered 1-8, and each Question's id prefix matches the set
     list it's declared in (e.g. set3 only contains "3_*" ids)
  6. .github/workflows/*.yml (if any) are valid YAML
  7. docs/ folder exists with expected GitHub Pages files
  8. Secret-scan: tracked files AND full git history for leaked credentials
     (GitHub tokens, private key blocks) — important given several tokens
     and a service-account key were pasted in chat during setup.

Exits non-zero and prints a clear FAIL list if anything is wrong;
prints a clean PASS summary otherwise.
"""

import glob
import os
import re
import subprocess
import sys

REPO_ROOT = os.getcwd()
FAILURES = []
WARNINGS = []


def fail(msg):
    FAILURES.append(msg)
    print(f"[FAIL] {msg}")


def warn(msg):
    WARNINGS.append(msg)
    print(f"[WARN] {msg}")


def ok(msg):
    print(f"[ OK ] {msg}")


# ---------------------------------------------------------------------
# 1-5: question_data.dart integrity
# ---------------------------------------------------------------------
data_path = os.path.join(REPO_ROOT, "lib", "data", "question_data.dart")

QUESTION_RE = re.compile(
    r"Question\(\s*"
    r"id:\s*'(?P<id>[^']*)',\s*"
    r"question:\s*'(?P<question>(?:[^'\\]|\\.)*)',\s*"
    r"options:\s*\[(?P<options>[^\]]*)\],\s*"
    r"correctIndex:\s*(?P<correctIndex>-?\d+),",
    re.DOTALL,
)
SET_DECL_RE = re.compile(
    r"static const List<Question> set(?P<num>\d+)\s*=\s*\[(?P<body>.*?)\n  \];",
    re.DOTALL,
)

if not os.path.isfile(data_path):
    fail(f"lib/data/question_data.dart not found at {data_path}")
else:
    with open(data_path, encoding="utf-8-sig") as f:
        src = f.read()

    sets = SET_DECL_RE.findall(src)
    if not sets:
        fail("Could not find any 'static const List<Question> setN = [...]' blocks")
        sets = []
    else:
        ok(f"Found {len(sets)} set declarations (set1..set{len(sets)})")

    bad_set_numbers = [n for n, _ in sets if not (1 <= int(n) <= 8)]
    if bad_set_numbers:
        fail(f"Set numbers outside 1-8 found: {bad_set_numbers}")
    else:
        ok("All set numbers are in range 1-8")

    all_questions = []
    for set_num, body in sets:
        qs = [m.groupdict() for m in QUESTION_RE.finditer(body)]
        for q in qs:
            q["set"] = set_num
        all_questions.append((set_num, qs))

    total = sum(len(qs) for _, qs in all_questions)
    if total == 0:
        fail("No Question(...) entries could be parsed from question_data.dart")
    else:
        ok(f"Parsed {total} Question(...) entries across all sets")

    # id prefix must match the set it's declared in
    mismatched = []
    for set_num, qs in all_questions:
        for q in qs:
            prefix = q["id"].split("_")[0] if "_" in q["id"] else None
            if prefix != set_num:
                mismatched.append((q["id"], set_num))
    if mismatched:
        fail(f"Question ids whose prefix doesn't match their declared set: {mismatched}")
    else:
        ok("All question ids' set-prefix matches the list they're declared in")

    # ids sequential within each set: N_1, N_2, ... N_k
    non_sequential = []
    for set_num, qs in all_questions:
        expected = [f"{set_num}_{i}" for i in range(1, len(qs) + 1)]
        actual = [q["id"] for q in qs]
        if actual != expected:
            non_sequential.append(set_num)
    if non_sequential:
        fail(f"Sets with non-sequential ids: {non_sequential}")
    else:
        ok("All ids are sequential within their set (N_1, N_2, ...)")

    flat = [q for _, qs in all_questions for q in qs]
    ids = [q["id"] for q in flat]
    if len(ids) != len(set(ids)):
        dupes = {i for i in ids if ids.count(i) > 1}
        fail(f"Duplicate question IDs found: {dupes}")
    else:
        ok("All question IDs are unique")

    texts = [q["question"] for q in flat]
    if len(texts) != len(set(texts)):
        dupes = {t for t in texts if texts.count(t) > 1}
        fail(f"Duplicate question text found: {dupes}")
    else:
        ok("No duplicate question text")

    bad_options = []
    for q in flat:
        opts = [o for o in re.findall(r"'((?:[^'\\]|\\.)*)'", q["options"])]
        if len(opts) != 4:
            bad_options.append(q["id"])
    if bad_options:
        fail(f"Questions without exactly 4 options: {bad_options}")
    else:
        ok("Every question has exactly 4 options")

    bad_answers = [
        q["id"] for q in flat
        if not (0 <= int(q["correctIndex"]) <= 3)
    ]
    if bad_answers:
        fail(f"Questions with invalid correctIndex: {bad_answers}")
    else:
        ok("Every correctIndex is a valid int 0-3")

# ---------------------------------------------------------------------
# 6: workflow YAML validity (repo currently has none — that's a WARN)
# ---------------------------------------------------------------------
workflow_dir = os.path.join(REPO_ROOT, ".github", "workflows")
if not os.path.isdir(workflow_dir):
    warn(".github/workflows/ not found - no CI workflows configured")
else:
    yml_files = glob.glob(os.path.join(workflow_dir, "*.yml")) + glob.glob(
        os.path.join(workflow_dir, "*.yaml")
    )
    if not yml_files:
        warn(".github/workflows/ exists but has no .yml/.yaml files")
    else:
        try:
            import yaml  # requires: pip install pyyaml
            for wf_path in yml_files:
                with open(wf_path, encoding="utf-8") as f:
                    wf = yaml.safe_load(f)
                if "jobs" in wf:
                    ok(f"{os.path.relpath(wf_path, REPO_ROOT)} is valid YAML with a jobs section")
                else:
                    fail(f"{os.path.relpath(wf_path, REPO_ROOT)} parsed but missing 'jobs' key")
        except ImportError:
            warn("PyYAML not installed - skipping YAML parse check (pip install pyyaml)")
        except Exception as e:
            fail(f"Workflow YAML failed to parse: {e}")

# ---------------------------------------------------------------------
# 7: docs/ (GitHub Pages) folder
# ---------------------------------------------------------------------
docs_dir = os.path.join(REPO_ROOT, "docs")
expected_docs_files = {"index.html", "privacy-policy.html"}
if not os.path.isdir(docs_dir):
    fail("docs/ folder not found")
else:
    present = set(os.listdir(docs_dir))
    missing = expected_docs_files - present
    if missing:
        fail(f"docs/ folder missing expected files: {missing}")
    else:
        ok("docs/ folder present with expected files")

# ---------------------------------------------------------------------
# 8: secret scan — tracked files + full git history
# ---------------------------------------------------------------------
SECRET_PATTERNS = [
    (r"gh[pousr]_[A-Za-z0-9]{30,}", "GitHub classic/fine-grained-style token"),
    (r"github_pat_[A-Za-z0-9_]{50,}", "GitHub fine-grained PAT"),
    (r"-----BEGIN (RSA |EC |)PRIVATE KEY-----", "Private key block"),
]


def scan_text(text, source_label):
    hits = []
    for pattern, desc in SECRET_PATTERNS:
        if re.search(pattern, text):
            hits.append((desc, source_label))
    return hits


all_hits = []

# scan current working tree (tracked files only)
try:
    tracked_files = subprocess.run(
        ["git", "ls-files"], capture_output=True, text=True,
        encoding="utf-8", errors="replace", check=True,
    ).stdout.splitlines()
    for fpath in tracked_files:
        full = os.path.join(REPO_ROOT, fpath)
        if os.path.isfile(full):
            try:
                with open(full, encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                all_hits.extend(scan_text(content, f"working tree: {fpath}"))
            except Exception:
                pass
except subprocess.CalledProcessError:
    warn("Not inside a git repo, or git not available - skipping working-tree scan")

# scan full git history (all commits, all branches) for the same patterns
try:
    log_output = subprocess.run(
        ["git", "log", "--all", "-p"], capture_output=True, text=True,
        encoding="utf-8", errors="replace", check=True,
    ).stdout
    hist_hits = scan_text(log_output, "git history (any commit)")
    all_hits.extend(hist_hits)
except subprocess.CalledProcessError:
    warn("Could not scan git history")

if all_hits:
    seen = set()
    for desc, loc in all_hits:
        key = (desc, loc)
        if key not in seen:
            seen.add(key)
            fail(f"Possible secret found - {desc} in {loc}")
else:
    ok("No obvious secrets found in tracked files or git history")

if "g1ready-release.jks" in subprocess.run(
    ["git", "ls-files"], capture_output=True, text=True
).stdout:
    warn(
        "g1ready-release.jks (release signing keystore) is tracked in git - "
        "this is a binary secret pattern-matching can't catch; make sure the "
        "passwords for it are NOT also committed anywhere"
    )

# ---------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------
print("\n" + "=" * 60)
if FAILURES:
    print(f"RESULT: {len(FAILURES)} check(s) FAILED, {len(WARNINGS)} warning(s)")
    sys.exit(1)
else:
    print(f"RESULT: All checks PASSED ({len(WARNINGS)} warning(s))")
    sys.exit(0)
