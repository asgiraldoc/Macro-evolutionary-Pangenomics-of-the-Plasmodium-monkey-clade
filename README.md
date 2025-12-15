# **Macro-evolutionary Pangenomics: A *Plasmodium* Case Study**

This repository documents a case study testing the capabilities of population-level pangenomics tools (**MUMento** and **PGGB**) in a macro-evolutionary context.

We analyzed the "monkey clade" of *Plasmodium*, focusing on the structural differences between species and assessing genome assembly quality.

## **Dataset**

The analysis includes **10 genomes** from the *Plasmodium* monkey clade:

* ***P. coatneyi*** (Hackeri): Used for assembly QC (comparison of V1 PacBio unpolished vs. V2 Hybrid polished).  
* ***P. knowlesi***: H , A1H1.  
* ***P. cynomolgi***: M.  
* ***P. vivax***: MHC087, PAM, W1, P01.  
* ***P. vivax***-like: SY43, SY56.

## **Tools Used**

1. **MUMento** (v1.3.4): For whole-genome alignment and synteny.  
2. **PGGB** (v0.7.2): For variation graph construction.

## **1. MUMento Analysis**

We utilized **MUMento** (v1.3.4) to identify maximal unique matches (MUMs) across the clade. This tool is generally used for intra-species pangenomes, but we adapted for inter-species comparison.

We ran mumemto allowing unique matches (-f 1) that appear in at least 2 genomes (-k 2). This `k` value is crucial for macro-evolutionary studies, as it allows for the identification of conserved regions without requiring them to be present in every single species (which would be too strict for this divergence level). All other parameters for assembly comparison remained at their default values.

To visualize the synteny, we used the viz module. We prepared a `filelist.txt` (listing file paths) and `labels.txt` (clean species names) for better readability. We utilized the `--mode` gapped option, which is better suited for distinct species comparisons than the default mode. 


### ***P. coatneyi*** **Assembly Comparison (V1 vs V2)**

We compared the 2016 PacBio-only assembly (V1; [Chien et al., 2016](https://doi.org/10.1128/genomeA.00883-16)) against our V2 update (polished with Illumina).
```
mumemto Pcoat*.fasta -o output/assemblies

mumemto viz -i output/assemblies   
    --filelist filelist.txt   
    --labels labels.txt   
    --mode gapped   
    --spacer 0.1   
    -o figures/assemblies.png
```

* **Results:** The alignment shows identical collinearity for most chromosomes (except corrections in Chr 12 and 14). However, we observe high "fragmentation" (variation) in the alignment. This is not structural variation but rather the massive correction of indels introduced by the polishing step. This confirms the qualitative superiority of the V2 assembly.
 
![Figure 1: Coatneyi Alignment](./figures/fig1.png)
*(Fig 1: High collinearity with indel-driven fragmentation)*

### **Clade-level Synteny**

We ran the all-vs-all comparison described in the workflow above across all species.

```
mumemto -f 1 -k 2 P*.fasta -o output/pangenome_f1_k2

mumemto viz -i output/pangenome_f1_k2   
    --filelist filelist.txt   
    --labels labels.txt   
    --mode gapped   
    --spacer 0.1   
    -o figures/pangenome_f1_k2.png
```
* **Results:** MUMento provided very granular synteny results, outperforming gene-centric tools like GENESPACE (R package). We were able to detect syntenic blocks in both intergenic and intragenic regions.

![Figure 2: Global Synteny](./figures/fig2.png)

*(Fig 2: Granular synteny across the clade)*

## **2. PGGB Analysis**

To test the capabilities of PGGB, we applied it in two distinct contexts: comparative assembly validation and the macro-evolutionary extraction of centromeric regions—loci typically difficult to resolve due to their GC content (5-7%) and repetitive motifs. Using *Bandage* and *seqkit* to visualize and annotate these results. 

### ***P. coatneyi*** **Assembly Comparison (V1 vs V2)**
We constructed a graph comparing the unpolished (V1) and polished (V2) assemblies to identify structural discrepancies. We adjusted the parameters to a 99% identity threshold (`-p 99`) and a 1kbp segment length (`-s 1000`)

* **Observation:** The graph forms many and very small "bubbles" (diverging paths) representing sequence variation. These bubbles are heavily concentrated in **intergenic and intronic regions**.  
* **Implication:** This indicates that the unpolished long-read assembly (V1) contains significant errors in low-complexity/repetitive regions, which are resolved in V2.

### **Global Pangenome (>85% Identity)**

For the macro-evolutionary analysis, we executed PGGB on a per-chromosome basis using the script `run_pggb.sh`. We adjusted the parameters to a 85% identity threshold (`-p 85`) and a 5kbp segment length (`-s 5000`); relaxing the identity threshold allows the graph to capture distant evolutionary relationships (deep homology), while a larger segment length prioritizes macro-synteny over micro-variation.

* **Core Genome:** Successfully identified conserved structural elements (centromere cores, RNA loci). Using `extract_centromeres.sh`, we leveraged ODGI to project the known centromere coordinates of the reference (*P. vivax* P01) onto the pangenome graph.
  
* **Variable Regions:** The "shell" of the pangenome is enriched with multigene families (host-parasite interaction), showing where the species diverge most.

[See slides PDF](https://www.google.com/search?q=./figures/pdf1.pdf)

## **Tool Comparison & Conclusions**

We evaluated both tools for their utility in macro-evolutionary studies:

### **MUMento**

* **Pros:** Very fast, easy to install, great for global synteny visualization.  
* **Cons:** Hard to extract raw data for downstream analysis; cannot easily identify unique paths (e.g. telomeres).

### **PGGB**

* **Pros:** Excellent data extraction, customizable, compatible with Bandage for graph viz, detects unique paths.  
* **Cons:** Computationally intensive (speed depends heavily on data size).

Summary:  
While these tools are designed for microevolutionary analysis, they are highly effective for inter-species analysis. MUMento is ideal for quick synteny checks, while PGGB is better suited for deep structural analysis and dissecting complex gene families.
