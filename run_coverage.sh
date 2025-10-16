#!/bin/bash

# --- Configuration ---
# The directory where we will store the final .exec files
OUTPUT_DIR="target/jacoco-per-test"
# The location of the test source files
TEST_SRC_DIR="src/test/java"

# --- Script Start ---
echo "Starting per-test coverage generation..."

# 1. Clean the project and create our output directory
mvn clean
mkdir -p "$OUTPUT_DIR"

# 2. Find all Java test files and convert their paths to class names
# Example: src/test/java/org/apache/commons/lang3/ArrayUtilsTest.java
# Becomes: org.apache.commons.lang3.ArrayUtilsTest
echo "Finding all test classes..."
TEST_CLASSES=$(find "$TEST_SRC_DIR" -type f -name '*Test.java' | sed "s#$TEST_SRC_DIR/##" | sed 's#/#.#g' | sed 's/.java//')

# 3. Loop through each test class and run it individually
for TST_CLASS in $TEST_CLASSES; do
    echo "------------------------------------------------------------"
    echo "Running test: $TST_CLASS"
    echo "------------------------------------------------------------"

    # Run just this single test class. The -Dtest flag does this.
    # We also skip the RAT check and tell Maven not to fail if one test fails.
    mvn test -Dtest="$TST_CLASS" -Drat.skip=true -Dmaven.test.failure.ignore=true

    # Check if the jacoco.exec file was created
    if [ -f "target/jacoco.exec" ]; then
        # Copy the resulting coverage file to our output directory with a unique name
        cp "target/jacoco.exec" "$OUTPUT_DIR/$TST_CLASS.exec"
        echo "SUCCESS: Saved coverage to $OUTPUT_DIR/$TST_CLASS.exec"
    else
        echo "WARNING: No jacoco.exec file generated for $TST_CLASS"
    fi
done

echo "------------------------------------------------------------"
echo "✅ All tests complete. Per-test coverage data is in $OUTPUT_DIR"
echo "------------------------------------------------------------"