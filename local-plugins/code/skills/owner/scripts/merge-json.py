#!/usr/bin/env python3
"""Resolves a merge conflict in a JSON file key by key, and finds keys written twice.

    python3 merge-json.py <path>            a file in conflict, in the folder where the merge is open
    python3 merge-json.py --check <path>    only look for duplicate keys

The path may be absolute or relative, and the command may run from any folder of that working tree.

A file of messages or settings conflicts at every merge when two lanes each add keys near the same place, although
the two sides rarely touch the same key. Git's three versions of the file (the common ancestor, ours, theirs) are
merged object by object: a key only one side added, changed or removed follows that side. The file is written back
with ours' key order, theirs' new keys after them.

The whole file is rewritten: its indentation is kept (spaces or tabs), an array written on one line is spread over
several, and an escaped character is written as the character itself. Use it on files of keys and values, such as
a file of messages; resolve by hand a file where that rewriting matters.

Exit 0: merged with nothing left to decide; stage the file. Exit 1: some keys were changed differently on both
sides (the file holds ours for those, and they are listed so that you read both values and choose), or a key is
written twice. Exit 2: the file cannot be handled here (not strict JSON, not in conflict, not in a git folder).

Needs python3 and git, nothing else.
"""
import json
import os
import subprocess
import sys

MISSING = object()


class NotJson(Exception):
    pass


def duplicate_keys(path):
    def hook(pairs):
        seen = set()
        for key, _ in pairs:
            if key in seen:
                duplicates.append(key)
            seen.add(key)
        return dict(pairs)

    duplicates = []
    with open(path, encoding="utf-8") as handle:
        json.load(handle, object_pairs_hook=hook)
    return duplicates


def stage(number, top, relative):
    result = subprocess.run(["git", "show", f":{number}:{relative}"], capture_output=True, text=True, cwd=top)
    if result.returncode != 0:
        return MISSING
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise NotJson(str(error)) from error


def merge(base, ours, theirs, trail, undecided):
    if ours is MISSING and theirs is MISSING:
        return MISSING
    if ours == theirs:
        return ours
    if base is MISSING and (ours is MISSING or theirs is MISSING):
        return theirs if ours is MISSING else ours
    if base is not MISSING and ours == base:
        return theirs
    if base is not MISSING and theirs == base:
        return ours
    if isinstance(ours, dict) and isinstance(theirs, dict):
        base_object = base if isinstance(base, dict) else {}
        merged = {}
        for key in list(ours) + [key for key in theirs if key not in ours]:
            value = merge(base_object.get(key, MISSING), ours.get(key, MISSING), theirs.get(key, MISSING), trail + [key], undecided)
            if value is not MISSING:
                merged[key] = value
        return merged
    undecided.append(".".join(trail) or "(the whole file)")
    return theirs if ours is MISSING else ours


def indent_of(text):
    """The indentation of the first indented line: a tab, or that many spaces; two spaces when nothing is indented."""
    for line in text.splitlines():
        if line.startswith("\t"):
            return "\t"
        stripped = line.lstrip(" ")
        if stripped and len(line) > len(stripped):
            return len(line) - len(stripped)
    return 2


def main():
    arguments = sys.argv[1:]
    check_only = arguments[:1] == ["--check"]
    if check_only:
        arguments = arguments[1:]
    if len(arguments) != 1:
        print(__doc__)
        return 2
    path = os.path.realpath(arguments[0])
    shown = arguments[0]

    if not check_only:
        located = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True, cwd=os.path.dirname(path))
        if located.returncode != 0:
            print(f"{shown}: not in a git folder; nothing done")
            return 2
        top = os.path.realpath(located.stdout.strip())
        relative = os.path.relpath(path, top)
        try:
            base, ours, theirs = stage(1, top, relative), stage(2, top, relative), stage(3, top, relative)
        except NotJson as error:
            print(f"{shown}: not strict JSON ({error}); resolve it by hand")
            return 2
        if ours is MISSING or theirs is MISSING:
            print(f"{shown}: git holds no conflict for this file here; nothing done")
            return 2
        ours_text = subprocess.run(["git", "show", f":2:{relative}"], capture_output=True, text=True, cwd=top).stdout
        undecided = []
        merged = merge(base, ours, theirs, [], undecided)
        with open(path, "w", encoding="utf-8") as handle:
            json.dump(merged, handle, ensure_ascii=False, indent=indent_of(ours_text))
            handle.write("\n")
        if undecided:
            print(f"{shown}: written, but {len(undecided)} key(s) differ on both sides; ours was kept, read both and choose:")
            for key in undecided:
                print(f"    {key}")
            return 1
        print(f"{shown}: merged key by key, nothing left to decide; stage it")

    try:
        duplicates = duplicate_keys(path)
    except (OSError, json.JSONDecodeError) as error:
        print(f"{shown}: not readable as strict JSON ({error})")
        return 2
    if duplicates:
        print(f"{shown}: {len(duplicates)} key(s) written twice in one object, the last one silently wins:")
        for key in duplicates:
            print(f"    {key}")
        return 1
    if check_only:
        print(f"{shown}: no key written twice")
    return 0


if __name__ == "__main__":
    sys.exit(main())
