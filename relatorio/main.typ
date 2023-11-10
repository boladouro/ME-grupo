#import "template.typ": *
#include "capa.typ"
#show: project
#counter(page).update(1)

= 1) Situação inicial

Atualmente, a gestão dos contactos pré-operatórios dos pacientes no serviço de cirurgia de um hospital é ineficiente, pois os pacientes têm de esperar dias numa lista de espera para agendar uma operação. Este processo é realizado pelos serviços administrativos do hospital, que podem ser contactados por telefone ou por mensagem na app do hospital. Vamos então visualizar as caracteristicas do processo de gestão de contactos atual:


+ *Horário de Funcionamento*: dois administrativos trabalham das 8h às 18h em dias úteis;
+ *Chegada de Chamadas/Mensagens*: $X_c$: o tempo entre chamadas ou mensagens segue uma distribuição $X_c tilde "Exp"(40/60 min)$;
+ *Tipo de Contato com Pacientes*:
 - Os pacientes entram em contato por telefone com probabilidade de 85% ou por via eletrónica com 15%;
 - Para o agendamento de consultas: 30% das vezes não é agendada uma consulta; 60% das vezes a consulta ocorre por telefone e em 10% das vezes, a consulta é presencial;
+ *Tempo Necessário para Atividades Administrativas*: $X_t$: o tempo das perguntas de triagem segue uma distribuição $X_t tilde N(4,1)$; $X_d$: o tempo que demora decidir o tipo de consulta segue uma distribuição $X_d tilde N(1,0.25)$; e $X_a$: o tempo que demora a agendar uma consulta se necessário (30% das vezes não é) segue uma distribuição $X_a tilde N(1, 0.25)$.
  Ou seja, o tempo necessário para as atividades administrativas $X_T$ segue uma distribuição $X_T ~ N(4,1) + N(1, 0.25) + k dot.c N(1, 0.25), k in {0, 1}$ 
+ *Política de Espera*: as chamadas são encerradas após 5 minutos de espera.
  Assumimos que as mensagens não são encerradas de todo, podendo até elas serem tratadas em dias seguintes. Assumimos também que, como as chamadas são encerradas e as mensagens não, os administradores vão atender primeiro as chamadas em espera do que as mensagens.
  
Através da biblioteca *simmer* do *R*, foi feita uma simulação de eventos discretos, de forma a visualizar a situação atual. Inicialmente, o grupo optou por criar uma única réplica para analisar de forma mais simples os resultados. A @1_replica_1 apresenta os resultados desta.


#figure(
  image("images/1.usage1repl.svg", width: 60%),
  caption: [Evolução dos recursos ao longo do tempo]
) <1_replica_1>


A @1_replica_1 demonstra não só que os administrativos estão sempre a trabalhar e não conseguem acompanhar o número de pedidos (parando apenas de trabalhar quando acabam os seus turnos), mas também que a fila nunca está vazia e está sempre a aumentar. Quanto aos recursos utilizados, conseguimos concluir que foi utilizado o tempo dos 2 administrativos na íntegra, não existindo momentos em que um dos dois não estivesse ocupado. Isto contribuirá para que a fila se extenda cada vez mais ao longo do tempo.

#figure(
  grid(
    columns: 2,
    image("images/1.HistMen1repl.svg", fit: "stretch"),
    image("images/1.HistTel1repl.svg",  fit: "stretch"),
  ),
  caption: "Distribuição do tempo de espera do tipo de contacto (mensagem e telefonema)"
)

// Esq - MENSAGENS 
// Dir - chamadas

À esquerda podemos visualizar um histograma com o tempo de espera das mensagens, onde nota-se que o período de espera é bastante distribuido existindo, não só mensagens com tempo de espera curto, como também mensagens com um tempo de espera muito elevado, chegando até a atingir longas escalas de minutos e consequentemente de horas. 

É importante referir que, como assumimos que uma mensagem pode ser respondida no dia seguinte, o tempo de espera de uma mensagem pode incluir o tempo entre as 18h e as 8h, onde os administradores não estão presentes. 

À direita podemos ver um gráfico em que a maior parte dos clientes espera perto de 5 minutos para as chamadas serem atendidas pelos administrativos. Na coluna associada a $x = 5 min$, a chamada é desligada pelo cliente e daí de este ser o valor máximo do histograma. Esta evolução tem uma distribuição exponencial. 

Com este breve entendimento, passamos então para a visualização dos resultados com a criação de 50 réplicas, onde obtivemos os seguintes resultados:

// image("images/1.phone&message.svg",  fit: "stretch")
// image("images/1.phone_rejected.svg", fit: "stretch")

