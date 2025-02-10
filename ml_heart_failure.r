#INSTALACAO E CARREGAMENTO DE BIBLIOTECAS E DE DATASET-------------------------------------------------------------------------------------------

#Instalação dos pacotes necessários para o código
install.packages("rpart")
install.packages("rpart.plot")
install.packages("caret")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("plotly")
          
#Carregamento das Bibliotecas necessárias para o código

library(rpart)
library(rpart.plot)
library(caret)
library(dplyr)
library(ggplot2)

# Carregamento do DataSet
# Carrega o Arquivo CSV contendo o conjunto de dados do DataSet e Armazena na Variavel 'dados'
#Lembre-se de mudar o argumento dessa função para o caminho em que se encontra o dataset baxado do repositório na sua máquina
#Esse dataset foi baixado do kaggle, alguns nomes foram traduzidos para portugues como parte do tratamento dos dados

dados <- read.csv("C:/Users/LUCAS/Desktop/R projetos/Databases/Insuficiencia_cardiaca/heart_failure_clinical_records.csv")  



#TRATAMENTO DE DADOS-----------------------------------------------------------------------------------------------------------------------------


#Definindo uma seed para que o mesmo resultado consiga ser sempre reproduzido indepente de quantas vezes o programa seja rodado
set.seed(123)

#Criando uma variavel chamada 'insuficiencia renal'.A insuficiência renal pode ser desenvolvida por um paciente a depender dos niveis de sódio sérico e creatina sérica dessa pessoa,a isso foi atribuída a escolha dessas variaveis.  A criação de uma variavel artificial pode ajudar o modelo a criar padrões 
dados$insuficiencia_renal <- dados$sodio_serico + dados$creatinina_serica 

#Inicialmente a variavel artificial criada não será um valor binário (ou seja, o paciente possui ou nao possui) para resolver isso será calculado a mediana (visto que a mediana divide os dados ao meio) dessa variavel e a mesma será armazenada numa variavel 'threshold'.
threshold <- median(dados$insuficiencia_renal, na.rm = TRUE)

#Transformando os valores em binário com a mediana como referência
dados$insuficiencia_renal_binaria <- ifelse(dados$insuficiencia_renal > threshold, 1, 0)

#Utilizando a função factor para realmente transformar os valores em binário
dados$insuficiencia_renal_binaria <- factor(dados$insuficiencia_renal_binaria, levels = c(0, 1))

#Removendo a variavel de insuficiencia renal nao binaria para garantir que o modelo nao a use
dados <- dados %>% select(-insuficiencia_renal)

#Transformando todas as outras variaveis binárias em factor tambem.
dados$evento_obito <- factor(dados$evento_obito, levels = c(0, 1))
dados$anemia <- factor(dados$anemia, levels = c(0, 1)) 
dados$diabetes <- factor(dados$diabetes, levels = c(0, 1))
dados$pressao_alta <- factor(dados$pressao_alta, levels = c(0, 1)) 
dados$sexo <- factor(dados$sexo, levels = c(0, 1))
dados$fumante <- factor(dados$fumante, levels = c(0, 1))

#Adicionando uma nova coluna de variavel aleatória, essa prática pode ser benéfica ao modelo. Essa terá valores contínuos aleatórios
#A função nrow dados retorna o numero de linhas (número de amostras) do dataframe
#Utilizando a funcao runif para gerar uma sequencia aleatoria de valores continuos para essas n linhas
dados$variavel_aleatoria <- runif(nrow(dados))

#Definindo evento_obito como variável alvo
variavel_alvo <- evento_obito ~ .


#CRIAÇÃO DO MODELO - PRIMEIRA VERSAO DO MODELO---------------------------------------------------------------------------------------------------

#Dividindo a base de dados em treino e teste utilizando a funcao createDataPartition
#Essa função vai gerar um vetor de índices que corresponde a divisao feita (índice = linha, ou seja, indica cada linha pertence a cada particao)
#Essa divisao foi feita com base na variavel evento_obito (a variavel alvo)
#Foi dividido 70% dos dados para treino e os outros 30% para teste
particao_dados <- createDataPartition(dados$evento_obito, p = 0.70, list = FALSE)

