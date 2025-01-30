# remove scaffolds from ref genome

# run on hpc: bessemer
# srun --mem=16G --pty bash -i
# module load Anaconda3/2019.07
# source activate mypython
# python

import os
from Bio import SeqIO

wd = os.getcwd()
print(wd)

# load reference genome
ref_genome = SeqIO.parse(wd + "/ARS-UI_Ramb_v3.0/GCF_016772045.2/GCF_016772045.2_ARS-UI_Ramb_v3.0_genomic.fa", "fasta")

auto = 'NC' # define pattern for filer (autosomes + MT)
count = 0 # initialize a count
ref_seq_IDs = [] # collect refs for selected chromosomes + MT
ref_genome_auto = [] # filtered output

for record in ref_genome :
    if record.id.startswith(auto) :
        ref_genome_auto.append(record)
        ref_seq_IDs.append(record.id)
        count = count + 1


# open a new referenc genome file
# note, adjust path: ARS-UI_Ramb_v3.0 -> ARS-UI_Ramb_v3.0_sc_rmv
with open(wd + "/ARS-UI_Ramb_v3.0_sc_rmv/GCF_016772045.2/GCF_016772045.2_ARS-UI_Ramb_v3.0_genomic.fa", 'w') as output_file :
    SeqIO.write(ref_genome_auto, output_file, "fasta")

    
    


    
    







