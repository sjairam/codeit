package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	awsPath, err := exec.LookPath("aws")
	if err != nil {
		fmt.Println("ERROR: The aws binary does not exist.")
		fmt.Println("FIX: Please install AWS CLI and ensure it is in your PATH.")
		os.Exit(1)
	}

	// Prepare the command to list all load balancers filtered by type 'application'
	cmd := exec.Command(awsPath, "elbv2", "describe-load-balancers",
		"--query", "LoadBalancers[?Type=='application'].{Name:LoadBalancerName, ARN:LoadBalancerArn}",
		"--output", "text",
		"--output", "table")

	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = os.Stderr

	// Execute the command and capture its output
	err = cmd.Run()
	if err != nil {
		fmt.Printf("ERROR: %v\n", err)
		os.Exit(1)
	}

	loadBalancers := strings.TrimSpace(out.String())

	// Check if there are any ALBs found
	if loadBalancers == "" {
		fmt.Println("No Application Load Balancers found.")
	} else {
		fmt.Println("Application Load Balancers:")
		fmt.Println(loadBalancers)
	}
}
