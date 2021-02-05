#!/usr/bin/env bats

@test "embedded c" {
  go run xgo.go github.com/karalabe/xgo/tests/embedded_c >&3
  [ "$status" -eq 0 ]
}

@test "embedded cpp" {
  go run xgo.go github.com/karalabe/xgo/tests/embedded_cpp >&3
  [ "$status" -eq 0 ]
}

@test "has mod" {
  skip "this test doesn't yet exist"
  go run xgo.go src.techknowlogick.com/xgo/tests/hasmod >&3
  [ "$status" -eq 0 ]
}

@test "has mod and vendor" {
  skip "this test doesn't yet exist"
  go run xgo.go src.techknowlogick.com/xgo/tests/hasmodandvendor >&3
  [ "$status" -eq 0 ]
}

@test "branches" {
  go run xgo.go --branch develop github.com/ethereum/go-ethereum/cmd/geth >&3
  [ "$status" -eq 0 ]
}

@test "cyan smoke" {
  go run xgo.go --branch develop github.com/rwcarlsen/cyan/cmd/cyan >&3
  [ "$status" -eq 0 ]
}

@test "cockroach smoke" {
  go run xgo.go --targets "darwin-10.6/amd64" github.com/cockroachdb/cockroach >&3
  [ "$status" -eq 0 ]
}