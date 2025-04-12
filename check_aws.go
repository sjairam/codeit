package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
)

func main() {
	// Define command-line flags
	checkType := flag.String("check", "all", "Type of check to perform (install, config, version, all)")
	flag.Parse()

	switch *checkType {
	case "install":
		checkAWSInstallation()
	case "config":
		checkAWSConfigured()
	case "version":
		checkAWSVersion()
	case "all":
		checkAWSInstallation()
		checkAWSVersion()
		checkAWSConfigured()
	default:
		fmt.Printf("Invalid check type: %s\n", *checkType)
		fmt.Println("Valid options: install, config, version, all")
		os.Exit(1)
	}
}

func checkAWSInstallation() {
	_, err := exec.LookPath("aws")
	if err != nil {
		fmt.Println("❌ AWS CLI is not installed or not in PATH")
		fmt.Println("Install it from: https://aws.amazon.com/cli/")
		os.Exit(1)
	}
	fmt.Println("✅ AWS CLI is installed")
}

func checkAWSVersion() {
	cmd := exec.Command("aws", "--version")
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Printf("⚠️ Error checking AWS CLI version: %v\n", err)
		return
	}
	fmt.Printf("🔹 AWS CLI version: %s", output)
}

func checkAWSConfigured() {
	cmd := exec.Command("aws", "sts", "get-caller-identity")
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("❌ AWS is not configured or credentials are invalid")
		fmt.Println("Run 'aws configure' to set up your credentials")
		return
	}
	fmt.Println("✅ AWS is properly configured")
	fmt.Printf("🔹 Current identity: %s", output)
}
