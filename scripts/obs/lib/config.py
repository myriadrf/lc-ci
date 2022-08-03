#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright 2022 sysmocom - s.f.m.c. GmbH <info@sysmocom.de>
import os

# Lists are ordered alphabetically.

path_top = os.path.normpath(f"{os.path.realpath(__file__)}/../..")
path_cache = f"{path_top}/_cache"
path_temp = f"{path_top}/_temp"

# Keep in sync with packages installed in data/Dockerfile
required_programs = [
    "dh",
    "dh_python3",
    "dpkg-buildpackage",
    "fakeroot",
    "find",
    "git",
    "meson",
    "osc",
    "rebar3",
    "sed",
]

required_python_modules = [
    "setuptools",
]

feeds = [
    "2022q1",
    "2022q2",
    "latest",
    "nightly",
    "nightly-asan",  # OS#5301
]
feeds_no_rpm_spec = [
    "nightly-asan",
]

# Osmocom projects: generated source packages will depend on a meta package,
# such as osmocom-nightly, osmocom-latest or osmocom-2022q1. This meta package
# prevents that packages from different feeds are mixed by accident.
projects_osmocom = [
    "erlang/osmo_dia2gsup",
    "libasn1c",
    "libgtpnl",
    "libosmo-abis",
    "libosmo-dsp",
    "libosmo-netif",
    "libosmo-sccp",
    "libosmocore",
    "libsmpp34",
    "libusrp",
    "osmo-bsc",
    "osmo-bts",
    "osmo-cbc",
    "osmo-e1d",
    "osmo-gbproxy",
    "osmo-ggsn",
    "osmo-gsm-manuals",
    "osmo-hlr",
    "osmo-hnbgw",
    "osmo-hnodeb",
    "osmo-iuh",
    "osmo-mgw",
    "osmo-msc",
    "osmo-pcap",
    "osmo-pcu",
    "osmo-remsim",
    "osmo-sgsn",
    "osmo-sip-connector",
    "osmo-smlc",
    "osmo-sysmon",
    "osmo-trx",
    "osmo-uecups",
    "python/osmo-python-tests",
    "rtl-sdr",
    "simtrace2",
]
projects_other = [
    "limesuite",
    "neocon",
    "open5gs",
]

# Do not build these for osmocom:nightly:asan
projects_osmocom_exclude_asan = [
    "erlang/osmo_dia2gsup",
    "libosmo-dsp",
    "osmo-gsm-manuals",
    "python/osmo-python-tests",
    "rtl-sdr",
]

git_url_default = "https://gerrit.osmocom.org"  # /project gets appended
git_url_other = {
    "libosmo-dsp": "https://gitea.osmocom.org/sdr/libosmo-dsp",
    "limesuite": "https://github.com/myriadrf/LimeSuite",
    "neocon": "https://github.com/laf0rge/neocon",
    "open5gs": "https://github.com/open5gs/open5gs",
    "rtl-sdr": "https://gitea.osmocom.org/sdr/rtl-sdr",
}

git_branch_default = "master"
git_branch_other = {
    "open5gs": "main",
}

git_latest_tag_pattern_default = "^[0-9]*\\.[0-9]*\\.[0-9]*$"
git_latest_tag_pattern_other = {
        "limesuite": "^v[0-9]*\\.[0-9]*\\.[0-9]*$",
        "open5gs": "^v[0-9]*\\.[0-9]*\\.[0-9]*$",
}

docker_image_name = "debian-bullseye-osmocom-obs"