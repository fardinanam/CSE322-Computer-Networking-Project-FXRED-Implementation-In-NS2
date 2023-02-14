if {$argc != 2} {
    puts "Usage: ns $argv0 <number_of_nodes> <number_of_flows>"
    exit 1
}

if {[lindex $argv 0] < 4 || [lindex $argv 1] % 2} {
    puts "Number of nodes must be even and at least 4"
    exit 1
}

set ns [new Simulator]

#======================
# define options
set val(nn) [lindex $argv 0]
set val(nf) [lindex $argv 1]
set val(qlimit) 30
set val(tstart) 0.5
set val(tend) 10
#======================

set namFile [open animation.nam w]
$ns namtrace-all $namFile

set node_(r1) [$ns node]
set node_(r2) [$ns node]

set val(nn) [expr {$val(nn) - 2}]

puts "Number of nodes: $val(nn)"

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
    $tcp_($i) set window_ 15

    set ftp_($i) [$tcp_($i) attach-source FTP]
}

# # Tracing a queue
# set redq [[$ns link $node_(r1) $node_(r2)] queue]
# set tchan_ [open all.q w]
# $redq trace curq_
# $redq trace ave_
# $redq attach $tchan_

for {set i 0} {$i < $val(nf)} {incr i} {
    $ns at $val(tstart) "$ftp_($i) start"
    $ns at $val(tend) "$ftp_($i) stop"
}

$ns at $val(tend) "finish"

# Define 'finish' procedure (include post-simulation processes)
proc finish {} {
    # global tchan_
    # set awkCode {
	# {
	#     if ($1 == "Q" && NF>2) {
	# 	print $2, $3 >> "temp.q";
	# 	set end $2
	#     }
	#     else if ($1 == "a" && NF>2)
	#     print $2, $3 >> "temp.a";
	# }
    # }
    # set f [open temp.queue w]
    # puts $f "TitleText: red"
    # puts $f "Device: Postscript"
    
    # if { [info exists tchan_] } {
	# close $tchan_
    # }
    # exec rm -f temp.q temp.a 
    # exec touch temp.a temp.q
    
    # exec awk $awkCode all.q
    
    # puts $f \"queue
    # exec cat temp.q >@ $f  
    # puts $f \n\"ave_queue
    # exec cat temp.a >@ $f
    # close $f
    # exec xgraph -bb -tk -x time -y queue temp.queue &
    exit 0
}

$ns run
