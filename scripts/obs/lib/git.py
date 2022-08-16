#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2022 sysmocom - s.f.m.c. GmbH <info@sysmocom.de>
import os
import re
import lib.config


def get_repo_path(project):
    return f"{lib.config.path_cache}/{os.path.basename(project)}"


def get_repo_url(project):
    if project in lib.config.git_url_other:
        return lib.config.git_url_other[project]
    return f"{lib.config.git_url_default}/{project}"


def get_latest_tag_pattern(project):
    if project in lib.config.git_latest_tag_pattern_other:
        return lib.config.git_latest_tag_pattern_other[project]
    return lib.config.git_latest_tag_pattern_default


def clone(project, fetch=False):
    repo_path = get_repo_path(project)
    url = get_repo_url(project)

    if os.path.exists(repo_path):
        if fetch:
            print(f"{project}: 'git fetch'")
            lib.run_cmd(["git", "fetch"], cwd=repo_path)
        else:
            print(f"{project}: using cached {url} (not cloning, not fetching)")
        return

    print(f"{project}: cloning {url}")
    os.makedirs(lib.config.path_cache, exist_ok=True)
    lib.run_cmd(["git", "clone", url, repo_path])

    lib.run_cmd(["git", "config", "user.name", "Osmocom OBS scripts"],
                cwd=repo_path)
    lib.run_cmd(["git", "config", "user.email", "info@osmocom.org"],
                cwd=repo_path)


def clean(project):
    repo_path = get_repo_path(project)
    print(f"{project}: 'git clean -ffxd'")
    lib.run_cmd(["git", "clean", "-ffxd"], cwd=repo_path)


def checkout(project, branch):
    repo_path = get_repo_path(project)
    print(f"{project}: 'git checkout -f {branch}'")
    lib.run_cmd(["git", "checkout", "-f", branch], cwd=repo_path)
    print(f"{project}: 'git reset --hard {branch}'")
    lib.run_cmd(["git", "reset", "--hard", branch], cwd=repo_path)


def checkout_default_branch(project):
    branch = lib.config.git_branch_default
    if project in lib.config.git_branch_other:
        branch = lib.config.git_branch_other[project]

    checkout(project, f"origin/{branch}")


def get_latest_tag(project):
    pattern_str = get_latest_tag_pattern(project)
    pattern = re.compile(pattern_str)
    repo_path = get_repo_path(project)

    git_tag_ret = lib.run_cmd(["git", "tag", "-l", "--sort=-v:refname"],
                              cwd=repo_path)

    for line in git_tag_ret.output.split('\n'):
        line = line.strip('\r')
        if pattern.match(line):
            return line

    lib.exit_error_cmd(git_tag_ret, f"couldn't find latest tag for {project},"
                       f" regex used on output: {pattern_str}")


def get_latest_tag_remote(project):
    pattern_str = get_latest_tag_pattern(project)
    pattern = re.compile(pattern_str)

    print(f"{project}: getting latest tag from git remote")
    ls_remote = lib.run_cmd(["git", "ls-remote", "--tags", "--sort=-v:refname",
                             get_repo_url(project)])
    for line in ls_remote.output.split('\n'):
        # Tags are listed twice, skip the ones with ^{} at the end
        if "^{}" in line:
            continue

        if "refs/tags/" not in line:
            continue

        line = line.rstrip().split("refs/tags/")[1]
        if pattern.match(line):
            return line

    # No tag found probably means the repository was just created and doesn't
    # have a release tag yet
    return None


def checkout_latest_tag(project):
    checkout(project, get_latest_tag(project))
