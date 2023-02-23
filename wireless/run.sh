#!/usr/bin/bash

# Baseline parameters
areaSize=500
pktspersec=200
nn=40
nf=20

# ns file
nsFile="simulation.tcl"

# awk file
awkFile="parse.awk"

# Output files
resultFiles=("red.out" "fxred.out")

runAwk() {
    text=$1
    redType=$2
    areaSize=$3
    nn=$4
    nf=$5
    pktspersec=$6
    resultFile=$7
        
    echo "---------------" >> "$resultFile"
    echo "$text" >> "$resultFile"

    ns $nsFile "$redType" "$areaSize" "$nn" "$nf" "$pktspersec" 
    awk -f $awkFile trace.tr >> "$resultFile" || exit 1
}

# echo "Area Size,Number of Nodes, Number of Flows" > $resultFile
# Initialize the output file
for (( k=0; k<${#resultFiles[@]}; k++ )); do
    resultFile=${resultFiles[$k]}

    true > "$resultFile"

    # Vary area size and show results
    echo "=================" >> "$resultFile"
    echo "varying area size" >> "$resultFile"
    for i in {1..5}; do 
        val=$((i*250)) 
        runAwk "Area Size: $val" "$k" "$val" "$nn" "$nf" "$pktspersec" "$resultFile"
    done

    # Vary packets per sec and show results
    echo "=================" >> "$resultFile"
    echo "varying packets per sec" >> "$resultFile"
    for i in {1..5}; do  
        val=$((i*100))
        runAwk "Packets per sec: $val" "$k" "$areaSize" "$nn" "$nf" "$val" "$resultFile"
    done

    # Vary number of nodes and show results
    echo "=======================" >> "$resultFile"
    echo "varying number of nodes" >> "$resultFile"
    for i in {1..5}; do 
        val=$((i*20)) 
        runAwk "Number of Nodes: $val" "$k" "$areaSize" "$val" "$nf" "$pktspersec" "$resultFile"
    done

    # Vary number of flows and show results
    echo "=========================" >> "$resultFile"
    echo "varying number of flows" >> "$resultFile"
    for i in {1..5}; do
        val=$((i*10))
        runAwk "Number of Flows: $val" "$k" "$areaSize" "$nn" "$val" "$pktspersec" "$resultFile"
    done

    echo "=========================" >> "$resultFile"
done
# Generate the graphs using python script
python3 graphGenerator.py "${resultFiles[0]}" "${resultFiles[1]}" || echo "Error: could not generate graphs"