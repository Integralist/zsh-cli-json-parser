#!/usr/bin/env zsh

# Test suite for get_cli_options.zsh

# Source the script to be tested
source get_cli_options.zsh

# Test case counter
tests_run=0
tests_failed=0

# Helper function for assertions
assert_equal() {
  local description="$1"
  local actual="$2"
  local expected="$3"
  ((tests_run++))

  # Sort both actual and expected results for consistent comparison
  local sorted_actual=$(echo -n "$actual" | sort)
  local sorted_expected=$(echo -n "$expected" | sort)

  if [[ "$sorted_actual" == "$sorted_expected" ]]; then
    echo "✅ PASS: $description"
  else
    echo "❌ FAIL: $description"
    echo "  Expected:"
    echo "$expected" | sed 's/^/    /'
    echo "  Actual:"
    echo "$actual" | sed 's/^/    /'
    ((tests_failed++))
  fi
}

# --- Test Cases ---

# Test 1: Top-level commands
description="should return top-level commands"
actual=$(get_cli_options "example.json" "")
expected=$'service\nacl'
assert_equal "$description" "$actual" "$expected"

# Test 2: Top-level/global options
description="should return top-level/global options"
actual=$(get_cli_options "example.json" "--")
expected=$'--help\n--quiet\n--verbose'
assert_equal "$description" "$actual" "$expected"

# Test 3: Subcommands and options for 'acl'
description="should return subcommands and options for 'acl'"
actual=$(get_cli_options "example.json" "acl")
expected=$'--help-acl\ncreate\nlist'
assert_equal "$description" "$actual" "$expected"

# Test 4: Options only for 'acl'
description="should return options only for 'acl'"
actual=$(get_cli_options "example.json" "acl --")
expected=$'--help-acl'
assert_equal "$description" "$actual" "$expected"

# Test 5: Subcommands and options for 'acl list'
description="should return subcommands and options for 'acl list'"
actual=$(get_cli_options "example.json" "acl list")
expected=$'--json\nthird-level'
assert_equal "$description" "$actual" "$expected"

# Test 6: Options only for 'acl list'
description="should return options only for 'acl list'"
actual=$(get_cli_options "example.json" "acl list --")
expected=$'--json'
assert_equal "$description" "$actual" "$expected"

# Test 7: Subcommands and options for 'acl list third-level'
description="should return subcommands and options for 'acl list third-level'"
actual=$(get_cli_options "example.json" "acl list third-level")
expected=$'--foo\n--bar\nfourth-level'
assert_equal "$description" "$actual" "$expected"

# Test 8: Options only for 'acl list third-level'
description="should return options only for 'acl list third-level'"
actual=$(get_cli_options "example.json" "acl list third-level --")
expected=$'--foo\n--bar'
assert_equal "$description" "$actual" "$expected"

# --- Test Summary ---

echo "\n---"
echo "Total tests: $tests_run"
echo "Tests failed: $tests_failed"
echo "---"

if (( tests_failed > 0 )); then
  exit 1
fi

exit 0
