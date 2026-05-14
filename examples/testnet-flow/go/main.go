// Run the aptos-ts-sdk Testnet confidential-asset demo with the same environment variables
// as examples/bun-confidential-testnet/confidential-testnet.ts (this process only execs pnpm/tsx).
package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
)

func main() {
	flowDir, err := os.Getwd()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	// Expect `go run .` from examples/testnet-flow/go — bindings repo root is ../../..
	bindingsRoot, err := filepath.Abs(filepath.Join(flowDir, "..", "..", ".."))
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	sdkRoot := os.Getenv("APTOS_TS_SDK_ROOT")
	if sdkRoot == "" {
		sdkRoot = filepath.Join(filepath.Dir(bindingsRoot), "aptos-ts-sdk")
	}
	sdkRoot, err = filepath.Abs(sdkRoot)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	target := filepath.Join(sdkRoot, "examples", "bun-confidential-testnet")
	if st, err := os.Stat(target); err != nil || !st.IsDir() {
		fmt.Fprintf(os.Stderr, "error: %s not found. Set APTOS_TS_SDK_ROOT.\n", target)
		os.Exit(1)
	}

	cmd := exec.Command("pnpm", "exec", "tsx", "confidential-testnet.ts")
	cmd.Dir = target
	cmd.Env = os.Environ()
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
