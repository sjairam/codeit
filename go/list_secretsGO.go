package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os/exec"
	"strings"
)

// Function to display help and options
func help() {
	fmt.Println("Displays IN PLAIN TEXT the Key-Value pairs for secrets in Secrets Manager")
	fmt.Println()
	fmt.Println("Syntax: go run list_secrets.go [-h|-s env/stack-secrets| -a]")
	fmt.Println("options:")
	fmt.Println("-h                     Print this message.")
	fmt.Println("-s env/stack-secrets   Prints just secrets for that stack.")
	fmt.Println("-a                     Prints all secrets in Secrets Manager (not advised).")
	fmt.Println()
}

// Function to check the availability of required binaries
func checkBinaries() {
	if _, err := exec.LookPath("aws"); err != nil {
		log.Fatalln("ERROR: The aws binary does not exist.", "FIX: Please ensure AWS CLI is installed and in your PATH.")
	}

	if _, err := exec.LookPath("jq"); err != nil {
		log.Fatalln("ERROR: The jq binary does not exist.", "FIX: Please ensure jq is installed and in your PATH.")
	}
}

// Function to list all secrets
func listAllSecrets() []string {
	cmd := exec.Command("aws", "secretsmanager", "list-secrets", "--query", "SecretList[*].Name", "--output", "text")
	output, err := cmd.Output()
	if err != nil {
		log.Fatalf("Error listing all secrets: %v\n", err)
	}
	secrets := strings.Fields(string(output))
	return secrets
}

// Function to describe a secret and get key-value pairs
func describeSecret(secretName string) {
	if secretName == "" {
		log.Fatalln("ERROR: Secret name not provided.")
	}
	cmd := exec.Command("aws", "secretsmanager", "get-secret-value", "--secret-id", secretName, "--query", "SecretString", "--output", "text")
	output, err := cmd.Output()
	if err != nil {
		log.Fatalf("Error describing secret: %v\n", err)
	}

	var secretData interface{}
	if err := json.Unmarshal(output, &secretData); err != nil {
		log.Fatalf("Error parsing secret JSON: %v\n", err)
	}

	fmt.Printf("Secret Name: %s\n", secretName)
	fmt.Println("Key-Value Pairs:")
	fmt.Printf("%v\n", secretData)
}

// Function to find whitespaces in secret values
func findWhitespaces(secretName string) {
	if secretName == "" {
		log.Fatalln("ERROR: Secret name not provided.")
	}
	cmd := exec.Command("aws", "secretsmanager", "get-secret-value", "--secret-id", secretName)
	output, err := cmd.Output()
	if err != nil {
		log.Fatalf("Error fetching secret for whitespace check: %v\n", err)
	}

	var result map[string]interface{}
	if err := json.Unmarshal(output, &result); err != nil {
		log.Fatalf("Error parsing JSON: %v\n", err)
	}
	secretString := result["SecretString"].(string)
	if strings.ContainsRune(secretString, ' ') || strings.ContainsRune(secretString, '\'') {
		fmt.Printf("Secret '%s': WHITESPACEs FOUND - check the output for leading or trailing spaces.\n", secretName)
	} else {
		fmt.Printf("Secret '%s': No whitespace found\n", secretName)
	}
}

func main() {
	helpFlag := flag.Bool("h", false, "Print help message.")
	allSecretsFlag := flag.Bool("a", false, "Print all secrets.")
	secretFlag := flag.String("s", "", "Specify stack secret name to print.")

	flag.Parse()

	if *helpFlag {
		help()
		return
	}

	checkBinaries()

	if *allSecretsFlag {
		fmt.Println("Listing all secrets:")
		secrets := listAllSecrets()
		for _, secret := range secrets {
			describeSecret(secret)
		}
	} else if *secretFlag != "" {
		describeSecret(*secretFlag)
		findWhitespaces(*secretFlag)
	} else {
		fmt.Println("Error: Missing required parameter.")
		help()
	}
}
