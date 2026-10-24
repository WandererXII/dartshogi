#!/bin/bash

set -euo pipefail

dart format --output=none --set-exit-if-changed lib test
dart analyze
dart test
