import pyautogui
import serial
import argparse
import time
import logging
import pygame
import sys
import threading

global valor_potenciometro
valor_potenciometro = None

global start
start = True

class MyControllerMap:
    def __init__(self):
        self.button = { 0 : 'h', 
                        1 : 'd',            # botao da placa
                        2 : 'r',            # botao de red
                        3 : 'b',            # botao de blue
                        4 : 'g',            # botao de green
                        5 : 'e',            # botao de exit
                        6 : 'f',            # botao de clear
                        7 : 'w' or 'up',    # botao de up
                        8 : 's' or 'down',  # botao de down
                        9 : 'a' or 'left',  # botao de left
                        10 : 'd' or 'right' # botao de right
                        }
   
class SerialControllerInterface:
    def __init__(self, port, baudrate, etch_a_sketch):
        self.ser = serial.Serial(port, baudrate=baudrate)
        self.etch_a_sketch = etch_a_sketch
        self.incoming = None
        pyautogui.PAUSE = 0
    
    def process_button(self, id, value):
        actions = {
            0: self.etch_a_sketch.handshake,   # botao de handshake
            1: self.etch_a_sketch.move_left,   # botao da placa
            2: self.etch_a_sketch.color_red,   # botao de red
            3: self.etch_a_sketch.color_blue,  # botao de blue
            4: self.etch_a_sketch.color_green, # botao de green
            5: self.etch_a_sketch.save_image,  # botao de save_image
            6: self.etch_a_sketch.clear_game,  # botao de clear
            7: self.etch_a_sketch.move_up,     # botao de up
            8: self.etch_a_sketch.move_down,   # botao de down
            9: self.etch_a_sketch.move_left,   # botao de left
            10: self.etch_a_sketch.move_right  # botao de right
        }
        action = actions.get(id, None)
        if action:
            print(f"Botão mapeado: {id}")
            if id in [1, 7, 8, 9, 10]:
                if value == 0:
                    # Inicia a ação de movimento se for um botão de movimento
                        action()  # Começa a ação
                else:
                    # Para a ação de movimento se for um botão de movimento
                    action(start=False)  # Para a ação
            else: 
                action()
        else:
            print(f"Botão não mapeado: {id}")
    
    def process_potentiometer(self, id, value):
        # Converta os valores de ID e VALUE de volta para um número inteiro
        pot_value = (id << 8) | value
        print(f"Valor do potenciômetro: {pot_value}")
        global valor_potenciometro
        valor_potenciometro = pot_value

    def update(self):
        head = None
        try:
            ## Handshake protocol
            while self.incoming != "H":
                self.incoming = self.ser.read().decode('utf-8')
                print(f"Recebido: {self.incoming}")
                if self.incoming == "H":
                    head = self.incoming
                    id = int.from_bytes(self.ser.read(), byteorder='big')
                    value = int.from_bytes(self.ser.read(), byteorder='big')
                    eof = self.ser.read().decode('utf-8')
                    self.ser.write(b'H')
                    logging.debug("Received HANDSHAKE: {} {} {}".format(head, id, value, eof))
                else:
                    logging.debug("Received INCOMING: {}".format(self.incoming))

            if head != "H":
                head = self.ser.read().decode('utf-8')
                if head != "H" and head != "B" and head != "P":
                    while head != "H":
                        head = self.ser.read().decode('utf-8')
                        if head == "H":
                            id = int.from_bytes(self.ser.read(), byteorder='big')
                            value = int.from_bytes(self.ser.read(), byteorder='big')
                            eof = self.ser.read().decode('utf-8')
                            self.process_button(6, 1) # reinicia o jogo
                            logging.debug("Received HANDSHAKE: {}".format(head))
                        else:
                            logging.debug("Received INCOMING: {}".format(head))
                else:
                    id = int.from_bytes(self.ser.read(), byteorder='big')
                    value = int.from_bytes(self.ser.read(), byteorder='big')
                    eof = self.ser.read().decode('utf-8')
                    if head != "H":
                        logging.debug(f"Received DATA: {head} {id} {value} {eof}")

            if head == "H":
                pass
            elif head == "B":
                self.process_button(id, value)
            elif head == "P":
                self.process_potentiometer(id, value)
            else:
                print(f"Header inválido: {head}")

            self.ser.write(b'X')
        
        except Exception as e:
            logging.error(e)
            pass
    
    def start_reading(self):
        self.running = True
        threading.Thread(target=self.read_from_port, daemon=True).start()

    def read_from_port(self):
        while self.running:
            self.etch_a_sketch.update_movement()
            self.update()
    
    def stop_reading(self):
        self.running = False

