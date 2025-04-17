package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

type EC2Instance struct {
	InstanceID string `json:"InstanceID"`
	Name       string `json:"Name"`
	State      string `json:"State"`
	PrivateIP  string `json:"PrivateIP"`
}

type EC2Reservation struct {
	Instances []EC2Instance `json:"Instances"`
}

type AWSOutput struct {
	Reservations []EC2Reservation `json:"Reservations"`
}

func main() {
	awsPath, err := exec.LookPath("aws")
	if err != nil {
		fmt.Println("ERROR: The aws binary does not exist.")
		fmt.Println("FIX: Please install AWS CLI and ensure it is in your PATH.")
		os.Exit(1)
	}

	fmt.Println("List all the running EC2 instances with their InstanceIDs, Names, States, and Private IPs")

	cmd := exec.Command(awsPath, "ec2", "describe-instances",
		"--filters", "Name=instance-state-name,Values=running",
		"--query", "Reservations[*].Instances[*].{InstanceID:InstanceId, Name:Tags[?Key==`Name`].Value | [0], State:State.Name, PrivateIP:PrivateIpAddress}",
		"--output", "json")

	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = os.Stderr

	err = cmd.Run()
	if err != nil {
		fmt.Printf("ERROR: %v\n", err)
		os.Exit(1)
	}

	var output AWSOutput
	err = json.NewDecoder(&out).Decode(&output)
	if err != nil {
		fmt.Printf("ERROR: Unable to parse JSON output: %v\n", err)
		os.Exit(1)
	}

	fmt.Printf("%-20s%-30s%-15s%-15s\n", "InstanceID", "Name", "State", "PrivateIP")
	fmt.Println(strings.Repeat("-", 80))

	for _, reservation := range output.Reservations {
		for _, instance := range reservation.Instances {
			fmt.Printf("%-20s%-30s%-15s%-15s\n", instance.InstanceID, instance.Name, instance.State, instance.PrivateIP)
		}
	}
}
