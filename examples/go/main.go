package main

import (
	"fmt"
	"os"

	"github.com/aptos-labs/confidential-asset-bindings/bindings/go/aptosconfidential"
)

func main() {
	ok, err := aptosconfidential.BatchVerifyProof(
		[]byte{0x01},
		make([]byte, 32),
		pad32(1),
		pad32(1),
		32,
	)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	fmt.Println("verify (expected false):", ok)
}

func pad32(v byte) []byte {
	b := make([]byte, 32)
	b[0] = v
	return b
}