#Utilizando o vetor de indices para armazenar em treino_dados
treino_dados <- dados[particao_dados, ]

#O '-' representa 'todos os indices que nao estiverem no vetor particao_dados' 
teste_dados <- dados[-particao_dados, ]

#Definindo um valor de cp
valor_cp_rpart <- 0.03

#Criando o modelo de arvore, utilizando o comando rpart, apenas com a base de treino
#Perceba que a funcao rpart ja faz validacao cruzada atreavez do argumento xval = 10 para evitar o overfitting
modelo_rpart <- rpart(variavel_alvo, 
                      data = treino_dados, 
                      method = "class",
                      control = rpart.control(cp = valor_cp_rpart),
                      xval = 10)

#Utilizando o modelo criado, agora com a base de testes, quais pacientes fora a obito e quais nao foram com a funcao predict
#O primeiro argumento indica qual modelo estamos utilizando, o segundo a base de dados que estamos utilizando, Ja o terceiro indica o tipo de retorno que teremos
#No caso 'type = "prob"' retornara a predicao em forma de probabilidade para cada a classe (No caso temos duas classes, 1 ou 0, se o evento ocorreu ou nao)
#Caso 'type = "class"' seria retornado 1 ou 0 para cada classe, ou seja, se o evento aconteceu ou nao
#Com type = "prob" podemos definir um threshold de chance para que o evento tenha acontecido ou nao
#Para definir esse treshold podemos utilizar curva roc, especifidade e sensibilidade, (so nao sei ainda como)

predicao_prob_rpart <- predict(modelo_rpart, newdata = teste_dados, type = "prob")

#Extraindo a coluna que indica a chance do evento aconter (ou seja a classe positiva)
probabilidades_classe_positiva <- predicao_prob_rpart[, 2]


#Criando um data frame que compara os valores observados (ou seja os valores reais) com os valores previstos
#Esta sendo utilizando um ponto de corte de 50%, ou seja, probabilidades acima de 50% serao consideradas como positivas. Depois disso transformando em fator
base_avaliacao <- data.frame(
  Observado = teste_dados$evento_obito,
  Predição = factor(ifelse(probabilidades_classe_positiva > 0.5, 1, 0), levels = c(0, 1))
)

#Criando uma matriz de confusao a partir desse data frame
#Como argumentos colocaremos os valores preditos e os valores reais (ou observados) e tambem qual e nossa classe postiva, ou seja, qual numero representa que o evento ocorreu
matriz_confusao <- confusionMatrix(base_avaliacao$Predição, base_avaliacao$Observado, positive = "1")

#Printando a matriz de confusao
print(matriz_confusao)

rpart.plot(modelo_rpart)

#CreateDataPartition vem do pacote caret porem acho que estou utilizando o pacote rpart para gerar a arvore, nao sei se posso juntar os dois para gerar a se bem que em ' data = ' no rpart nos utilizamos a 'treino_dados'

#Nao estou utilizando a variavel controle treino para nada ou seja,a cross validation nao esta sendo efetuada, por mais que a acuracia pareca estar boa. O que pode significar que a funcao rpart ja esta utilizando uma cross validation por padrao


#sEGUNDA VERSÃO DO MODELO (RETIRANDO VARIAVEL TEMPO E A VARIAVEL ALEATORIA)----------------------------------------------------------------------

#Retirando a variavel tempo
dados <- dados %>% select(-tempo)

#Retirando também a variavel aleatoria
dados <- subset(dados, select = -variavel_aleatoria)

#Repetindo o processo de criacao da arvore
particao_dados <- createDataPartition(dados$evento_obito, p = 0.70, list = FALSE)
  
  
treino_dados <- dados[particao_dados, ]
  
 
teste_dados <- dados[-particao_dados, ]
  
valor_cp_rpart = 0.03
 
modelo_rpart <- rpart(variavel_alvo, 
                      data = treino_dados, 
                      method = "class",
                      control = rpart.control(cp = valor_cp_rpart),
                      xval = 10)
  

