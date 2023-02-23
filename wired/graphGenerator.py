import matplotlib.pyplot as plt
import sys
import os

graph_folder = 'graphs'

def plotGraph(xs, ys1, ys2, xLabel : str, yLabel : str, title : str, fileName : str):
    print("plotGraph\n:")
    print(f"xs: {xs}\nys1: {ys1}\nys2: {ys2}\nxLabel: {xLabel}\nyLabel: {yLabel}\ntitle: {title}\nfileName: {fileName}\n")
    fig, ax = plt.subplots()
    ax.plot(xs, ys1, color="red", label='RED')
    ax.scatter(xs, ys1, color="red")
    ax.plot(xs, ys2, color="blue", linestyle='dashed', label='FXRED')
    ax.scatter(xs, ys2, color="blue")
    # ax.grid(True)

    # give plot a title
    ax.set_title(title)

    # make axis labels
    ax.set_xlabel(xLabel)
    ax.set_ylabel(yLabel)
    
    if yLabel == 'Delivery Ratio' or yLabel == 'Drop Ratio':
        ax.set_ylim(0, 1)
            
    fig.legend(loc='upper right', bbox_to_anchor=(0.85, 0.85), ncol=1)
    
    # save the plot as a file
    fig.savefig(graph_folder + '/' +fileName)
    
    # close the plot file
    plt.close(fig)
    

def makeTitleAndCreateGraphs(data1 : dict, data2 : dict):
    print("makeTitleAndCreateGraphs\n:")
    if data1['varyingParam'] != data2['varyingParam']:
        print("Error: Varying param not same")
        exit(1)
    
    if data1['xs'] != data2['xs']:
        print("Error: X values not same")
        exit(1)
    
    print(f"varying param: {data1['varyingParam']}")
    xLabel = data1.get('varyingParam')
    xs = data1.get('xs')
    throughput1 = data1.get('throughput')
    throughput2 = data2.get('throughput')
    avgDelay1 = data1.get('avgDelay')
    avgDelay2 = data2.get('avgDelay')
    deliveryRatio1 = data1.get('deliveryRatio')
    deliveryRatio2 = data2.get('deliveryRatio')
    dropRatio1 = data1.get('dropRatio')
    dropRatio2 = data2.get('dropRatio')
    
    yLabel = 'Throughput'
    title = yLabel + ' vs ' + xLabel
    yLabel = yLabel + ' (kbps)'
    plotGraph(xs, throughput1, throughput2, xLabel, yLabel, title, title+'.png')

    yLabel = 'Average Delay'
    title = yLabel + ' vs ' + xLabel
    yLabel = yLabel + ' (sec)'
    plotGraph(xs, avgDelay1, avgDelay2, xLabel, yLabel, title, title+'.png')

    yLabel = 'Delivery Ratio'
    title = yLabel + ' vs ' + xLabel
    plotGraph(xs, deliveryRatio1, deliveryRatio2, xLabel, yLabel, title, title+'.png')

    yLabel = 'Drop Ratio'
    title = yLabel + ' vs ' + xLabel
    plotGraph(xs, dropRatio1, dropRatio2, xLabel, yLabel, title, title+'.png')


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 graphGenerator.py <red_input_file> <fxred_input_file>")
        exit(1)
    
    if not os.path.isdir(graph_folder):
        os.mkdir(graph_folder)
    
    data = [[],[]] # list of all data dictionaries
    resultFiles = [sys.argv[1], sys.argv[2]]
    for i in range(0, 2):
        varyingParamIdx = -1 # packets per sec = 1, no. of nodes = 2, no. of flows = 3
        pktspersec = []
        nodes = []
        flows = []

        throughput = []
        avgDelay = []
        deliveryRatio = []
        dropRatio = []
        
        with open(resultFiles[i], 'r') as inputFile:
            for line in inputFile:
                if line.startswith('='):
                    varyingParamIdx += 1

                    if varyingParamIdx < 1: continue

                    varyingParam = None
                    xs = []
                    
                    if varyingParamIdx == 1:
                        varyingParam = 'Packets Per Second'
                        xs = pktspersec
                    elif varyingParamIdx == 2:
                        varyingParam = 'Number of Nodes'
                        xs = nodes
                    elif varyingParamIdx == 3:
                        varyingParam = 'Number of Flows'
                        xs = flows
                    
                    # print(f"Varying param: {varyingParam}")
                    # makeTitleAndCreateGraphs(varyingParam, xs, throughput, avgDelay, deliveryRatio, dropRatio)
                    data[i].append({
                        'varyingParam' : varyingParam,
                        'xs' : xs,
                        'throughput' : throughput,
                        'avgDelay' : avgDelay,
                        'deliveryRatio' : deliveryRatio,
                        'dropRatio' : dropRatio
                    })
                    
                    throughput = []
                    avgDelay = []
                    deliveryRatio = []
                    dropRatio = []
                elif line.startswith('Packets Per Sec'):
                    # print(line, line.split(sep=" ")[-1])
                    pktspersec.append(int(line.split(sep=" ")[-1]))
                elif line.startswith('Number of Nodes'):
                    nodes.append(int(line.split(sep=" ")[-1]))
                elif line.startswith('Number of Flows'):
                    flows.append(int(line.split(sep=" ")[-1]))
                elif line.startswith('varying') or line.startswith('-'):
                    continue
                else:
                    metrices = line.split(sep=" ")

                    if len(metrices) < 4:
                        continue

                    throughput.append(float(metrices[0])/1000)
                    avgDelay.append(float(metrices[1]))
                    deliveryRatio.append(float(metrices[2]))
                    dropRatio.append(float(metrices[3]))
    
    for i in range(0, len(data[1])):
        # print(f"data1: {data[0][i]}\ndata2: {data[1][i]}\n")
        makeTitleAndCreateGraphs(data[0][i], data[1][i])