**Manual de Uso do Relógio na FPGA**

**Design de Computadores: Projeto 1**

Gabriel Hermida e Pedro Civita

**Inicialização Automática:**

Ao ser ligado, o relógio automaticamente começa a funcionar a partir de 00:00:00 (hh:mm:ss), iniciando a contagem do tempo de imediato.

**Controles de Ajuste de Tempo:**

- KEY3 (Incremento da Hora): Pressione este botão para adicionar uma hora ao tempo atual.
- KEY2 (Incremento dos Minutos): Pressione este botão para adicionar um minuto ao tempo atual.
- KEY1 (Incremento dos Segundos): Pressione este botão para adicionar um segundo ao tempo atual.

**Configuração de Valores com KEY0:**

- KEY0: Permite configurar manualmente os valores nas casas de horas, minutos e segundos, para setar uma contagem regressiva (Timer) ou um alarme. Utilize as switches SW0 a SW3 para definir os valores em binário.

**Funções de Timer e Alarme:**

- SW7 (Modo Alarme/Timer): Este switch permite alternar entre as funções de timer e alarme, proporcionando flexibilidade no uso do dispositivo.

**Timer (SW7 desativado):**

- Configuração: Utilize a KEY0 em conjunto com os switches SW0 a SW3 para definir manualmente o tempo inicial para o timer. Cada ativação da KEY0 registra o valor configurado pelos switches para uma unidade de tempo específica (horas, minutos ou segundos), seguindo uma ordem sequencial.
- Funcionamento: O timer decrementa continuamente os segundos, minutos e horas a partir do valor estabelecido até chegar a zero. Esse decremento ocorre em paralelo ao relógio normal, permitindo que ambos operem independentemente.
- Indicação de Término: Quando o timer atinge zero, os LEDs especificamente configurados se apagam, sinalizando o fim do período de contagem regressiva. Isso é útil para eventos de tempo limitado ou lembretes.

**Alarme (SW7 ativado):**

- Configuração: O alarme é ativado para disparar no horário específico definido pela configuração atual dos displays, que é feita usando a KEY0 e os switches SW0 a SW3. Cada pressão da KEY0 registra o valor para horas, minutos ou segundos, na sequência.
- Ativação: O alarme não é ajustado em tempo real pelas KEY1, KEY2 ou KEY3, que são destinadas ao ajuste direto do relógio. Em vez disso, o alarme dispara quando o tempo no relógio corresponde ao tempo definido nos displays, fazendo com que os LEDs configurados se apaguem como um alerta visual.
- Redefinição: O tempo do alarme pode ser reconfigurado a qualquer momento para responder a mudanças de planos ou correções, garantindo flexibilidade no seu uso.

**Dicas de Uso:**

- Sequência de Configuração: Ao configurar tanto o timer quanto o alarme, é crucial seguir a ordem correta de definição das horas, minutos e segundos para evitar configurações incorretas.
- Feedback Visual: Os LEDs correspondentes (LEDR0 a LEDR5) acenderão para confirmar cada configuração. Esse feedback ajuda a verificar a corretude dos valores inseridos.
- Monitoramento: Acompanhe a operação do relógio em relação ao timer ou alarme para garantir que as configurações estejam funcionando como esperado.

**Ajuste de Velocidade:**

Utilize SW8 e SW9 para modificar a velocidade da contagem do tempo:

- SW9 = 0 e SW8 = 0: Velocidade normal (cada segundo passa naturalmente).
- SW9 = 0 e SW8 = 1: Velocidade aumentada em 100 vezes.
- SW9 = 1 e SW8 = 0: Velocidade aumentada em 1000 vezes.
- SW9 = 1 e SW8 = 1: Velocidade aumentada em 10000 vezes.

**Displays de Sete Segmentos:**

- HEX0 a HEX5: Exibem as horas, minutos e segundos atuais. O switch SW6 permite alternar entre mostrar o tempo atual e o tempo configurado para o timer ou alarme.

**Visualização de Estado e Debug:**

- LEDR0 a LEDR5: Indicam qual posição do tempo está sendo ajustada, ajudando a verificar a validade dos valores inseridos.
- LEDR8 (Timer) e LEDR9 (Alarme): Mostram qual função está ativa, auxiliando o usuário na compreensão do modo de operação do dispositivo.
- LEDs de Debug: Sinalizam a ativação do timer ou do alarme e mostram quais posições do tempo foram configuradas corretamente. Se tentativa de configuração inválida for feita, os LEDs correspondentes não acenderão, fornecendo feedback imediato.

**Gerenciamento Simultâneo de Timer e Alarme:**

Se você estiver configurando o timer e, em meio a essa configuração, decidir ativar o alarme, a mudança será refletida imediatamente nos LEDs de apoio, que indicam qual função está ativa e qual posição está sendo configurada. Se mudar de timer para alarme após configurar horas e minutos, por exemplo, e então configurar os segundos sob o modo alarme, os LEDs mostrarão essa transição e apagarão os LEDs das posições não configuradas para o alarme. Assim que concluir a configuração do alarme e, posteriormente, voltar para o timer, o LED do alarme permanecerá aceso, indicando que a configuração do alarme foi completada, mesmo que alterne entre as funções.

**Notas Importantes:**

- Certifique-se de que todas as conexões estejam corretas e que a FPGA esteja corretamente programada antes de iniciar o relógio.
- Ajustes nos switches e pressionamentos de botões devem ocorrer enquanto o sistema está ativo para assegurar reconhecimento das alterações.
- Entenda completamente o mapeamento dos switches e a funcionalidade dos botões para evitar configurações errôneas e assegurar a operação efetiva do relógio.

●
