#!/bin/bash

# Terraform Test Runner Script
# This script runs all the unit and integration tests for the Terraform ECS Infrastructure

set -e

# Set colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to print section headers
print_header() {
  echo -e "\n${YELLOW}========== $1 ==========${NC}\n"
}

# Function to run a test and report results
run_test() {
  local test_name=$1
  local test_script=$2
  
  echo -e "${YELLOW}Running test: ${test_name}${NC}"
  
  if bash "$test_script"; then
    echo -e "${GREEN}✓ Test passed: ${test_name}${NC}"
    return 0
  else
    echo -e "${RED}✗ Test failed: ${test_name}${NC}"
    return 1
  fi
}

# Main directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Initialize counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Run unit tests
print_header "Running Unit Tests"

for test_dir in unit/*; do
  if [ -d "$test_dir" ]; then
    for test_script in "$test_dir"/*.sh; do
      if [ -f "$test_script" ]; then
        TOTAL_TESTS=$((TOTAL_TESTS + 1))
        if run_test "$(basename "$test_dir")/$(basename "$test_script")" "$test_script"; then
          PASSED_TESTS=$((PASSED_TESTS + 1))
        else
          FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
      fi
    done
  fi
done

# Run integration tests
print_header "Running Integration Tests"

for test_script in integration/*.sh; do
  if [ -f "$test_script" ]; then
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if run_test "integration/$(basename "$test_script")" "$test_script"; then
      PASSED_TESTS=$((PASSED_TESTS + 1))
    else
      FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
  fi
done

# Print summary
print_header "Test Summary"
echo -e "Total tests: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"

# Exit with failure if any tests failed
if [ $FAILED_TESTS -gt 0 ]; then
  exit 1
fi

exit 0