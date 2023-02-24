BEGIN {
    receivedPackets = 0;
    sentPackets = 0;
    droppedPackets = 0;
    totalReceivedBytes = 0;

    totalDelay = 0;
    simStartTime = 1000000;
    simEndTime = 0;

    headerBytes = 20;
}

{
    eventType = $1;
    eventStartTime = $2;
    packetType = $5;
    packetBytes = $6;
    packetId = $12;

    # Eliminate the underscores from the node ID
    sub(/^_*/, "", nodeID)
    sub(/_*$/, "", nodeID)

    # Set start time for the simulation
    if (eventStartTime < simStartTime) {
        simStartTime = eventStartTime;
    }

    if (packetType == "tcp" || packetType == "udp" || packetType == "cbr") {
        if (eventType == "+") {
            sentPackets++;
            packetSentTime[packetId] = eventStartTime;
        } else if (eventType == "r") {
            packetTransmitTime = eventStartTime - packetSentTime[packetId];

            if (packetTrasnmitTime < 0) {
                print "ERROR";
            } else {
                totalDelay += packetTransmitTime;
                totalReceivedBytes += packetBytes - headerBytes;
                receivedPackets++;
            }
        } else if (eventType == "d") {
            droppedPackets++;
        }
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
    # print "Total Packets Dropped: ", droppedPackets;

    # print "------------------------------------------------------";
    # print "Throughput:", throughput, "bits/sec";
    # print "Average Delay:", avgDelay, "sec";
    # print "Delivery Ratio:", deliveryRatio;
    # print "Drop Ratio:", dropRatio;

    print throughput, avgDelay, deliveryRatio, dropRatio;
}