class Etch_a_sketch:
    def __init__(self):
        self.x = 315
        self.y = 250
        self.color_state = "BLACK"
        self.r = 0
        self.g = 0
        self.b = 0
        self.moving = {'left': False, 'right': False, 'up': False, 'down': False}
        self.clean = False
        self.running = True
        self.save = False
        self.n_screenshots = 0
    
    def transforma_valor_potenciometro(self, valor_potenciometro):
        # valor convertido está entre 0 e 4095, trasnformar para 0 a 255
        valor_convertido = valor_potenciometro / 16
        return valor_convertido
    
    def start_game(self):
        threading.Thread(target=self.run_game, daemon=True).start()

    def handshake(self):
        pass

    def color_red(self):
        self.r = 255
        self.g = 000
        self.b = 000
        self.color_state = "RED"
        print("RED")
    
    def color_green(self):
        self.g = 255  
        self.r = 000
        self.b = 000
        self.color_state = "GREEN"
        print("GREEN")
    
    def color_blue(self):        
        self.b = 255
        self.r = 000
        self.g = 000
        self.color_state = "BLUE"
        print("BLUE")

    def move_left(self, start=True):
        # Ativa ou desativa o movimento para a esquerda
        self.moving['left'] = start
        print(start)

    def move_right(self, start=True):
        # Ativa ou desativa o movimento para a direita
        self.moving['right'] = start
        print(start)

    def move_up(self, start=True):
        # Ativa ou desativa o movimento para cima
        self.moving['up'] = start
        print(start)

    def move_down(self, start=True):
        # Ativa ou desativa o movimento para baixo
        self.moving['down'] = start
        print(start)

    def clear_game(self):
        # Limpa a tela
        self.clean = True

    def exit_game(self):
        # Sai do jogo
        self.running = False

    def save_image(self):
        self.save = True

    def update_movement(self):
        if self.moving['left']:
            self.x -= 0.05
        if self.moving['right']:
            self.x += 0.05
        if self.moving['up']:
            self.y -= 0.05
        if self.moving['down']:
            self.y += 0.05

    def update_color(self):
        if valor_potenciometro is not None:
            if self.color_state == "RED":
                self.r = self.transforma_valor_potenciometro(valor_potenciometro)
            if self.color_state == "GREEN":
                self.g = self.transforma_valor_potenciometro(valor_potenciometro)
            if self.color_state == "BLUE":
                self.b = self.transforma_valor_potenciometro(valor_potenciometro)

    def run_game(self):
        pygame.init()
        self.color_state = "BLACK"
        
        #Create Window
        screen = pygame.display.set_mode((636, 518))
        done = False
        
        #Import Background
        image = pygame.image.load(r'./etch_a_sketch.jpg')
        screen.blit(image, (0,0))

        #LOOP
        while not done:
            self.update_movement()
            self.update_color()
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    done = True
            pygame.draw.rect(screen, (self.r,self.g,self.b), pygame.Rect(self.x, self.y, 5, 5))

            #Boundaries
            if self.x <= 78:
                self.x = 78
            elif self.x >= 542:
                self.x = 542
            if self.y >= 418:
                self.y = 418
            elif self.y <= 86:
                self.y = 86
            
            #Get Keys
            pressed = pygame.key.get_pressed()

            #Colours
            if pressed[pygame.K_r]:
                if valor_potenciometro is not None:
                    self.r = self.transforma_valor_potenciometro(valor_potenciometro)
                else:
                    self.r = 255
                self.g = 000
                self.b = 000
                self.color_state = "RED"

            if pressed[pygame.K_g]:
                if valor_potenciometro is not None:
                    self.g = self.transforma_valor_potenciometro(valor_potenciometro)
                else:
                    self.g = 255  
                self.r = 000
                self.b = 000
                self.color_state = "GREEN"

            if pressed[pygame.K_b]:
                if valor_potenciometro is not None:
                    self.b = self.transforma_valor_potenciometro(valor_potenciometro)
                else:
                    self.b = 255
                self.r = 000
                self.g = 000
                self.color_state = "BLUE"
            
            if self.color_state == "RED":
                if pressed[pygame.K_c]:
                    self.r += 0.05
                if pressed[pygame.K_v]:
                    self.r -= 0.05

            if self.color_state == "GREEN":
                if pressed[pygame.K_c]:
                    self.g += 0.05
                if pressed[pygame.K_v]:
                    self.g -= 0.05

            if self.color_state == "BLUE":
                if pressed[pygame.K_c]:
                    self.b += 0.05
                if pressed[pygame.K_v]:
                    self.b -= 0.05

            if self.r > 255:
                self.r = 255
            if self.g > 255:
                self.g = 255
            if self.b > 255:
                self.b = 255

            if self.r < 0:
                self.r = 0

            if self.g < 0:
                self.g = 0

            if self.b < 0:
                self.b = 0

            #Move
            if pressed[pygame.K_UP]: self.y -= 0.05
            if pressed[pygame.K_DOWN]: self.y += 0.05
            if pressed[pygame.K_LEFT]: self.x -= 0.05
            if pressed[pygame.K_RIGHT]: self.x += 0.05

            if pressed[pygame.K_w]: self.y -= 0.05
            if pressed[pygame.K_s]: self.y += 0.05
            if pressed[pygame.K_a]: self.x -= 0.05
            if pressed[pygame.K_d]: self.x += 0.05
        
            #Clear
            if self.clean == True or pressed[pygame.K_SPACE]:
                self.clean = False
                screen.fill((0,0,0))
                image = pygame.image.load(r'./etch_a_sketch.jpg')
                screen.blit(image, (0,0))
                self.x = 315
                self.y = 250

            pygame.display.flip()

            #Exit
            if self.running == False or pressed[pygame.K_e] or pressed[pygame.K_ESCAPE]:
                done = True
            
            # Save
            if self.save == True:
                self.save = False
                pygame.image.save(screen, f"screenshots/screenshot{self.n_screenshots}.jpg")
                self.n_screenshots += 1

            if event.type == pygame.QUIT:
                done = True
        pygame.quit()

