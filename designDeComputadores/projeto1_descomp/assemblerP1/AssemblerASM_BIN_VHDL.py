# Caminhos para os arquivos
inputASM = 'ASM.txt'
outputBIN = 'BIN.txt'
outputMIF = 'initROM.mif'

# Dicionário dos mnemônicos e seus respectivos OPCODEs em Hexadecimal
mne = {
    "NOP": "0", "LDA": "1", "SOMA": "2", "SUB": "3",
    "LDI": "4", "STA": "5", "JMP": "6", "JEQ": "7",
    "CHECK": "8", "JSR": "9", "RET": "A", "ANDI": "B",
    "JLT": "C", "JNE": "D"
}

# Indica se os operandos imediatos devem ser tratados com 9 bits
noveBits = False

def encontrar_labels(lines):
    labels = {}
    addr = 0
    for line in lines:
        # Remove espaços em branco e verifica se a linha não é um comentário e não está vazia
        stripped_line = line.strip()
        if stripped_line and not stripped_line.startswith('#'):
            # Verifica se a linha contém um label
            if ':' in stripped_line:
                label = stripped_line.split(':')[0].strip()
                labels[label] = addr
            else:
                addr += 1
    return labels

lines = []
with open(inputASM) as f:
    lines = f.readlines()

labels = encontrar_labels(lines)

def processar_linha(line, labels):
    line_comentada = line.strip()  # Guarda a linha original para comentários
    line = line.split('#')[0].strip()  # Remove comentários e espaços extras
    partes = line.split()
    if not partes:
        return None, None  # Ignora linhas vazias
    opcode = mne.get(partes[0], None)
    if opcode is None:
        return None, None  # Ignora linhas não mapeadas
    operand = "000000000"  # Operand padrão como string de 9 bits
    coment = ""  # Comentário inicial vazio
    if len(partes) == 2:
        operando = partes[1].lstrip('@$')
        if operando.isdigit():
            # Converte o operando para binário e preenche para garantir 9 bits
            operand = format(int(operando), '09b')
        elif operando.startswith('.'):
            label_addr = labels[operando]
            print(labels)
            if label_addr is not None:
                # Converte o endereço do label para binário e preenche para 9 bits
                operand = format(label_addr, '09b')
            else:
                return None, None  # Ignora labels não encontrados
    if len(partes) == 1 or (len(partes) == 2 and not line_comentada.endswith("#")):
        coment = partes[0]  # Usa o mnemônico como comentário se não houver outro
    else:
        coment = line_comentada.split('#')[1] if '#' in line_comentada else partes[0]
    return f"{partes[0]} & \"{operand}\"", coment

# Ajuste no loop de escrita dos arquivos para aplicar o novo formato
with open(outputBIN, 'w') as f_bin, open(outputMIF, 'w') as f_mif:
    f_mif.write("WIDTH=8;\nDEPTH=256;\nADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n")
    addr = 0
    for line in lines:
        processed_line, coment = processar_linha(line, labels)
        if processed_line:
            f_bin.write(f"tmp({addr})  := {processed_line}; -- {coment}\n")
            # A linha abaixo é uma adaptação para manter a compatibilidade com o formato MIF, caso necessário
            hex_opcode, hex_operand = processed_line.split(' & ')
            hex_opcode = format(int(mne[hex_opcode], 16), 'X')
            hex_operand = format(int(hex_operand.replace('"', ''), 2), '02X')
            f_mif.write(f"    {addr} : x\"{hex_opcode}{hex_operand}\"; -- {coment}\n")
            addr += 1
    f_mif.write("END;")

with open(outputBIN, 'w') as f_bin, open(outputMIF, 'w') as f_mif:
    f_mif.write("WIDTH=8;\nDEPTH=256;\nADDRESS_RADIX=DEC;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n")
    addr = 0
    for line in lines:
        processed_line, coment = processar_linha(line, labels)
        if processed_line:
            f_bin.write(f"tmp({addr}) := {processed_line}; -- {coment}\n")
            f_mif.write(f"    {addr} : {processed_line.split(';')[0]}; -- {coment}\n")
            addr += 1
    f_mif.write("END;")
