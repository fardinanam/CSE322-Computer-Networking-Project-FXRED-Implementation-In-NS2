#!/usr/bin/bash

# Baseline parameters
pktspersec=200
nn=40
nf=20

# ns file
nsFile="simulation.tcl"

# awk file
awkFile="parse.awk"

# Output files
resultFiles=("red.out" "fxred.out")

# echo "Area Size,Number of Nodes, Number of Flows" > $resultFile
# Initialize the output file
for (( k=0; k<${#resultFiles[@]}; k++ )); do
    resultFile=${resultFiles[$k]}

    true > "$resultFile"

    # Vary packets per sec and show results
    echo "=================" >> "$resultFile"
    echo "varying packets per sec" >> "$resultFile"
    for i in {1..5}; do  
        val=$((i*100))
        
        echo "---------------" >> "$resultFile"
        echo "Packets Per Sec: $val" >> "$resultFile"

        ns $nsFile $k $nn $nf $val 
        awk -f $awkFile < trace.tr >> "$resultFile"
    done

    # Vary number of nodes and show results
    echo "=======================" >> "$resultFile"
    echo "varying number of nodes" >> "$resultFile"
    for i in {1..5}; do  
        val=$((i*20))
        
        echo "---------------------" >> "$resultFile"
        echo "Number of Nodes: $val" >> "$resultFile"

        ns $nsFile $k $val $nf $pktspersec
        awk -f $awkFile < trace.tr >> "$resultFile"
    done

    # Vary number of flows and show results
    echo "=========================" >> "$resultFile"
    echo "varying number of flows" >> "$resultFile"
    for i in {1..5}; do
        val=$((i*10))
        
        echo "---------------------" >> "$resultFile"
        echo "Number of Flows: $val" >> "$resultFile"
        
        ns $nsFile $k $nn $val $pktspersec
        awk -f $awkFile < trace.tr >> "$resultFile"
    done

    echo "=========================" >> "$resultFile"
done
# Generate the graphs using python script
python3 graphGenerator.py "${resultFiles[0]}" "${resultFiles[1]}" || echo "Error: could not generate graphs"