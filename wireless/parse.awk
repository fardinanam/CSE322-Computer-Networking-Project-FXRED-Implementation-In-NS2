BEGIN {
    receivedPackets = 0;
    sentPackets = 0;
    droppedPackets = 0;
    totalReceivedBytes = 0;

    totalDelay = 0;
    simStartTime = 1000000;
    simEndTime = 0;

    headerBytes = 20;

    totalEnergy = 0;
}

{
    eventType = $1;
    eventStartTime = $2;
    nodeID = $3;
    layerType = $4;
    packetId = $6;
    packetType = $7;
    packetBytes = $8;
    energyValue = $7

    # Eliminate the underscores from the node ID
    sub(/^_*/, "", node)
    sub(/_*$/, "", node)

    # Set start time for the simulation
    if (eventStartTime < simStartTime) {
        simStartTime = eventStartTime;
    }

    if (layerType == "AGT" && (packetType == "tcp" || packetType == "udp" || packetType == "cbr")) {
        if (eventType == "s") {
            sentPackets++;
            packetSentTime[packetId] = eventStartTime;
        } else if (eventType == "r") {
            packetTransmitTime = eventStartTime - packetSentTime[packetId];

            if (packetTrasnmitTime < 0) {
                print "ERROR";
            } else {
                totalDelay += packetTransmitTime;
                totalReceivedBytes += packetBytes - headerBytes;
                # print "bytes: ", packetBytes - headerBytes;
                receivedPackets++;
            }
        }
    }

    if (eventType == "N") {
        totalEnergy += energyValue;
    }

    if (packetType == "tcp" && eventType == "D") {
        droppedPackets++;
    }
}

END {
    simEndTime = eventStartTime;
    simTime = simEndTime - simStartTime;

    # droppedPackets = sentPackets - receivedPackets;

    throughput = (totalReceivedBytes * 8) / simTime;
    avgDelay = (totalDelay / receivedPackets);
    deliveryRatio = (receivedPackets / sentPackets);
    dropRatio = (droppedPackets / sentPackets);

    # print "Simulation Time: ", simTime;
    # print "Total Packets Sent: ", sentPackets;
    # print "Total Packets Received: ", receivedPackets;
    # print "Total Bytes Received: ", totalReceivedBytes;
    # print "Total Packets Dropped: ", droppedPackets;

    # print "------------------------------------------------------";
    # print "Throughput:", throughput, "bits/sec";
    # print "Average Delay:", avgDelay, "sec";
    # print "Delivery Ratio:", deliveryRatio;
    # print "Drop Ratio:", dropRatio;
    # print "Total Energy Consumption:", totalEnergy;

    print throughput, avgDelay, deliveryRatio, dropRatio, totalEnergy;
}