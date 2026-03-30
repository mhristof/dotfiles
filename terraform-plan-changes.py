#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["ansicolors"]
# ///
# -*- coding: utf-8 -*-
# vim:fenc=utf-8

""" """

import json
import sys
import subprocess
import os

from colors import color

if len(sys.argv) < 2:
    print("Usage: terraform-plan-changes.py <plan>")
    sys.exit(1)

verbose = "-v" in sys.argv
sys.argv = [x for x in sys.argv if x != "-v"]

plan = sys.argv[1]

# check if file exists
try:
    with open(plan) as f:
        pass
except FileNotFoundError:
    print(f"File {plan} not found")
    sys.exit(1)


def terraform_show(plan):
    cmd = f"terraform show -json {plan}"
    process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

    return json.loads(output)


modules_with_tags = {}
modules_without_tags = {}
create = 0
delete = 0
paths = []

for change in terraform_show(plan).get("resource_changes", []):
    if "no-op" not in change["change"]["actions"]:
        paths.append(change["address"])

    if "create" in change["change"]["actions"]:
        create += 1

    if "delete" in change["change"]["actions"]:
        delete += 1

    if "update" != change["change"]["actions"][0]:
        continue

    if verbose:
        print(change["address"])

    values = change["change"]

    for k, v in values["before"].items():
        if k == "tags" or k == "tags_all":
            # if its not a dict, skip

            if not isinstance(v, dict):
                continue

            if k not in values["after"]:
                continue

            for tag, value in v.items():
                if values["after"].get(k, {}).get(tag, None) != value:
                    if verbose:
                        print(f"foo {tag}: {value} -> {values['after'][k][tag]}")
                    modules_with_tags[change["address"]] = 1

                    continue
        elif values["after"].get(k, v) != v:
            if verbose:
                print("key:", k)
                print("value:", v)
            modules_without_tags[change["address"]] = 1

            continue

    for k, v in values["after"].items():
        if k == "tags" or k == "tags_all":
            if not isinstance(v, dict):
                continue

            for tag, value in v.items():
                before = values["before"].get(k, None).get(tag, None)

                if before != value:
                    if verbose:
                        print(f"bar {tag}: {before} -> {value}")
                    modules_with_tags[change["address"]] = 1

                    continue
        elif values["before"].get(k, v) != v:
            if verbose:
                print("key:", k)
                print("value:", v)
            modules_without_tags[change["address"]] = 1

            continue

total_changes = len(modules_without_tags) + len(modules_with_tags)
print(
    color("Plan:", style="bold"),
    f"{create} to add, {total_changes} to change (from which {len(modules_with_tags)} are tag-only), {delete} to destroy.",
)

common_prefix = os.path.commonprefix(paths)
print("Resources common prefix:", common_prefix)


if verbose:
    print(json.dumps(modules_without_tags, indent=4))

# print(f"Modules with tag changes: {len(modules_with_tags)}")

# if len(modules_without_tags) > 0:
#     print(
#         color("Modules with changes:", style="bold"),
#         color(len(modules_without_tags), fg="red"),
#     )
