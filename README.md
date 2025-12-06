<p align="center">
  <a href="https://github.com/txr-ai/txr">
    <img src="https://github.com/txr-ai/txr/blob/main/txr_image.png" alt="TxR Logo" width="50%">
  </a>
</p>

<h1 align="center">Transactional Reasoning (TxR) — Evaluation Bundle</h1>

<p align="center">
  <a href="https://github.com/txr-ai/txr">github.com/txr-ai/txr</a>
</p>

---

## 1. Overview

**Transactional Reasoning (TxR)** is a new operator class for Artificial Intelligence and Machine Intelligence. It is a core component to the Transactional Neural Reasoning Machine Intelligence Framework.   
TxR introduces **Monotone-Confidence (MCC)**, **Dual-Manifold Orientation**,**Multi-Pillar Governance** and **Reasoning Intelligence for Machines**.  

Unlike prior classes (search, optimization, inference, learning), TxR enforces at runtime:

- Confidence must be monotone non-decreasing (MCC).  
- Actions are bounded between *Ideal* and *Adversarial* manifolds.  
- Every decision is evidence-gated with auditable logs.  

**Result:** A series of microtransactions, reasoning through a series of pillars "SENSE, ASSESS, DECIDE, ACTION, VERIFY" under a per transaction, elected governance and enforcement logic that is reviewed upon completion and satisfied in quorum. Pass or fail is determined by: "Was that action non-regressive, does it position the work closer to the desired state/desired outcome, and was the work completed successfully, within boundaries and reported on via receipts.

---

## 2. Why It Matters

Traditional generation uses the prompt to solve the next likely token in order to generate output. TxR reasons its way via a dynamic multi-pillar governance model that is integrity and confidence-bound between dual manifolds (ideal & adversarial) with a monotone confidence-constraint to enforce non-regressive actions only. 

- Non Regressive under MCC  
- Logs every state delta (pre vs. post, predicted vs. observed) and reassesses progress on a per step basis. 
- Dynamic operator ownership based on conditions & feedback  
- Linear moves for fast paths, expanded logic when higher confidence required or confidence erodes  

**Practical Value**  
- Long-running inference: chunked with no regressions  
- Reduced hallucinations: bounded by Ideal/Adversarial orientation 
- Focused Output: Multiple Gates, each responsible for Logic ownership and confidence of progress 
- Efficiency: fewer wasted tokens and GPU cycles  
- Governance: audit-grade decision trail at every step  

---

## 3. Novelty Criteria

TxR meets the academic test for a distinct operator class:

- [x] **Distinct mechanism** beyond search, optimization, inference, learning  
- [x] **Unique invariants**: MCC, manifold orientation, evidence gating  
- [x] **General applicability**: not a niche hack, works in interactive AI, inference, and governance  
- [x] **Formal outputs**: logs, ablations, conformance results 


---
## 4. Bundle Contents
All folders in bundles.zip are unpacked in the repo root, running the script will  overwrite the unpacked folders and perform a checksum verification and spot check HMAC Signatures printing the results in the terminal. The password is tXr


When you unpack `tests/chess_tests.zip`, you get:

- `logs_pass/` – MCC-satisfied runs (e.g., Morphy’s Opera Game)  
- `logs_fail/` – Injected violations caught by Oversight  
- `logs_no_verify/` – Runs without signature verification  
- `out_pass/`, `out_fail/`, `out_ablation/` – Verdicts + summaries  
- `SHA256SUMS.txt` – Integrity manifest  
- `.sig` files – HMAC-SHA256 signatures for JSONL logs  
- `bundle.zip` – Zipped archive for replication  

---

## 5. Example Logs

**Illegal Move Catch**
```json
"pre_state": {"C":0.72,"J":0.66,"O":0.63,"OIS":0.32},
"post_state": {"C":0.74,"J":0.72,"O":0.64,"OIS":0.34},
"predictions": {"dC":0.02,"dJ":0.06,"dO":0.01,"dOIS":0.02},
"gates": {"passed":["MCC"]}
```

**Planner Move**
```json
"pre_state": {"C":0.60,"J":0.70,"O":0.63,"OIS":0.20},
"post_state": {"C":0.62,"J":0.84,"O":0.62,"OIS":0.22},
"predictions": {"dC":0.02,"dJ":0.14,"dO":-0.01,"dOIS":0.02}
```

---

## 6. Running the Suite

**Install requirements**
```bash
sudo apt-get update
sudo apt-get install -y unzip p7zip-full openssl coreutils xmlstarlet
# or: sudo apt-get install -y libxml2-utils
```

**Run**
```bash
chmod +x unpack.sh
./unpack.sh
```

This will:  
- Unpack `bundle.zip`  
- Validate checksums and signatures  
- Print conformance results  

**Quick check**
```bash
cat out_pass/summary.csv
```
**Verify Checksums Without Unpacking**

in directory root:
```bash
sha256sum -c SHA256SUMS.txt
```


---

## 7. License & Legal Notice

- **License:** [Creative Commons BY-ND 4.0](https://creativecommons.org/licenses/by-nd/4.0/)  
  (Attribution Required)    
- **Contact:** [Joshua Williamson](https://www.linkedin.com/in/joshuabrint)  
  Email: joshua@bridger.systems  

---


## 9. Disputes

- You are free to challenge methodology or novelty.  
- Logs and bundles are open for independent replication/review.  
- Patent-protected logic is **not disclosed** here.  



---

Thank you for your time and attention in reviewing this claim for Transactional Reasoning (TxR). Updates will be posted as submissions are posted for review. 
