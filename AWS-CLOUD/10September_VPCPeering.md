# Batch 18 — AWS Cloud Running Notes: 10 September 2026

**Topic: VPC Peering**

Friends, yesterday we built a VPC with its own subnets, route tables, and Internet Gateway. Today we connect **two separate VPCs together**, privately, using **VPC Peering** — the first of three networking topics today (IP addressing and Security Groups follow in their own files).

---

## 1. What is VPC Peering?

- VPC Peering is a networking connection between **two VPCs**.
- It lets resources in one VPC talk to resources in another VPC using **private IP addresses**.
- No public IPs, no internet involved — traffic stays entirely on AWS's own network.

**Example:**
```
VPC-A: 10.0.0.0/16          VPC-B: 20.0.0.0/16
EC2-A: 10.0.1.10   ----->    EC2-B: 20.0.1.10
                 (private IP, via peering)
```

**Easy memory trick:** VPC Peering → a private bridge between two VPCs.

---

## 2. Why use VPC Peering?

- Used whenever **two VPCs need to talk privately**.
- Typical split: one VPC for the application, a separate VPC for the database.

**Real-time DevOps example:**
```
VPC-A (App)  CIDR 10.0.0.0/16 — App EC2: 10.0.1.10
VPC-B (DB)   CIDR 20.0.0.0/16 — DB EC2:  20.0.1.20

App connects to MySQL: 10.0.1.10 ---> 20.0.1.20:3306 (via peering)
```
This is how a company keeps its application and database on separate, isolated VPCs (maybe managed by different teams) while still letting the app reach the database privately.

---

## 3. Important requirement — CIDR must not overlap

- **Correct:** VPC-A `10.0.0.0/16`, VPC-B `20.0.0.0/16` — different CIDRs, peering possible.
- **Incorrect:** VPC-A `10.0.0.0/16`, VPC-B `10.0.0.0/16` — same/overlapping CIDR, peering **not allowed**.

**Easy memory trick:** Different VPCs + different CIDRs = peering possible.

---

## 4. How VPC Peering works — 3 steps

1. **Create** the VPC Peering Connection (from VPC-A, targeting VPC-B).
2. **Accept** the peering connection (the owner of VPC-B must accept it).
3. **Update route tables** on both sides — see below, this step is easy to forget.

---

## 5. Route tables — required, not automatic

- Creating a VPC Peering connection does **NOT** automatically configure routing.
- You must manually add a route on **both** sides.

**Example:**
```
VPC-A route table: destination 20.0.0.0/16 → target pcx-12345
VPC-B route table: destination 10.0.0.0/16 → target pcx-12345
```
`pcx-12345` is the VPC Peering Connection ID.

**Easy memory trick:** Peering = the connection. Route table = the direction traffic actually flows.

---

## 6. Security Group and Network ACL also matter

- The route table only allows the network **path** to exist — the **Security Group** must separately allow the actual traffic.
- **Network ACLs** (subnet-level firewall) can also block traffic even if the route table and Security Group are correct.

**Example — database Security Group allowing the app's traffic:**
```
Type: MySQL
Port: 3306
Source: 10.0.0.0/16
```

**Easy memory trick:** VPC Peering + Route Table + Security Group = actual communication. Miss any one, and it won't work.

---

## 7. Same Region, different Regions, and different AWS accounts

- **Same Region peering:** both VPCs in the same AWS Region (e.g. both in `ap-south-1`) — the simple, common case.
- **Inter-Region peering:** VPCs in different Regions (e.g. `ap-south-1` and `us-east-1`) can also be peered.
- **Cross-account peering:** VPCs belonging to **different AWS accounts** can be peered too — the other account's owner must accept the request.

---

## 8. VPC Peering is NOT transitive

⚠️ **Very commonly tested point:** if VPC-A is peered with VPC-B, and VPC-B is peered with VPC-C, **VPC-A cannot automatically reach VPC-C**. Peering is a **direct** connection only — A cannot use B as a router to reach C.

**Easy memory trick:** VPC Peering = direct connection only, never transitive.

---

## 9. VPC Peering vs Internet Gateway vs NAT Gateway vs Transit Gateway

| | Connects | Used for |
|---|---|---|
| Internet Gateway | VPC ↔ Internet | Public internet access |
| NAT Gateway | Private subnet ↔ Internet | Outbound-only internet access for private subnets |
| VPC Peering | VPC ↔ VPC | Direct, private connection between two VPCs |
| Transit Gateway | Many VPCs ↔ each other | A centralized hub, once you have too many VPCs for peering to stay manageable |

**Easy memory trick:** Few VPCs → VPC Peering is fine. Many VPCs → consider a Transit Gateway instead, so you're not managing a tangle of individual peering connections.

---

## 10. Basic AWS CLI

```bash
# Create VPC Peering
aws ec2 create-vpc-peering-connection \
  --vpc-id vpc-AAAA \
  --peer-vpc-id vpc-BBBB

# Accept it
aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id pcx-123456

# Add the route
aws ec2 create-route \
  --route-table-id rtb-AAAA \
  --destination-cidr-block 20.0.0.0/16 \
  --vpc-peering-connection-id pcx-123456
```

**Easy memory trick:** Create → Accept → Route → Security Group. Miss a step, and the connection looks fine but traffic still won't flow.

---

## 11. Terraform example

```hcl
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc_a.id
  peer_vpc_id = aws_vpc.vpc_b.id
  auto_accept = true

  tags = {
    Name = "vpc-a-to-vpc-b"
  }
}

resource "aws_route" "vpc_a_to_b" {
  route_table_id            = aws_route_table.vpc_a.id
  destination_cidr_block    = "20.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
```

---

## 12. Real-time architecture

```
                AWS
                 |
        +--------+--------+
        |                 |
      VPC-A              VPC-B
  10.0.0.0/16        20.0.0.0/16
        |                 |
     APP EC2           DB EC2
    10.0.1.10         20.0.1.20
        |                 |
        +---- PEERING ----+

App connects: 10.0.1.10 ---> 20.0.1.20:3306

Required together: VPC Peering + Route Tables + Security Groups
```

---

## 13. Troubleshooting — "VPC-A can't reach VPC-B"

1. Check the peering connection's status (is it actually **active**?).
2. Check the CIDR ranges (do they overlap?).
3. Check VPC-A's route table.
4. Check VPC-B's route table.
5. Check the Security Group.
6. Check the Network ACL.
7. Check the application/service port itself.

**Testing a specific port:**
```
$ nc -vz 20.0.1.20 3306
Connection to 20.0.1.20 3306 port [tcp/mysql] succeeded!
```
This confirms whether TCP port 3306 is actually reachable, isolating whether the problem is networking or the application itself.

---

## Quick Recap Table

| Concept | One-line meaning | Real-time (DevOps) example |
|---|---|---|
| VPC Peering | A private, direct connection between two VPCs | Connecting an App VPC to a separate DB VPC |
| Non-overlapping CIDR | A hard requirement for peering | `10.0.0.0/16` ↔ `20.0.0.0/16`, not the same range twice |
| Route table update | Required manually, not automatic | `20.0.0.0/16 → pcx-12345` on VPC-A's route table |
| Not transitive | A ↔ B and B ↔ C does not mean A ↔ C | Each pair of VPCs needs its own peering connection |
| Same/different Region, different account | All supported | An App VPC in one account peered to a DB VPC in another |
| `nc -vz <ip> <port>` | Tests whether a specific port is reachable | Confirming port 3306 is open across a peering connection |
