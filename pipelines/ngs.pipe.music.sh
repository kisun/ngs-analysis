#!/bin/bash
## 
## DESCRIPTION:   Run MuSiC tools
##
## USAGE:         ngs.pipe.music.sh bamlist maf_file roi_file out_dir ref.fasta
##
## OUTPUT:        MuSiC outputs
##

# Load analysis config
source $NGS_ANALYSIS_CONFIG

# Check correct usage
usage 5 $# $0

# Process input parameters
BAMLIST=$1
MAFFILE=$2
ROI_BED=$3
OUT_DIR=$4
REFEREN=$5

# Create temporary directory
TMPDIR=tmp.music.$RANDOM
mkdir $TMPDIR

#==[ Run MuSiC ]===============================================================================#

# Select genes from ensembl exons that are in maf file
grep -w -f <(cut -f1 $MAFFILE | sed 1d | sort -u | sed '/^$/d') $ROI_BED > $TMPDIR/roi.bed

# Compute bases covered
music.bmr.calc_covg.sh $BAMLIST $TMPDIR/roi.bed $OUT_DIR $REFEREN

# Compute background mutation rate
music.bmr.calc_bmr.sh $BAMLIST $MAFFILE $TMPDIR/roi.bed $OUT_DIR $REFEREN 1

# Compute per-gene mutation significance
# Fix erroreous counts where covered > mutations
#$PYTHON $NGS_ANALYSIS_DIR/modules/somatic/music_fix_gene_mrs.py $OUT_DIR/gene_mrs > $OUT_DIR/gene_mrs.fixed
#music.smg.sh $OUT_DIR/gene_mrs.fixed $OUT_DIR 20
music.smg.sh $OUT_DIR/gene_mrs $OUT_DIR 20

# Mutation relation test
music.mutation_relation.sh $BAMLIST $MAFFILE $OUT_DIR 200

exit

# Pfam - doesn't work
music.pfam.sh $MAFFILE $OUT_DIR

# Proximity analysis - need transcript name, aa changed, and nucleotide position columns in the maf file
music.proximity.sh $MAFFILE $OUT_DIR 10

# Compare variants against COSMIC and OMIM data - need transcript name and aa changed columns in the maf file
music.cosmic_omim.sh $MAFFILE $OUT_DIR


# bmr                   ...  Calculate gene coverages and background mutation rates.     
# clinical-correlation       Correlate phenotypic traits against mutated genes, or       
#                             against individual variants.                               
# cosmic-omim                Compare the amino acid changes of supplied mutations to     
#                             COSMIC and OMIM databases.                                 
# mutation-relation          Identify relationships of mutation concurrency or mutual    
#                             exclusivity in genes across cases.                         
# path-scan                  Find signifcantly mutated pathways in a cohort given a list 
#                             of somatic mutations.                                      
# pfam                       Add Pfam annotation to a MAF file.                          
# play                       Run the full suite of MuSiC tools sequentially.             
# proximity                  Perform a proximity analysis on a list of mutations.        
# smg                        Identify significantly mutated genes.                       
# survival                   Create survival plots and P-values for clinical and         
#                             mutational phenotypes.                