import csv

print "start"

input = open('cambpop-nodes.csv', 'rb')
output = open('cambpop-nodes-clean.csv', 'wb')
writer = csv.writer(output)
for row in csv.reader(input):
##    print row
    if row != ['', '', '']:
        writer.writerow(row)
input.close()
output.close()

print "done"
