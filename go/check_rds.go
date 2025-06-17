package main

import (
	"context"
	"flag"
	"fmt"
	"os"
	"text/tabwriter"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/rds"
	"github.com/aws/aws-sdk-go-v2/service/rds/types"
)

func main() {
	// Command-line flags
	region := flag.String("region", "us-east-1", "AWS region to check")
	profile := flag.String("profile", "", "AWS profile to use")
	flag.Parse()

	// Initialize AWS configuration
	cfg, err := loadAWSConfig(*region, *profile)
	if err != nil {
		fmt.Printf("Failed to load AWS config: %v\n", err)
		os.Exit(1)
	}

	// Create RDS client
	client := rds.NewFromConfig(cfg)

	// Get all RDS instances
	instances, err := getRDSInstances(client)
	if err != nil {
		fmt.Printf("Failed to get RDS instances: %v\n", err)
		os.Exit(1)
	}

	// Display results in a table
	displayResults(instances)
}

func loadAWSConfig(region, profile string) (aws.Config, error) {
	ctx := context.Background()
	opts := []func(*config.LoadOptions) error{
		config.WithRegion(region),
	}

	if profile != "" {
		opts = append(opts, config.WithSharedConfigProfile(profile))
	}

	return config.LoadDefaultConfig(ctx, opts...)
}

func getRDSInstances(client *rds.Client) ([]types.DBInstance, error) {
	ctx := context.Background()
	var instances []types.DBInstance
	var marker *string

	for {
		resp, err := client.DescribeDBInstances(ctx, &rds.DescribeDBInstancesInput{
			Marker: marker,
		})
		if err != nil {
			return nil, err
		}

		instances = append(instances, resp.DBInstances...)

		if resp.Marker == nil {
			break
		}
		marker = resp.Marker
	}

	return instances, nil
}

func displayResults(instances []types.DBInstance) {
	if len(instances) == 0 {
		fmt.Println("No RDS instances found")
		return
	}

	w := tabwriter.NewWriter(os.Stdout, 0, 0, 2, ' ', 0)
	fmt.Fprintln(w, "INSTANCE ID\tENGINE\tSTATUS\tMULTI-AZ\tSTORAGE TYPE\tAVAILABILITY ZONE")

	for _, instance := range instances {
		multiAZ := "❌ Disabled"
		if instance.MultiAZ != nil && *instance.MultiAZ {
			multiAZ = "✅ Enabled"
		}

		az := "N/A"
		if instance.AvailabilityZone != nil {
			az = *instance.AvailabilityZone
		}

		fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\t%s\n",
			aws.ToString(instance.DBInstanceIdentifier),
			aws.ToString(instance.Engine),
			aws.ToString(instance.DBInstanceStatus),
			multiAZ,
			aws.ToString(instance.StorageType),
			az,
		)
	}
	w.Flush()
}