class GameInterface:
    def __init__(self, etch_a_sketch_game):
        self.etch_a_sketch = etch_a_sketch_game  # Armazena a referência do jogo
        self.mapping = MyControllerMap()

    def update(self):
        # Aqui você atualiza o estado do jogo chamando o método update do etch_a_sketch
        self.etch_a_sketch.update()
        
if __name__ == '__main__':
    interfaces = ['dummy', 'serial']
    argparse = argparse.ArgumentParser()
    argparse.add_argument('serial_port', type=str)
    argparse.add_argument('-b', '--baudrate', type=int, default=9600)
    argparse.add_argument('-c', '--controller_interface', type=str, default='serial', choices=interfaces)
    argparse.add_argument('-d', '--debug', default=False, action='store_true')
    args = argparse.parse_args()
    if args.debug:
        logging.basicConfig(level=logging.DEBUG)

    print("Connection to {} using {} interface ({})".format(args.serial_port, args.controller_interface, args.baudrate))

    controller = None
    game = Etch_a_sketch()

    if args.controller_interface == 'serial':
        controller = SerialControllerInterface(port=args.serial_port, baudrate=args.baudrate, etch_a_sketch=game)
        controller.start_reading()
    
    game.start_game()

    try:
        while True:  # Loop principal vazio apenas para manter o programa em execução
            time.sleep(0.1)  # Espere 0.1 segundos para reduzir o uso da CPU
    except KeyboardInterrupt:
        print("\nPrograma interrompido pelo usuário. Saindo...")
        if controller:
            controller.stop_reading()
        if args.controller_interface != 'dummy':
            controller.ser.close()