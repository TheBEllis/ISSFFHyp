import numpy as np
import csv


with open("HeatFlux.csv", mode="r") as infile:
    reader = csv.reader(infile, dialect="excel", delimiter="\t")    
    with open("temp2.txt", mode="w") as outfile:
        writer = csv.writer(outfile, delimiter=',')
        writer.writerows(reader)