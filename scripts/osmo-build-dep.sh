#!/bin/sh
. "$(dirname "$0")/common.sh"

project="$1"
branch="$2"
cfg="$3"

set -e

set +x
example="
Example:
  export deps=\$PWD/deps inst=\$PWD/inst
  mkdir -p \$deps
  mkdir -p \$inst
  MAKE=make PARALLEL_MAKE=-j8 osmo-build-dep.sh libosmocore
"

echo
echo
echo
echo " =============================== $project ==============================="
echo
if [ -z "$project" ]; then
	echo "internal failure: \$project is empty$example"
	exit 1
fi
if [ -z "$deps" ]; then
	echo "internal failure: \$deps is empty$example"
	exit 1
fi
if [ -z "$inst" ]; then
	echo "internal failure: \$inst is empty$example"
	exit 1
fi
if [ -z "$MAKE" ]; then
	echo "internal failure: \$MAKE is empty$example"
	exit 1
fi
set -x

mkdir -p "$deps"
cd "$deps"
osmo-deps.sh "$project" "$branch"
cd "$project"

# Keep the installation targets of the dependencies in a seperate directory
# hierarchy before stowing them to avoid wrongly suggesting that they are part
# of the -I and -L search paths
mkdir -p "$inst/stow"

subdir="$(osmo_source_subdir "$project")"
if [ -n "$subdir" ]; then
	cd "$subdir"
fi

autoreconf --install --force
./configure --prefix="$inst/stow/$project" --with-systemdsystemunitdir="$inst/stow/$project/lib/systemd/system" $cfg

if [ -n "$CHECK" ]; then
	$MAKE $PARALLEL_MAKE check
fi

$MAKE $PARALLEL_MAKE install

# Make the dependencies available through symlinks in $deps ($PWD/..).
STOW_DIR="$inst/stow" stow --restow $project
