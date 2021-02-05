#!/usr/bin/env bats

@test "embedded c" {
  xgo github.com/karalabe/xgo/tests/embedded_c
  [ "$status" -eq 0 ]
}

@test "embedded cpp" {
  xgo github.com/karalabe/xgo/tests/embedded_cpp
  [ "$status" -eq 0 ]
}

@test "has mod" {
  skip "this test doesn't yet exist"
  xgo src.techknowlogick.com/xgo/tests/hasmod
  [ "$status" -eq 0 ]
}

@test "has mod and vendor" {
  skip "this test doesn't yet exist"
  xgo src.techknowlogick.com/xgo/tests/hasmodandvendor
  [ "$status" -eq 0 ]
}

@test "branches" {
  xgo --branch develop github.com/ethereum/go-ethereum/cmd/geth
  [ "$status" -eq 0 ]
}

@test "cyan smoke" {
  xgo --branch develop github.com/rwcarlsen/cyan/cmd/cyan
  [ "$status" -eq 0 ]
}

@test "cockroach smoke" {
  xgo --targets "darwin-10.6/amd64" github.com/cockroachdb/cockroach
  [ "$status" -eq 0 ]
}