import random
import sys


x = sys.argv[1].split(',')

retRan = random.sample(range(1, int(x[0])), int(x[1]))
#retRan.sort()
rest = ",".join('%s' % id for id in retRan)
print(rest)