#figure(
  grid(
    columns: 2,
      image("images/1.phone&message.svg", fit: "stretch"),
      image("images/1.phone_rejected.svg",  fit: "stretch"), 
  ),
  caption:[Rejeição de chamadas durante a semana (colorido) e o tamanho da fila para as réplicas (cinzento)]
)

Com a criação das 50 réplicas, as conclusões não se alteram muito da primeira réplica analisada. Existem alguns casos melhores, e outros piores, mas são todos muito aquém daquilo que se espera de um serviço de gestão de um hospital. Os gráficos apresentados demonstram a clara evolução linear entre o número de chamadas rejeitadas e a evolução de apenas cada dia separadamente (à direita), mas também ao longo dos 5 dias, com as interrupções pós-laborais (à esquerda). É possível identificar o tamanho da fila ao longo dos diferentes dias no gráfico à esquerda (período semanal completo), na parte inferior.


Na @gaveuprate1 podemos observar a taxa de rejeição das chamadas (quando passa de $5 min$) por todas as chamadas nas várias réplicas. Podemos concluir que uma grande  minoria tem as suas chamadas atendidas, e mais de metade são rejeitadadas em todas as réplicas, demonstrando a necessidade de mudanças no sistema.


#figure(
  image("images/1.gave_up_rate.svg", width:60%),
  caption: [Rácio de chamadas rejeitadas em cada replicação]
) <gaveuprate1>

Concluindo, esta situação apresenta vários problemas, como a quantidade de chamadas rejeitadas e o elevado tempo de espera. Os utentes podem ser perdidos pela inefeciência do sistema devido à falta de pessoal e má gestão de recursos. 

= 2) Implementação das medidas de melhoria

Nesta fase do trabalho, foram tidos em conta as seguintes recomendações/informações fornecidas: A revelação do novo número de contactos, por períodos diferentes de tempo, pelo estudo realizado por alunos de ciências de dados; *e* a hipótese, sugerida pela diretora do serviço de cirurgia, para se alterar o horário de funcionamento de administradores. Além destas alterações, ainda teremos em conta 2 situações de estudo diferentes: Os administrativos podem interromper, ou não, a análise da mensagem quando chega uma chamada telefónica. (Importante notar que na situação incial já era assumida a prioridade das chamadas.)

Declaremos a simulação $bold(a))$ como aquela que interrompe a mensagem, e o $bold(b))$ o contrário.  Daqui para frente, cada cenário vai ter 50 réplicas, sendo possível visualizar os resultados obtidos nas figuras abaixo:
#set image(width: 85%)
#figure(
  grid(
    columns: 2,
    image("images/2a_HistTel.svg", fit: "stretch"),
    image("images/2b_HistTel.svg",  fit: "stretch"),
  ),
  caption: [Distribuição do tempo de espera das chamadas nas 2 situações ( $bold(a))$ na esquerda, $bold(b))$ na direita)]
) <tempo_espera_chamadas>
#set image(width: 100%)
Na @tempo_espera_chamadas observa-se o tempo de espera das várias pessoas nas várias réplicas da situação proposta. Ao contrário da situação inicial (que apresentava uma distribuição exponencial), esta aparenta possuir um tempo de espera (das mensagens) linear, indicando que mais pessoas foram atendidas (menor número de pessoas com 5 minutos de espera). No entanto, não se nota diferença entre os cenários $bold(a))$ e $bold(b))$.
Importante notar que na situação incial já era assumida a prioridade das chamadas.
#set image(width: 100%)
#figure(
  grid(
    columns: 2,
    image("images_corretasPla/2agave_up_rate.svg", fit: "stretch"),
    image("images_corretasPla/2bgave_up_rate.svg",  fit: "stretch"),
  ),
  caption: [Rácio da desistência em chamadas nas 2 situações ($bold(a))$ na esquerda, $bold(b))$ na direita)]
) <racio>
#set image(width: 100%)
A @racio mostra o rácio de desistência nas diferentes situações. Podemos observar que a taxa de rejeição aumentou, quando comparado com a situação atual. Isto deve ser consequência da análise dos cientistas de dados, que revelaram o aumento de mensagens, via app, em alguns horários, o que influenciou a quantidade de chamadas. Nota-se que o aumento da taxa mostra que o horário proposto não é adequado para a situação. A aparente melhoria que a @tempo_espera_chamadas mostra torna-se irrelevante, pois há mais pessoas a serem rejeitadas.

Quando comparando os diferentes cenários, parece que a taxa de rejeição entre estes não é muito diferente, somado a isto,  a @tempo_espera_chamadas demonstra que a política de interrupção não parece melhorar ou piorar muito as chamadas.

Para visualizar as filas nestes cenários, apresentamos na @1_replica_2 apenas uma réplica, para comparar com a situação atual.
#figure(
  grid(
    columns: 2,
    image("images/2a.1replicausage.svg", fit: "stretch"),
    image("images/2b.1replicausage.svg",  fit: "stretch"),
  ),
  caption: [Tamanho da fila de uma réplica da $bold(a))$ na esquerda, da $bold(b))$ na direita)]
) <1_replica_2>

