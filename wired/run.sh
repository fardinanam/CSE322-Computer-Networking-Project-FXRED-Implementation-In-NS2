#!/usr/bin/bash

# Baseline parameters
pktspersec=200
nn=40
nf=20

# ns file
nsFile="simulation.tcl"

# awk file
awkFile="parse.awk"

# Output file
resultFile="results.out"

# echo "Area Size,Number of Nodes, Number of Flows" > $resultFile
# Initialize the output file
true > $resultFile

# Vary area size and show results
echo "=================" >> $resultFile
echo "varying packets per sec" >> $resultFile
for i in {1..5}; do  
    val=$((i*100))
    
    echo "---------------" >> $resultFile
    echo "Packets Per Sec: $val" >> $resultFile
   
    ns $nsFile $nn $nf $val 
    awk -f $awkFile < trace.tr >> $resultFile
done

# Vary number of nodes and show results
echo "=======================" >> $resultFile
echo "varying number of nodes" >> $resultFile
for i in {1..5}; do  
    val=$((i*20))
    
    echo "---------------------" >> $resultFile
    echo "Number of Nodes: $val" >> $resultFile

    ns $nsFile $val $nf $pktspersec
    awk -f $awkFile < trace.tr >> $resultFile
done

# Vary number of flows and show results
echo "=========================" >> $resultFile
echo "varying number of flows" >> $resultFile
for i in {1..5}; do
    val=$((i*10))
    
    echo "---------------------" >> $resultFile
    echo "Number of Flows: $val" >> $resultFile
    
    ns $nsFile $nn $val $pktspersec
    awk -f $awkFile < trace.tr >> $resultFile
done

echo "=========================" >> $resultFile
# Generate the graphs using python script
python3 graphGenerator.py $resultFile || echo "Error: could not generate graphs"