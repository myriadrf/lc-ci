#!/bin/sh -e
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_DIR="$(git rev-parse --show-toplevel)"
PROJECT="$(basename "$PROJECT_DIR")"

exclude_paths_common() {
	# Stdout and stderr of regression tests
	echo '--exclude \.(ok|err)$'
	# Generated from commit log, which may contain spelling errors (OS#5232)
	echo '--exclude ^debian/changelog$'
	# Patch files
	echo '--exclude \.patch$'
}

exclude_paths_common_asn1c() {
	local pattern="^ \* Generated by asn1c-"
	local files="$(find -name '*.c' -o -name '*.h' | cut -d / -f 2-)"
	local i

	if [ -z "$files" ]; then
		return
	fi

	for i in $(grep -l "$pattern" $files); do
		# Example: --exclude ^include/osmocom/sabp/SABP_Data-Coding-Scheme.h$
		echo '--exclude ^'$i'$'
	done
}

exclude_paths_project() {
	case "$PROJECT" in
	libosmocore)
		# Imported code
		echo '--exclude ^src/gsm/kdf/'
		echo '--exclude ^src/gsm/milenage/'
		;;
	osmo-ci)
		# Do not warn about spelling errors in spelling.txt :)
		echo '--exclude ^lint/checkpatch/spelling.txt$'
		;;
	osmo-pcu)
		# Imported code
		echo '--exclude ^src/csn1.(c|h)$'
		echo '--exclude ^src/csn1_(enc|dec).c$'
		echo '--exclude ^src/gsm_rlcmac.(c|h)$'
		;;
	esac
}

# Ignored checks:
# * ASSIGN_IN_IF: not followed (e.g. 'if ((u8 = gsup_msg->cause))')
# * AVOID_EXTERNS: we do use externs
# * BLOCK_COMMENT_STYLE: we don't use a trailing */ on a separate line
# * BRACES_NOT_NECESSARY: not followed
# * COMPLEX_MACRO: we don't use parentheses when building macros of strings across multiple lines
# * CONSTANT_COMPARISON: not followed: "Comparisons should place the constant on the right side"
# * DEEP_INDENTATION: warns about many leading tabs, not useful if changing existing code without refactoring
# * EMBEDDED_FILENAME: this is useful sometimes (e.g. explaining how to use a script), so do not fail here
# * EMBEDDED_FUNCTION_NAME: often __func__ isn't used, arguably not much benefit in changing this when touching code
# * EXECUTE_PERMISSIONS: not followed, files need to be executable: git-version-gen, some in debian/
# * FILE_PATH_CHANGES: we don't use a MAINTAINERS file
# * FUNCTION_WITHOUT_ARGS: not followed: warns about func() instead of func(void)
# * GLOBAL_INITIALISERS: we initialise globals to NULL for talloc ctx (e.g. *tall_lapd_ctx = NULL)
# * IF_0: used intentionally
# * INITIALISED_STATIC: we use this, see also http://lkml.iu.edu/hypermail/linux/kernel/0808.1/2235.html
# * LINE_CONTINUATIONS: false positives
# * LINE_SPACING: we don't always put a blank line after declarations
# * LONG_LINE*: should be 120 chars, but exceptions are done often so don't fail here
# * MISSING_SPACE: warns about breaking strings at space characters, not useful for long strings of hex chars
# * PREFER_DEFINED_ATTRIBUTE_MACRO: macros like __packed not defined in libosmocore
# * PREFER_FALLTHROUGH: pseudo keyword macro "fallthrough" is not defined in libosmocore
# * REPEATED_WORD: false positives in doxygen descriptions (e.g. '\param[in] data Data passed through...')
# * SPDX_LICENSE_TAG: we don't place it on line 1
# * SPLIT_STRING: we do split long messages over multiple lines
# * STRING_FRAGMENTS: sometimes used intentionally to improve readability
# * TRACING_LOGGING: recommends to use kernel's internal ftrace instead of printf("%s()\n", __func__)
# * TRAILING_STATEMENTS: not followed, e.g. 'while (osmo_select_main_ctx(1) > 0);' is put in one line
# * UNNECESSARY_BREAK: not followed (see https://gerrit.osmocom.org/c/libosmo-netif/+/26429)
# * UNNECESSARY_INT: not followed (see https://gerrit.osmocom.org/c/libosmocore/+/25345)
# * UNSPECIFIED_INT: not followed (doesn't seem useful for us)
# * VOLATILE: using volatile makes sense in embedded projects so this warning is not useful for us

cd "$PROJECT_DIR"

$SCRIPT_DIR/checkpatch.pl \
	$(exclude_paths_common) \
	$(exclude_paths_common_asn1c) \
	$(exclude_paths_project) \
	--ignore ASSIGN_IN_IF \
	--ignore AVOID_EXTERNS \
	--ignore BLOCK_COMMENT_STYLE \
	--ignore BRACES_NOT_NECESSARY \
	--ignore COMPLEX_MACRO \
	--ignore CONSTANT_COMPARISON \
	--ignore DEEP_INDENTATION \
	--ignore EMBEDDED_FILENAME \
	--ignore EMBEDDED_FUNCTION_NAME \
	--ignore EXECUTE_PERMISSIONS \
	--ignore FILE_PATH_CHANGES \
	--ignore FUNCTION_WITHOUT_ARGS \
	--ignore GLOBAL_INITIALISERS \
	--ignore IF_0 \
	--ignore INITIALISED_STATIC \
	--ignore LINE_CONTINUATIONS \
	--ignore LINE_SPACING \
	--ignore LONG_LINE \
	--ignore LONG_LINE_COMMENT \
	--ignore LONG_LINE_STRING \
	--ignore MISSING_SPACE \
	--ignore PREFER_DEFINED_ATTRIBUTE_MACRO \
	--ignore PREFER_FALLTHROUGH \
	--ignore REPEATED_WORD \
	--ignore SPDX_LICENSE_TAG \
	--ignore SPLIT_STRING \
	--ignore STRING_FRAGMENTS \
	--ignore TRACING_LOGGING \
	--ignore TRAILING_STATEMENTS \
	--ignore UNNECESSARY_BREAK \
	--ignore UNNECESSARY_INT \
	--ignore UNSPECIFIED_INT \
	--ignore VOLATILE \
	--max-line-length 120 \
	--typedefsfile "$SCRIPT_DIR/typedefs_osmo.txt" \
	--no-signoff \
	--no-tree \
	"$@"
