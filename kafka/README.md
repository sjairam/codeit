# JBOD in Kafka with Kubernetes/Strimzi

## Table of Contents
1. [What is JBOD?](#what-is-jbod)
2. [Why Use JBOD with Kafka?](#why-use-jbod-with-kafka)
3. [JBOD vs. RAID](#jbod-vs-raid)
4. [Strimzi Kafka Cluster Example (YAML)](#strimzi-kafka-cluster-example-yaml)
5. [Non-Kubernetes Kafka Example](#non-kubernetes-kafka-example)
6. [Kubernetes Persistent Volume Claims for JBOD](#kubernetes-persistent-volume-claims-for-jbod)
7. [Pros and Cons of JBOD](#pros-and-cons-of-jbod)
8. [References](#references)

---

## What is JBOD?

**JBOD** stands for "Just a Bunch Of Disks." It is a storage architecture that uses multiple hard drives, but unlike RAID (Redundant Array of Independent Disks), JBOD does not combine the drives into a single logical unit for redundancy or performance. Each disk in a JBOD setup operates independently and is seen by the operating system as a separate drive.

**Key points:**
- Each disk can be used for different purposes or as separate storage volumes.
- No data redundancy or performance improvement as in RAID.
- If one disk fails, only the data on that disk is lost.
- Maximizes storage capacity without RAID complexity.

---

## Why Use JBOD with Kafka?

Kafka brokers can benefit from JBOD by spreading data across multiple disks, improving throughput and isolating failures to individual disks. In Kubernetes, Strimzi (the Kafka Operator) supports JBOD by allowing each broker pod to use multiple persistent volumes, each mapped to a different disk.

**Benefits in Kafka:**
- Higher throughput by parallelizing disk I/O.
- Isolates disk failures to only the data on the failed disk.
- Flexible storage management.

---

## JBOD vs. RAID

| Feature         | JBOD                        | RAID 0 (Striping)           |
|----------------|-----------------------------|-----------------------------|
| Disk Usage     | Independent disks           | Combined into one volume    |
| Redundancy     | None                        | None                        |
| Performance    | No improvement              | Improved (striping)         |
| Failure Impact | Only data on failed disk    | All data lost if any fail   |

**Example:**
- Disk 1: 500GB
- Disk 2: 1TB
- Disk 3: 2TB

With JBOD: System sees three separate drives (500GB, 1TB, 2TB).
With RAID 0: System sees a single 3.5TB volume, but all data is lost if any disk fails.

---

## Strimzi Kafka Cluster Example (YAML)

Below is an example of a Strimzi Kafka custom resource using JBOD storage:

```yaml
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    replicas: 3
    storage:
      type: jbod
      volumes:
        - id: 0
          type: persistent-claim
          size: 100Gi
          class: fast-disks
        - id: 1
          type: persistent-claim
          size: 200Gi
          class: slow-disks
  zookeeper:
    replicas: 3
    storage:
      type: persistent-claim
      size: 50Gi
  entityOperator:
    topicOperator: {}
    userOperator: {}
```

**Explanation:**
- Each Kafka broker uses two separate persistent volumes (100Gi and 200Gi).
- Each volume is independent; if one fails, only the data on that volume is affected.

---

## Non-Kubernetes Kafka Example

In a traditional Kafka `server.properties` file, you might configure JBOD like this:

```properties
log.dirs=/mnt/disk1,/mnt/disk2
```

**Explanation:**
- Kafka will store partitions across both `/mnt/disk1` and `/mnt/disk2`.
- Each directory is a separate disk (JBOD style).

---

## Kubernetes Persistent Volume Claims for JBOD

You might define multiple PVCs for a pod:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kafka-disk0
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kafka-disk1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 200Gi
```

And mount them in the container:

```yaml
volumeMounts:
  - name: kafka-disk0
    mountPath: /mnt/disk0
  - name: kafka-disk1
    mountPath: /mnt/disk1
```

**Explanation:**
- The application (Kafka) can use both `/mnt/disk0` and `/mnt/disk1` as independent storage locations.

---

## Pros and Cons of JBOD

**Pros:**
- Simple to set up and manage
- Maximizes available storage
- Isolates disk failures
- Flexible disk usage

**Cons:**
- No redundancy (data loss if a disk fails)
- No performance boost from striping
- Manual management of disk usage

---

## References
- [Strimzi Documentation: Storage](https://strimzi.io/docs/operators/latest/deploying.html#type-JBOD-reference)
- [Apache Kafka Documentation: Log Directories](https://kafka.apache.org/documentation/#brokerconfigs_log.dirs)
- [JBOD vs RAID](https://en.wikipedia.org/wiki/Non-RAID_drive_architectures)