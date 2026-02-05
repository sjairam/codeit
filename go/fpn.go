package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const timeLayout = "2006-01-02 15:04:05"

func printHelp() {
	helpText := `List all pods running on a given Kubernetes node across all namespaces.

Usage:
  find-pods-node <node-name>

Arguments:
  node-name    Name of the Kubernetes node to list pods for

Options:
  -h, --help   Show this help message

Examples:
  find-pods-node ip-10-0-1-42.us-east-2.compute.internal
  find-pods-node my-worker-node-01

Requirements:
  kubectl must be installed and configured for your cluster.`

	fmt.Println(helpText)
}

func main() {
	// Ensure kubectl exists
	kubectlPath, err := exec.LookPath("kubectl")
	if err != nil {
		fmt.Println("Error: kubectl is not installed or not in PATH")
		os.Exit(1)
	}

	// Handle help flags
	if len(os.Args) > 1 {
		switch os.Args[1] {
		case "-h", "--help", "help":
			printHelp()
			return
		}
	}

	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, "Usage: %s <node-name>\n", filepath.Base(os.Args[0]))
		fmt.Fprintf(os.Stderr, "Run '%s --help' for more information.\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}

	nodeName := os.Args[1]
	scriptName := filepath.Base(os.Args[0])

	fmt.Printf("=== %s - Node: %s ===\n\n", scriptName, nodeName)

	startTime := time.Now()
	startTimeStr := startTime.Format(timeLayout)

	// First: list pods on the given node (streaming directly to stdout)
	listCmd := exec.Command(
		kubectlPath,
		"get", "pods",
		"--all-namespaces",
		"-o", "wide",
		"--field-selector", fmt.Sprintf("spec.nodeName=%s", nodeName),
	)
	listCmd.Stdout = os.Stdout
	listCmd.Stderr = os.Stderr

	if err := listCmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error running kubectl: %v\n", err)
		os.Exit(1)
	}

	// Second: count pods on the given node (excluding header)
	var buf bytes.Buffer
	countCmd := exec.Command(
		kubectlPath,
		"get", "pods",
		"--all-namespaces",
		"-o", "wide",
		"--field-selector", fmt.Sprintf("spec.nodeName=%s", nodeName),
		"--no-headers",
	)
	countCmd.Stdout = &buf
	countCmd.Stderr = os.Stderr

	if err := countCmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error running kubectl for count: %v\n", err)
		os.Exit(1)
	}

	podCount := 0
	scanner := bufio.NewScanner(bytes.NewReader(buf.Bytes()))
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line != "" {
			podCount++
		}
	}
	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "Error reading kubectl output: %v\n", err)
		os.Exit(1)
	}

	endTime := time.Now()
	endTimeStr := endTime.Format(timeLayout)
	elapsedSeconds := int(endTime.Sub(startTime).Seconds())

	// Summary table: script, start time, end time, pod count
	fmt.Printf("\n")
	fmt.Printf("%-20s  %-20s  %-20s  %-14s  %s\n", "SCRIPT", "START TIME", "END TIME", "DURATION (s)", "POD COUNT")
	fmt.Printf("%-20s  %-20s  %-20s  %-14s  %s\n", "--------------------", "--------------------", "--------------------", "--------------", "----------")
	fmt.Printf("%-20s  %-20s  %-20s  %-14d  %d\n", scriptName, startTimeStr, endTimeStr, elapsedSeconds, podCount)
}