Visualizando detalhadamente a @1_replica_1, é notável que as sugestões propostas tiveram um impacto positivo, reduzindo o número de pacientes na fila de espera. Antes de prosseguirmos à comparação destas 2 situações, é importante realçar que as medidas adotadas levaram a uma notável melhoria no tempo de espera dos pacientes, permitindo que mais deles fossem atendidos de forma eficaz. Das 9h30 às 12h, ao estarem 4 administrativos a trabalharem, o número de pacientes na "fila de espera" diminuiu de forma significativa (a mesma coisa ocorre, mas de forma menos significativa, das 12h às 15h30 com 3 administrativos), dando assim resposta às necessidades dos pacientes. Apesar disso, esta melhoria não dá as condições suficientes para a equipa de gestão conseguir responder às necessidades dos paciente, até porque, com o passar dos dias, a fila de espera sempre aumenta, nunca ficando vazia ( exceto no dia 1 da situação $bold(b))$ ). Comparando agora as situações $bold(a))$ e $bold(b))$, existem breves diferenças entre estas, por exemplo: na situação $bold(b))$, nos momentos onde há um maior número de administrativos a trabalhar, estes apresentam-se mais eficientes quando comparados com os mesmos administrativos da situação $bold(a))$, pois, a fila de espera diminui mais rápido; no entanto, quando há menos administrativos, a situação inverte, ou seja, estes parecem mais ineficientes quando comparados com os da situação $bold(a))$ .

#set image(width:80%)
#figure(
  grid(
    columns: 2,
    image("images_corretasPla/2a_histograma_mensagens.svg", fit: "stretch"),
    image("images_corretasPla/2b_histograma_mensagens.svg",  fit: "stretch"),
  ),
  caption: "Distribuição do tempo de espera das mensagens nas 2 situações (a na esquerda, b na direita)"
) <tempo_espera_mensagens>
#set image(width:100%)
A análise destas duas réplicas parece sugerir que na situação $bold(b))$ a fila parece diminuir um pouco mais do que a fila da situação $bold(a))$, mas não podemos tirar estas conclusões apenas de uma réplica.

#set image(width: 80%)
#figure(
  grid(
    columns: 2,
    rows: 2,
    image("images_corretasPla/2a_queue_size_and_rejected(sep).svg"),
    image("images_corretasPla/2a_queue_size_and_rejected(junto).svg"),
    image("images_corretasPla/2b_queue_size_and_rejected(sep).svg"),
    image("images_corretasPla/2b_queue_size_and_rejected(junto).svg"),
  ),
  caption:[Rejeição de chamadas durante a semana (colorido) e o tamanho da fila (cinzento), diário e semanal]
) <chamadas_rejeitadas_2>
#set image(width: 100%)

A @chamadas_rejeitadas_2 demonstra as quantidade total de chamadas rejeitadas ao longo do tempo, dos dois cenários. Conseguimos notar a mesma relação linear que as chamadas rejeitas têm ao longo da semana, mas a observação diária (à esquerda) mostra o notável aumento de contactos por hora (que os cientistas de dados notaram) entre as 8h e 10h, e a diminuição do aumento quase instantâneo depois disso. A presença dos quatro administradores parece até garantir que nenhuma chamada é rejeitada. Ao meio dia, o número de administraticos diminui para 3, e podemos logo notar que o número começa logo a aumentar, sugerindo um ponto ótimo de 4 admnistradores, talvez até as 16h, onde o número de contactos por hora diminui drasticamente.Nota-se também que a partir das 16h o número parece estabilizar outra vez levemente, sugerindo que 2 administradores sejam suficientes para atender as chamadas e ver mensagens ainda não respondidas. 

Contudo, não parece haver nenhuma diferença notável entre as situações $bold(a))$ e $bold(b))$, o que sugere que não haja necessidade de interromper as mensagens para antender as chamadas.


Concluindo, o novo cenário construido pelos cientistas de dados não parece dar necessidade de interromper as mensagens, sendo que os resultados entre $bold(a))$ e $bold(b))$ são demasiado similares. O novo horário proposto pela Diretora parece melhorar o tempo de espera de mensagens, mas aumentar a quantidade de chamadas rejeitadas. No entanto, uma análise do horário inicial com as mudanças do estudo seria mais adequado para chegar a esta conclusão, sendo que estariamos a isolar as propostas. Ainda assim, recomendamos à Diretora que repense o horário, especialmente entre as 8h e 10h, onde o número de contactos por hora não consegue ser acomodado apenas por um ou dois administrativos.

