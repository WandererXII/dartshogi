#!/bin/bash

dart format --output=none --set-exit-if-changed $(find lib/src -name "*.dart" )
dart format --output=none --set-exit-if-changed $(find test -name "*.dart" )
dart analyze
dart test
