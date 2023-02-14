#1805087	
#wireless MAC: 802.11	
#Routing protocol: DSDV	
#Agent + Application: UDP + Exponential Traffic	
#Node Positioning: Random	
#Flow: 1 Source, Random Sink

if {$argc != 4} {
    puts "Usage: ns $argv0 <area_length> <area_width> <number_of_nodes> <number_of_flows>"
    exit 1
}

set ns [new Simulator]

#===============================================================================
#Define options
set val(chan)           Channel/WirelessChannel
set val(prop)           Propagation/TwoRayGround
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(rp)             DSDV
set val(ant)            Antenna/OmniAntenna
set val(ll)             LL
set val(ifq)            Queue/RED
set val(ifqlen)         50
set val(hLen)           [lindex $argv 0]
set val(vLen)           [lindex $argv 1]
set val(nn)             [lindex $argv 2]
set val(nf)             [lindex $argv 3]
set val(tstart)         5.0
set val(tend)           100.0
set val(vmin)           0
set val(vmax)           0
set val(energymodel)    EnergyModel		;# Energy Model
set val(initialenergy)  100			    ;# value
# queue parameters
set val(qthresh)        10
set val(qmaxthresh)     30
set val(qweight)        0.002
set val(qminpcksize)    1000
#===============================================================================
#trace file
set traceFile [open trace.tr w]
$ns trace-all $traceFile

#nam file
set namFile [open animation.nam w]
$ns namtrace-all-wireless $namFile $val(hLen) $val(vLen)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(hLen) $val(vLen)

create-god $val(nn)

# Create channel
set chan_1_ [new $val(chan)]

$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace ON \
		-routerTrace ON \
		-macTrace OFF \
		-movementTrace OFF \
		-channel $chan_1_ \
        -energyModel $val(energymodel) \
        -initialEnergy $val(initialenergy) \
        -rxPower 35.28e-3 \
        -txPower 31.32e-3 \
        -idlePower 712e-6 \
        -sleepPower 144e-9 

# Set RED queue parameters
Queue/RED set thresh_ $val(qthresh)
Queue/RED set maxthresh_ $val(qmaxthresh)
Queue/RED set q_weight_ $val(qweight)
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set min_pcksize_ $val(qminpcksize)

# Generate nodes at random positions
set points []
for {set i 0} {$i < $val(nn)} {incr i} {
    # global $node_($i)

    set x [expr rand() * $val(hLen)]
    set y [expr rand() * $val(vLen)]

    while {[lsearch -all -inline $points [list $x $y]] != {}} {
        set x [expr rand() * $val(hLen)]
        set y [expr rand() * $val(vLen)]
    }

    set point [list $x $y]
    lappend points $point

    set node_($i) [$ns node]
    $node_($i) random-motion 0
    
    # Set initial node position
    $node_($i) set X_ $x
    $node_($i) set Y_ $y
    $node_($i) set Z_ 0.0
    $ns initial_node_pos $node_($i) 20  

    # Set node movement
    set tmov [expr (rand() * ($val(tend) - $val(tstart)) + $val(tstart))]   ;# start moving at random time
    set destX [expr rand() * $val(hLen)]                                    ;# move to random position
    set destY [expr rand() * $val(vLen)]                                    ;# move to random position  
    set speed [expr (rand() * ($val(vmax) - $val(vmin)) + $val(vmin))]      ;# move at random speed
    $ns at $tmov "$node_($i) \
        setdest $destX \
        $destY \
        $speed"
}

# select a node as a source 
set srcNodeNum [expr int(rand() * $val(nn))]

puts "Source node: $srcNodeNum $node_($srcNodeNum)"

# Create random flows
for {set i 0} {$i < $val(nf)} {incr i} {
    # Create a UDP agent and attach it to source node
    set udp_($i) [new Agent/UDP]
    $ns attach-agent $node_($srcNodeNum) $udp_($i)
    # select a node as a sink
    set sinkNodeNum [expr int(rand() * $val(nn))]
    while {$sinkNodeNum == $srcNodeNum} {
        set sinkNodeNum [expr int(rand() * $val(nn))]
    }
    # puts "Sink node: $sinkNodeNum $node_($sinkNodeNum)"
    # Create a null agent and attach it to sink node
    set null_($i) [new Agent/Null]
    $ns attach-agent $node_($sinkNodeNum) $null_($i)

    # Create the flow
    $ns connect $udp_($i) $null_($i)
    
    # Attach an exponential traffic generator to the flow
    set exp_($i) [new Application/Traffic/Exponential]
    $exp_($i) set packetSize_ 512
    $exp_($i) set burst_time_ 500ms
    $exp_($i) set idle_time_ 500ms
    $exp_($i) set rate_ 100k

    $exp_($i) attach-agent $udp_($i)

    $ns at $val(tstart) "$exp_($i) start"
}

# Tell nodes when the simulation ends
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns at $val(tend) "$node_($i) reset";
}

$ns at $val(tend) "finish"
$ns at [expr $val(tend) + 0.1] "puts \"NS EXITING...\" ; $ns halt"
proc finish {} {
    global ns traceFile namFile
    $ns flush-trace
    close $traceFile
	close $namFile
    # exec nam animation.nam &
    exit 0
}

$ns run