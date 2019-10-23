package main

import (
	"testing"
)

func TestCompareOutAndImage(t *testing.T) {
	out1 := []byte(`
REPOSITORY                                      TAG                 IMAGE ID                                                                  CREATED             SIZE
techknowlogick/xgo                              latest              sha256:9fa22a0bbbfaff02eb2abb3f593ca2f27151d0cba5e8ff2a2c6ab87337de45ae   3 weeks ago         6.14GB
nginx                                           latest              sha256:f949e7d76d63befffc8eec2cbf8a6f509780f96fb3bacbdc24068d594a77f043   3 weeks ago         126MB
ubuntu                                          latest              sha256:2ca708c1c9ccc509b070f226d6e4712604e0c48b55d7d8f5adc9be4a4d36029a   4 weeks ago         64.2MB
lmenezes/cerebro                                latest              sha256:419a8fc6a7777ab015d8c67e45efaf7cfc97e43da61d6b4d90525f27d163df2c   3 months ago        263MB
ubuntu                                          14.04               sha256:2c5e00d77a67934d5e39493477f262b878f127b9c01b491f06d8f06f78819578   5 months ago        188MB
docker.elastic.co/elasticsearch/elasticsearch   5.6.2               sha256:59b11c02b218c87592dd4b29b7f6e837901a8ea8771dc6ef329ca8aed832fe3c   2 years ago         657MB
	`)
	image1 := "techknowlogick/xgo:latest"
	match1, _ := compareOutAndImage(out1, image1)
	if !match1 {
		t.Errorf(
			`
image not found, expect found
docker images output:
%s
image: %s`, out1, image1)
	}

	out2 := []byte(`
REPOSITORY                                      TAG                 IMAGE ID                                                                  CREATED             SIZE
techknowlogick/xgo                              latest              sha256:9fa22a0bbbfaff02eb2abb3f593ca2f27151d0cba5e8ff2a2c6ab87337de45ae   3 weeks ago         6.14GB
techknowlogick/xgo                              1.13.2              sha256:60706f00806bb20e30b717e523433d01c94f27db3c2bf653d0e2891e3330f554   3 weeks ago         6.14GB
techknowlogick/xgo                              1.12.11             sha256:f3aa1cb1de1aa7aecb57883b4027d04a1ea192c9be266ed301b9825e6cc87aa8   3 weeks ago         6.14GB
nginx                                           latest              sha256:f949e7d76d63befffc8eec2cbf8a6f509780f96fb3bacbdc24068d594a77f043   3 weeks ago         126MB
ubuntu                                          latest              sha256:2ca708c1c9ccc509b070f226d6e4712604e0c48b55d7d8f5adc9be4a4d36029a   4 weeks ago         64.2MB
lmenezes/cerebro                                latest              sha256:419a8fc6a7777ab015d8c67e45efaf7cfc97e43da61d6b4d90525f27d163df2c   3 months ago        263MB
ubuntu                                          14.04               sha256:2c5e00d77a67934d5e39493477f262b878f127b9c01b491f06d8f06f78819578   5 months ago        188MB
docker.elastic.co/elasticsearch/elasticsearch   5.6.2               sha256:59b11c02b218c87592dd4b29b7f6e837901a8ea8771dc6ef329ca8aed832fe3c   2 years ago         657MB
	`)
	image2 := "techknowlogick/xgo:1.13.2"
	match2, _ := compareOutAndImage(out2, image2)
	if !match2 {
		t.Errorf(
			`
image not found, expect found
docker images output:
%s
image: %s`, out2, image2)
	}
	out3 := []byte(`
REPOSITORY                                      TAG                 IMAGE ID                                                                  CREATED             SIZE
techknowlogick/xgo                              latest              sha256:9fa22a0bbbfaff02eb2abb3f593ca2f27151d0cba5e8ff2a2c6ab87337de45ae   3 weeks ago         6.14GB
techknowlogick/xgo                              1.12.11             sha256:f3aa1cb1de1aa7aecb57883b4027d04a1ea192c9be266ed301b9825e6cc87aa8   3 weeks ago         6.14GB
nginx                                           latest              sha256:f949e7d76d63befffc8eec2cbf8a6f509780f96fb3bacbdc24068d594a77f043   3 weeks ago         126MB
ubuntu                                          latest              sha256:2ca708c1c9ccc509b070f226d6e4712604e0c48b55d7d8f5adc9be4a4d36029a   4 weeks ago         64.2MB
lmenezes/cerebro                                latest              sha256:419a8fc6a7777ab015d8c67e45efaf7cfc97e43da61d6b4d90525f27d163df2c   3 months ago        263MB
ubuntu                                          14.04               sha256:2c5e00d77a67934d5e39493477f262b878f127b9c01b491f06d8f06f78819578   5 months ago        188MB
docker.elastic.co/elasticsearch/elasticsearch   5.6.2               sha256:59b11c02b218c87592dd4b29b7f6e837901a8ea8771dc6ef329ca8aed832fe3c   2 years ago         657MB
	`)
	image3 := "techknowlogick/xgo:1.13.2"
	match3, _ := compareOutAndImage(out3, image3)
	if match3 {
		t.Errorf(
			`
image found, expect not found
docker images output:
%s
image: %s`, out3, image3)
	}
}
