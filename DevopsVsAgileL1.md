# DevOps vs Agile — L1 Assignment

---

## Concept Task: Comparison Table

| # | Aspect | Agile | DevOps |
|---|--------|-------|--------|
| 1 | **Focus** | Software development — breaking work into sprints, delivering features fast | Deployment & operations — automating release, monitoring, and infrastructure |
| 2 | **Team Scope** | Developers + testers (dev side only) | Developers + operations + infra teams together (end-to-end) |
| 3 | **Goal** | Deliver working software in short iterations (2-week sprints) | Deliver that software to production reliably, fast, and continuously (CI/CD) |

> **One-line memory hook:** Agile fixes *how you build* it. DevOps fixes *how you ship and run* it.

---

## Hands-on Task: Bottleneck Scenarios

### Scenario 1 — Communication Bottleneck (Agile solves this)

**Situation:**  
A product team is building an e-commerce site. The client wants a "Buy Now" button added. The business analyst writes a 10-page requirement doc, hands it to developers after 3 weeks, and only in the review meeting does the client say — *"That's not what I meant."*  
Time wasted: 3 weeks.

**How Agile Solves It:**  
The team breaks the feature into a 2-day user story: *"As a user, I want to buy in one click."* Developers demo a working prototype to the client on Day 3. Feedback is instant. Changes happen in the same sprint. No more 10-page docs floating between siloed teams.

---

### Scenario 2 — Deployment Bottleneck (DevOps solves this)

**Situation:**  
The same e-commerce team finishes a feature sprint. Now they hand the code to the operations team to deploy. The ops team says *"We need 2 weeks to test, configure servers, and release."*  
Sprint velocity is high, but production releases happen once a month — and they're always risky.

**How DevOps Solves It:**  
A CI/CD pipeline (Jenkins) automatically builds and tests the code on every commit. If tests pass, it deploys to production automatically. What took 2 weeks now takes 20 minutes. Operations is no longer a bottleneck — it's automated.
