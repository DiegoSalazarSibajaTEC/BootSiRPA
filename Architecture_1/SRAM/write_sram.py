import random

file = open("sram_input.txt","w") 

for x in range(8192):
    word="{0:b}".format(random.randint(1, 10000000)).zfill(32)
    ##print(word+'\n')
    file.write(word+'\n')
file.close() 
