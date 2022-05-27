import sys
import re


opcodes ={'NOP': '110000','HLT': '110001','SETC': '000000','NOT': '000001','INC': '000010','OUT': '000011','IN': '000100','MOV': '000101','SWAP': '000110','ADD': '000111',
        'SUB': '001000','AND': '001001','IADD': '010000','PUSH': '010001','POP': '010010','LDM': '010011','LDD': '010100','STD': '010101',
        'JZ': '100000','JN': '100001','JC': '100010','JMP': '100011','CALL': '100100','RET': '100101','INT': '100110','RTI': '100111',
        'R0': '000', 'R1':'001', 'R2':'010', 'R3':'011', 'R4':'100','R5':'101','R6':'110', 'R7':'111'
        }


def mcode(tokens):
    if tokens[0] == "NOP" or tokens[0]=="HLT" or tokens[0] == "SETC" or tokens[0] == "RET" or tokens[0] == "RTI":
        op = opcodes[tokens[0]]
    elif tokens[0] == "NOT" or tokens[0]=="INC" or tokens[0] == "PUSH" or tokens[0] == "POP":
        binary = opcodes[tokens[0]]
        rs2 = opcodes[tokens[1]]
        op1 = binary.ljust(9,'X')
        op2 = rs2.ljust(6, 'X')
        op = op1 + op2
    elif tokens[0] == "OUT":
        binary = opcodes[tokens[0]]
        rs1 = opcodes[tokens[1]]
        op1 = binary + rs1
        op = op1.ljust(15, 'X')
    elif tokens[0] == "IN":
        binary = opcodes[tokens[0]]
        rdst = opcodes[tokens[1]]
        op1 = binary.ljust(12, 'X')
        op = op1 + rdst
    elif tokens[0] == "MOV":
        binary = opcodes[tokens[0]]
        rs1 = opcodes[tokens[1]]
        rdst = opcodes[tokens[2]]
        op1 = (binary+rs1).ljust(12, 'X')
        op = op1 + rdst
    elif tokens[0] == "SWAP":
        binary = opcodes[tokens[0]]
        rs1 = opcodes[tokens[1]]
        rs2 = opcodes[tokens[2]]
        op1 = binary +rs1 + rs2
        op = op1.ljust(15 , 'X')
    elif tokens[0] == "ADD" or tokens[0] == "SUB" or tokens[0] == "AND":
        binary = opcodes[tokens[0]]
        rs1 = opcodes[tokens[2]]
        rs2 = opcodes[tokens[3]]
        rdst = opcodes[tokens[1]]
        op = binary + rs1 + rs2 + rdst
    elif tokens[0] == "IADD" :
        binary = opcodes[tokens[0]]
        rs = opcodes[tokens[2]]
        rdst = opcodes[tokens[1]]
        op1 = (binary + rs ). ljust(12, 'X')
        offset = '{:016b}'.format (int(tokens[3],16))
        op = (op1 + rdst).ljust(16, 'X') + offset
    elif tokens[0] == "LDM" :
        binary = opcodes[tokens[0]]
        rdst = opcodes[tokens[1]]
        op1 = binary.ljust(12, 'X')
        op2 =op1 + rdst
        op3 = op2.ljust(16, 'X')
        offset = '{:016b}'.format (int(tokens[2],16))
        
        op = op3 + offset
    elif tokens[0] == "JZ" or tokens[0] == "JN" or tokens[0] == "JC" or tokens[0] == "JMP" or tokens[0] == "CALL" or tokens[0] == "INT": 
        binary = opcodes[tokens[0]]
        op1 = binary.ljust(16, 'X')
        offset = '{:016b}'.format (int(tokens[1],16))
        op = op1 + offset
    elif tokens[0] == "STD" or tokens[0] == "LDD":
        binary = opcodes[tokens[0]]
        rs = opcodes[tokens[3]]
        op1 = (binary + rs).ljust(12, 'X')
        rdst = opcodes[tokens[1]]
        offset = '{:016b}'.format (int(tokens[2],16))
        op = (op1 + rdst).ljust(16, 'X') + offset



    return op


ram ={}


address = 0
flag = False

with open (sys.argv[1]) as file:
    for line in file:
        if line[0] == "#" or line[0] == "\n" :
            continue

        pattern ='#.*'
        no_comment = re.sub(pattern ,' ', line )
        tokens = no_comment.replace(',', ' ').replace('(', ' ').replace(')', ' ').split()
        print(tokens)

        if tokens[0] == ".ORG":
            address = int(tokens[1] , 16) #memory address is given in hexadecimal
            flag = True
            continue
        
        if flag == True and opcodes.get(tokens[0])==None :
            ram[address] =  '{:032b}'.format (int(tokens[0],16))
            flag = False
            address = address +1

        if flag == True and opcodes.get(tokens[0])!=None:
            t= mcode(tokens)
            t1 = t.ljust(32,'X')
            print(t1)
            ram[address] = t1
            address = address +1
            
        
with open("memory.mem", 'w') as f:
                f.write(r'''// memory data file (do not edit the following line - required for mem load use)
// instance=/ram/ram
// // format=mti addressradix=d dataradix=b version=1.0 wordsperline=1''')
                for k in sorted(ram):
                    f.write(f'\n{k}: {ram[k]} ')

print(ram)