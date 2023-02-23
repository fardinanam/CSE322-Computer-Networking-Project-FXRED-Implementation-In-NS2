if {$argc != 4} {
    puts "Usage: ns $argv0 <red-type(0=>red, 1=>fxred)> <number_of_nodes> <number_of_flows> <packets_per_second>"
    exit 1
}

if {[lindex $argv 0] != 0 && [lindex $argv 0] != 1} {
    puts "RED type must be 0 or 1"
    exit 1
}

if {[lindex $argv 1] < 4 || [lindex $argv 1] % 2} {
    puts "Number of nodes must be even and at least 4"
    exit 1
}

set ns [new Simulator]

#======================
# define options
set val(redtype) [lindex $argv 0] 
set val(nn) [lindex $argv 1]
set val(nf) [lindex $argv 2]
set val(pktpersec) [lindex $argv 3]
set val(pktsize) 1000
set val(qlimit) 30
set val(tstart) 0.5
set val(tend) 10
#======================

Queue/RED set thresh_ 5
Queue/RED set maxthresh_ 15
Queue/RED set q_weight_ 0.001
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set mean_pktsize_ $val(pktsize)
Queue/RED set fxred_ $val(redtype)
Queue/RED set c_ 2

set namFile [open animation.nam w]
$ns namtrace-all $namFile
set traceFile [open trace.tr w]
$ns trace-all $traceFile

set node_(r1) [$ns node]
set node_(r2) [$ns node]

set val(nn) [expr {$val(nn) - 2}]

# puts "Number of nodes: $val(nn)"

expr srand(87)

for {set i 0} {$i < [expr {$val(nn) / 2}]} {incr i} {
    set node_(s$i) [$ns node]
    $ns duplex-link $node_(s$i) $node_(r1) 10Mb 2ms DropTail
}

$ns duplex-link $node_(r1) $node_(r2) 1.5Mb 20ms RED 
$ns queue-limit $node_(r1) $node_(r2) $val(qlimit)
$ns queue-limit $node_(r2) $node_(r1) $val(qlimit)

for {set i 0} {$i < [expr {$val(nn) / 2}]} {incr i} {
    set node_(d$i) [$ns node]
    $ns duplex-link $node_(d$i) $node_(r2) 10Mb 2ms DropTail
}

$ns duplex-link-op $node_(r1) $node_(r2) orient right
$ns duplex-link-op $node_(r1) $node_(r2) queuePos 0
$ns duplex-link-op $node_(r2) $node_(r1) queuePos 0

for {set i 0} {$i < $val(nf)} {incr i} {
    set source [expr int(rand() * ($val(nn)/2))]
    set dest [expr int(rand() * ($val(nn)/2))]
    set tcp_($i) [$ns create-connection TCP/Reno $node_(s$source) TCPSink $node_(d$dest) $i]

    set ftp_($i) [new Application/FTP]
    $ftp_($i) set packetSize_ $val(pktsize)
    $ftp_($i) set rate_ 10Mb
    $ftp_($i) set interval_ [expr 1.0 / $val(pktpersec)]
    # puts "packet rate: $val(pktpersec)"
    # puts "packet interval: [expr 1.0 / $val(pktpersec)]"
    $ftp_($i) attach-agent $tcp_($i)

    # set udp_($i) [new Agent/UDP]
    # $ns attach-agent $node_(s$source) $udp_($i)
    
    # set cbr_($i) [new Application/Traffic/CBR]
    # $cbr_($i) set PacketSize_ $val(pktsize)
    # $cbr_($i) set rate_ $val(pktpersec)
    # $cbr_($i) attach-agent $udp_($i)

    # set sink_($i) [new Agent/Null]
    # $ns attach-agent $node_(d$dest) $sink_($i)

    # $ns connect $udp_($i) $sink_($i)
}

for {set i 0} {$i < $val(nf)} {incr i} {
    $ns at $val(tstart) "$ftp_($i) start"
    $ns at $val(tend) "$ftp_($i) stop"
}

$ns at $val(tend) "finish"

# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
    exit 0
}

$ns run
