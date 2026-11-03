# Batch 18 — Terraform Running Notes: 3 November 2026

**Topic: Terraform Variable Data Type Constraints**

Friends, every variable we've written since `21October_Terraform_Variables.md` has used `type = string` or `type = number` without really dwelling on *why* that line matters. Today we slow down on exactly that — the full set of data types Terraform variables can be constrained to, from the simplest (`string`) to the one real projects reach for constantly (`list(object)`).

---

## 1. What are data type constraints?

- A **data type constraint** defines what *kind* of value a variable is allowed to accept.

| Type | Holds |
|---|---|
| `string` | Text only |
| `number` | Numbers only |
| `bool` | `true`/`false` only |
| `list` | Multiple values, in order |
| `map` | Key-value pairs |
| `object` | Structured data — several named fields together |

**Why they matter:**
- Avoid mistakes — catch the wrong *kind* of value before it ever reaches AWS.
- Make code predictable — anyone reading the variable knows exactly what shape of value to supply.
- Improve readability.

---

## 2. `string` — text

```hcl
variable "region" {
  type = string
}
```
```hcl
region = "us-east-1"
```
**Real-time use:** AWS region, resource names, environment name (`dev`/`prod`).

---

## 3. `number`

```hcl
variable "instance_count" {
  type = number
}
```
```hcl
instance_count = 3
```
**Real-time use:** number of servers, disk size (GB), Auto Scaling limits.

---

## 4. `bool` — true/false

```hcl
variable "enable_public_ip" {
  type = bool
}
```
```hcl
enable_public_ip = true
```
**Real-time use:** turning a feature on or off, enabling/disabling a public IP.

---

## 5. `list` — ordered values

```hcl
variable "subnet_cidrs" {
  type = list(string)
}
```
```hcl
subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]
```
**Real-time use:** subnets, Availability Zones, Security Group IDs — anything where you need several values of the *same* type, in a specific order.

---

## 6. `map` — key-value pairs

```hcl
variable "tags" {
  type = map(string)
}
```
```hcl
tags = {
  Name  = "web-server"
  Env   = "dev"
  owner = "madhu"
}
```
**Real-time use:** AWS resource tagging — this is exactly the shape every `tags = { Name = ... }` block we've written since `16October_Terraform_MiniProject.md` has actually been, just not formally typed as a variable until now.

---

## 7. `object` — structured data

```hcl
variable "server_config" {
  type = object({
    name  = string
    size  = string
    count = number
  })
}
```
```hcl
server_config = {
  name  = "web"
  size  = "t2.micro"
  count = 2
}
```
- Unlike a `map`, every field in an `object` can have its **own type** — `name` and `size` are strings, `count` is a number, all inside one variable.

**Real-time use:** a single server's configuration, database settings, an application's config — anywhere several *related but differently-typed* values travel together.

---

## 8. `list(object(...))` — the one that matters most in real projects

```hcl
variable "public_subnets" {
  description = "List of public subnets with CIDR and Availability Zone"
  type = list(object({
    cidr = string
    az   = string
  }))
}
```
```hcl
public_subnets = [
  { cidr = "10.0.1.0/24", az = "us-east-1a" },
  { cidr = "10.0.2.0/24", az = "us-east-1b" }
]
```
- A **list of objects** — each entry in the list is itself a small structured object with its own `cidr` and `az`.

**Real-time use:** multiple subnets across multiple Availability Zones, multiple servers each with their own settings, multiple environments — **this is called out as the most-used type in real projects**, because almost everything in AWS that comes in sets (subnets, instances, listener rules) needs exactly this "list of small structured things" shape.

---

## 9. Why type constraints are actually important

**1. Prevent errors:**
```hcl
instance_count = "three"   # ❌ wrong type — number expected, got a string
```

**2. Validate structure:**
```hcl
public_subnets = "10.0.1.0/24"   # ❌ wrong shape — a list was expected, not a single string
```

**3. Improve readability.**

**4. Help teamwork** — a teammate can look at a variable's declared type and immediately know the exact input format expected, without having to go read how it's used everywhere downstream.

---

## 10. Simple analogy

| Terraform type | Real-life example |
|---|---|
| `string` | A name |
| `number` | An age |
| `bool` | Yes or no |
| `list` | A shopping list |
| `map` | A dictionary (word → meaning) |
| `object` | A form with fields |
| `list(object)` | Multiple filled-out forms |

---

## 11. Final summary

- Terraform variables need the **correct data type** to behave predictably.
- Types ensure the input format is actually correct, not just "whatever happened to be typed in."
- Common types: `string`, `number`, `bool`, `list`, `map`, `object`.
- **Most used in real projects: `list(object)`.**

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| `string` | Text only | AWS region, resource names |
| `number` | Numeric values only | Instance count, disk size |
| `bool` | `true`/`false` only | Enable/disable a public IP |
| `list` | Multiple values, in order | A list of subnet CIDRs |
| `map` | Key-value pairs | Resource tags |
| `object` | Structured data, fields can have different types | One server's full configuration |
| `list(object)` | A list of structured objects — the most-used real-world type | Multiple subnets, each with its own CIDR + AZ |
| Why types matter | Catches the wrong kind/shape of value before it's ever applied | `instance_count = "three"` fails immediately |
