# Extract eplets and alleles from HLAmatchmaker v2

The sheets `5DRDQDPMatchingVs2.2.xlsb` and `4ABCEpletMatchingVs02prototype.xlsb`
are used.

1. Unlock the sheets by converting to `.xlsx` and running a VBA unlocking script
   found online.
2. Save as `.xltx` to be able to play with the sheet without destroying
   anything.
3. For every group of loci, cut all alleles into new sheets: one with
   ab-verified eplets and the other with other eplets (10 sheets for class II,
   two for class I). These sheets are referred to as the allele tables and the
   eplets therein as "table eplets".
   Make sure to remove invalid values such as `x` and `*`. Alleles will later be
   normalized for whitespace and casing.
4. Extract all eplets from the `Results` sheet into new sheets, separated by
   group of loci and verification status. Only one column is required so a
   single sheet will do with proper headings. Thes eplets are referred to as
   "algorithm eplets".
5. Use `pandas` to intersect all tables and assign the `table_only`,
   `algorithm_only` and `both` status values to all eplets.
   **TODO:** describe in detail.
6. Paste all allele names into the `EnterData` donor boxes, one row for each
   allele. Copy all eplets from `Results` into new sheets, separated by group of
   loci and verification status. This set of eplets contain a superset of eplets
   that are shared between table and algorithm -- not all of these are included
   in the algorithm, however.
   **TODO:** what to do with this information
7. Exclude any eplet not present in the final results. Put the cursor in the
   concatenation formula for verified and other eplets, respectively. Note which
   fields (now color-coded) that are not included and mark these eplets as
   `algorithm_only`. The eplet count includes all fields, but the
   eplet string concatenation does not! This information is provided in section
   *Lost in translation* below. Edit the final tables manually or use pandas.


## Lost in translation

The following eplets are not included in the final eplet string concatenation,
but are still counted as a mismatch.

### ABC

Verified: 166ES


### DR

Verified: 70D


### DQB1

Verified: 66DI, 84QL, 85VA, 87F, 182N


<!--

for ep in eplets:
    var table, algorithm: bool
    if ep in table_eplets[ep.locus][ep.status]:
        table = true
    if ep in algorithm_eplets[ep.locus][ep.status]:
        algorithm = true
    if table and algorithm:
        ep.status = stBoth
    elif table:
        ep.status = stTable
    elif algorithm:
        ep.status = stAlgorithm

-->