#Testando modelo e extraindo matriz de confusao
predicao_prob_rpart <- predict(modelo_rpart, newdata = teste_dados, type = "prob")


probabilidades_classe_positiva <- predicao_prob_rpart[, 2]


base_avaliacao <- data.frame(
  Observado = teste_dados$evento_obito,
  Predição = factor(ifelse(probabilidades_classe_positiva > 0.5, 1, 0), levels = c(0, 1))
)

matriz_confusao <- confusionMatrix(base_avaliacao$Predição, base_avaliacao$Observado, positive = "1")

print(matriz_confusao)

rpart.plot(modelo_rpart)



#TERCEIRA VERSÃO DO MODELO (AUMENTANDO A SENSIBILIDADE ATRAVEZ DA DIMINUICAO DO VALOR DE PONTO DE CORTE PARA QUE O MODELO CONSIDERE QUE UM PACIENTE MORREU)---------------------------------------------------------------------------------------------------------------------------------

#Um modelo com maior sensibilidade é um modelo que gera menos falsos negativos. Em modelos gerados para prever a ocorrência de doenças de alto índice de contágio em um paciente, em teoria, é melhor que esse tenha uma sensibilidade mais elevada. Visto que os malefícios de um falso negativo são maiores que de um falso positivo.
#Nessa versão, a lógica de que um falso negativo é melhor que um falso positivo será usada. Ou seja, mesmo que o algoritimo indique, ainda que de maneira errônea, que um paciente virá a óbito por conta de um ataque cardiáco, é melhor que o paciente sofra as consequências dos metodos utilizados para previnir um infarto do que esse vir a óbito.

valor_cp_rpart = 0.03

modelo_rpart <- rpart(variavel_alvo, 
                      data = treino_dados, 
                      method = "class",
                      control = rpart.control(cp = valor_cp_rpart),
                      xval = 10)


#Testando modelo e extraindo matriz de confusao
predicao_prob_rpart <- predict(modelo_rpart, newdata = teste_dados, type = "prob")


probabilidades_classe_positiva <- predicao_prob_rpart[, 2]


base_avaliacao <- data.frame(
  Observado = teste_dados$evento_obito,
  Predição = factor(ifelse(probabilidades_classe_positiva > 0.30, 1, 0), levels = c(0, 1))
)

matriz_confusao <- confusionMatrix(base_avaliacao$Predição, base_avaliacao$Observado, positive = "1")

print(matriz_confusao)

rpart.plot(modelo_rpart)


#TERCEIRA VERSÃO DO MODELO (ALTERANDO A IMPORTANCIA DADA A CADA CLASSE DA VARIAVEL ALVO PARA AUMENTAR A ACURACIA)------------------------------------------------------------------------------------------------------------------------------------------------

#É possível notar que a quantidade de pacientes que não foram à óbito é maior do que a quantidade de pacientes que foram à óbito
table(dados$evento_obito)

#O que pode causar imprecisão no modelo caso devidos pesos nao sejam atribuidos a cada classe.
#No caso alem de compensar vamos priorizar que o modelo evite gerar falsos negativos para aumentar a acurácia

valor_cp_rpart = 0.03

modelo_rpart <- rpart(variavel_alvo, 
                      data = treino_dados, 
                      method = "class",
                      control = rpart.control(cp = valor_cp_rpart),
                      xval = 10,
                      parms = list(loss = matrix(c(0,4,1,0), ncol = 2)))

predicao_prob_rpart <- predict(modelo_rpart, newdata = teste_dados, type = "prob")


probabilidades_classe_positiva <- predicao_prob_rpart[, 2]


base_avaliacao <- data.frame(
  Observado = teste_dados$evento_obito,
  Predição = factor(ifelse(probabilidades_classe_positiva > 0.30, 1, 0), levels = c(0, 1))
)

matriz_confusao <- confusionMatrix(base_avaliacao$Predição, base_avaliacao$Observado, positive = "1")

print(matriz_confusao)

rpart.plot(modelo_rpart)

