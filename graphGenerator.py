import matplotlib.pyplot as plt
import sys
import os

def plotGraph(xs, ys, xLabel : str, yLabel : str, title : str, fileName : str):
    fig, ax = plt.subplots()
    ax.plot(xs, ys, color="blue", linestyle='dashed')
    ax.scatter(xs, ys, color="red")
    ax.grid(True)

    # give plot a title
    ax.set_title(title)

    # make axis labels
    ax.set_xlabel(xLabel)
    ax.set_ylabel(yLabel)
    
    # save the plot as a file
    fig.savefig('graphs/'+fileName)
    
    # close the plot file
    plt.close(fig)
    

def makeTitleAndCreateGraphs(varyingParam : str, xs : list, throughputs : list, avgDelays : list, deliveryRatios : list, dropRatios):
    xLabel = varyingParam
    
    yLabel = 'Throughput'
    title = yLabel + ' vs ' + varyingParam
    yLabel = yLabel + ' (kbps)'
    plotGraph(xs, throughputs, xLabel, yLabel, title, title+'.png')

    yLabel = 'Average Delay'
    title = yLabel + ' vs ' + varyingParam
    yLabel = yLabel + ' (sec)'
    plotGraph(xs, avgDelays, xLabel, yLabel, title, title+'.png')

    yLabel = 'Delivery Ratio'
    title = yLabel + ' vs ' + varyingParam
    plotGraph(xs, deliveryRatios, xLabel, yLabel, title, title+'.png')

    yLabel = 'Drop Ratio'
    title = yLabel + ' vs ' + varyingParam
    plotGraph(xs, dropRatios, xLabel, yLabel, title, title+'.png')


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 graphGenerator.py <input_file>")
        exit(1)
    
    if not os.path.isdir('graphs'):
        os.mkdir('graphs')

    varyingParamIdx = -1 # area = 1, no. of nodes = 2, no. of flows = 3
    areaSizes = []
    nodes = []
    flows = []

    throughput = []
    avgDelay = []
    deliveryRatio = []
    dropRatio = []

    with open(sys.argv[1], 'r') as inputFile:
        for line in inputFile:
            if line.startswith('='):
                varyingParamIdx += 1

                if varyingParamIdx < 1: continue

                varyingParam = None
                xs = []
                
                if varyingParamIdx == 1:
                    varyingParam = 'Area Size'
                    xs = areaSizes
                elif varyingParamIdx == 2:
                    varyingParam = 'Number of Nodes'
                    xs = nodes
                elif varyingParamIdx == 3:
                    varyingParam = 'Number of Flows'
                    xs = flows
                
                # print(f"Varying param: {varyingParam}")
                makeTitleAndCreateGraphs(varyingParam, xs, throughput, avgDelay, deliveryRatio, dropRatio)
                
                throughput = []
                avgDelay = []
                deliveryRatio = []
                dropRatio = []
            elif line.startswith('Area Size'):
                # print(line, line.split(sep=" ")[-1])
                areaSizes.append(int(line.split(sep=" ")[-1]))
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