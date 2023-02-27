BEGIN {
    received_packets = 0;
    sent_packets = 0;
    dropped_packets = 0;
    total_delay = 0;
    received_bytes = 0;
    total_energy_consumption = 0;
    
    start_time = 1000000;
    end_time = 0;

    # constants
    header_bytes = 20;
    max_nodes = 1000;

    for(i=0; i<max_nodes; i++)
        node_energy_consumption[i] = 0;
    
}


{
    event = $1;
    time_sec = $2;
    node = $3;
    layer = $4;
    packet_id = $6;
    packet_type = $7;
    packet_bytes = $8;
    time_sec_for_energy = $3;

    energy_indicator = $13
    available_energy = $14
    idle_energy_consumption = $16
    sleep_energy_consumption = $18
    tx_energy_consumption = $20
    rx_energy_consumption = $22


    sub(/^_*/, "", node);
	sub(/_*$/, "", node);


    # set start time for the first line
    if( event != "N" && start_time > time_sec) {
        start_time = time_sec;
    } else if( event == "N" && start_time > time_sec_for_energy ){
		start_time = time_sec_for_energy;
	}

    if (layer == "AGT" && packet_type == "tcp") {
        
        if(event == "s") {
            sent_time[packet_id] = time_sec;
            sent_packets += 1;
        }

        else if(event == "r") {
            delay = time_sec - sent_time[packet_id];
            
            total_delay += delay;


            bytes = (packet_bytes - header_bytes);
            received_bytes += bytes;

            
            received_packets += 1;
        }
    }

    if (packet_type == "tcp" && event == "D") {
        dropped_packets += 1;
    }

    if(energy_indicator == "[energy") {
        #energy consumption calculation
        node_energy_consumption[node] = (idle_energy_consumption+sleep_energy_consumption+tx_energy_consumption+rx_energy_consumption);
    }
}


END {

    if( event != "N" ) {
        end_time = time_sec;
    } else if( event == "N"  ){
		end_time = time_sec_for_energy;
	}
    simulation_time = end_time - start_time;

    for(i=0; i<max_nodes; i++) {
        total_energy_consumption += node_energy_consumption[i];
    }

    # throughput, avg delay, delivery ratio, dropratio, energy comsumption
    # print "Throughput (kbits/sec), Avg delay (seconds), Delivery ratio, Drop ratio, Energy Consumption";
    print (received_bytes * 8) / (simulation_time * 1000), (total_delay / received_packets), (received_packets / sent_packets), (dropped_packets / sent_packets), total_energy_consumption;
}