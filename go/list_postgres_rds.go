package main

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	// Check if AWS CLI is installed
	awsPath, err := exec.LookPath("aws")
	if err != nil {
		fmt.Println("ERROR: The aws binary does not exist or is not executable.")
		fmt.Println("Please install AWS CLI and ensure it is in your PATH.")
		os.Exit(1)
	}

	// Prepare the command to fetch all RDS instances with PostgreSQL as the database engine
	cmd := exec.Command(awsPath, "rds", "describe-db-instances",
		"--query", "DBInstances[?Engine=='postgres'].[DBInstanceIdentifier, DBInstanceClass, Engine, EngineVersion, DBInstanceStatus, MultiAZ]",
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

	rdsInstances := strings.TrimSpace(out.String())

	// Check if any PostgreSQL RDS instances are found
	if rdsInstances == "" {
		fmt.Println("No PostgreSQL RDS instances found.")
	} else {
		fmt.Println("PostgreSQL RDS Instances:")
		fmt.Println(rdsInstances)
	}
}
