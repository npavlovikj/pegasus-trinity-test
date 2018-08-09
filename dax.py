#!/usr/bin/python
import sys
import os

# Import the Python DAX library
os.sys.path.insert(0, "/usr/lib64/pegasus/python")
from Pegasus.DAX3 import *

dax = ADAG("pipeline")
base_dir = os.getcwd()

# create read_left input file
input_read_left = File("reads.left.5000.fa")
input_read_left.addPFN(PFN("file://" + base_dir + "/reads.left.5000.fa", "local-hcc"))
dax.addFile(input_read_left)

# create read_right input file
input_read_right = File("reads.right.5000.fa")
input_read_right.addPFN(PFN("file://" + base_dir + "/reads.right.5000.fa", "local-hcc"))
dax.addFile(input_read_right)



# Step 1 of the pipeline
# add executable for preprocessing
ex_preprocessing = Executable(namespace="dax", name="preprocessing", version="4.0", os="linux", arch="x86_64", installed=True)
ex_preprocessing.addPFN(PFN("/bin/ls", "local-hcc"))
dax.addExecutable(ex_preprocessing)
# add job for preprocessing
preprocessing = Job(namespace="dax", name=ex_preprocessing, version="4.0")
preprocessing.addArguments(base_dir)
dax.addJob(preprocessing)



# Step 2 of the pipeline
# add executable for Trinity
ex_trinity_run = Executable(namespace="dax", name="trinity_run", version="4.0", os="linux", arch="x86_64", installed=True)
ex_trinity_run.addPFN(PFN("file://" + base_dir + "/trinity.sh", "local-hcc"))
dax.addExecutable(ex_trinity_run)
# add job for Trinity, multiple for different kmers
trinity_run = []
k=25
for i in range(0,4):
    trinity_run.append(Job(namespace="dax", name=ex_trinity_run, version="4.0"))
    trinity_run[i].addArguments("--seqType","fa","--max_memory","2G","--left",input_read_left.name,"--right",input_read_right.name,"--SS_lib_type","RF","--KMER_SIZE","%d" %k,"--output","trinity_%d_out" %k)
    trinity_run[i].uses(input_read_left, link=Link.INPUT)
    trinity_run[i].uses(input_read_right, link=Link.INPUT)
    trinity_run[i].uses("trinity_%d_out/Trinity.fasta" %k, link=Link.OUTPUT)
    dax.addJob(trinity_run[i])
    
    dax.addDependency(Dependency(parent=preprocessing, child=trinity_run[i]))
    k = k + 2
 
list_of_output_transcripts = []
k=25
for i in range(0,4):
    f = File("trinity_%d_out/Trinity.fasta" %k)
    list_of_output_transcripts.append(f)
    k = k + 2



# Step 3 of the pipeline
# add executable to concatenate all Trinity.fasta files
ex_cat_transcripts = Executable(namespace="dax", name="cat_transcripts", version="4.0", os="linux", arch="x86_64", installed=True)
ex_cat_transcripts.addPFN(PFN("/bin/cat", "local-hcc"))
dax.addExecutable(ex_cat_transcripts)
# rename the final concatenated Trinity.fasta file
output_cat_transcripts = File("cat_Trinity_transcripts.fasta")
# add job to concatenate all Trinity.fasta files
cat_transcripts = Job(namespace="dax", name=ex_cat_transcripts, version="4.0")
cat_transcripts.addArguments(*list_of_output_transcripts)
for l in list_of_output_transcripts:
    cat_transcripts.uses(l, link=Link.INPUT)
cat_transcripts.setStdout(output_cat_transcripts)
cat_transcripts.uses(output_cat_transcripts, link=Link.OUTPUT, transfer=True, register=False)
dax.addFile(output_cat_transcripts)
dax.addJob(cat_transcripts)



# Add control-flow dependencies
for i in range(0,4):
    dax.addDependency(Dependency(parent=trinity_run[i], child=cat_transcripts))



# Write the DAX to stdout
dax.writeXML(sys.stdout)
