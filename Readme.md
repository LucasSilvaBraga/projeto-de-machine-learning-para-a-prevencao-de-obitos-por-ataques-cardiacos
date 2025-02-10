# Projeto de Machine Learning para a Prevenção de Obitos por Ataques Cardiácos

## Descrição
Esse algoritimo de machine learning, desenvolvido apenas em linguagem R, tentará prever o evento de obito gerado por um ataque cardiaco. O projeto foi desenvolvido com base em um dataset que possui informações de 5000 pacientes que sofreram do infarto miocárdico, esse conta com 12 variáveis preditoras e uma variavel alvo.

O projeto tem a intenção de utilizar e incentivar o uso de machine learning para previnir fatalidades no âmbito da medicina.

## Pré-requisitos
[R na versão 4.4.2 ou superior](https://posit.co/download/rstudio-desktop/)

[Rstudio na versão 2024.12.0+467 ou superior](https://posit.co/download/rstudio-desktop/)

Arquivo contendo dataset traduzido disponível nesse mesmo repositório [(Dataset original extraído do Kaggle)](https://www.kaggle.com/datasets/aadarshvelu/heart-failure-prediction-clinical-records)

## Utilização do codigo no Rstudio
Clone o projeto na sua máquina utilizando o git bash:

```bash 
git clone https://github.com/usuario/repo.git
```
Ja no R instale e carregue as bibliotecas necessárias:

```r

install.packages("rpart")         
install.packages("rpart.plot")    
install.packages("caret")         
install.packages("dplyr")         
install.packages("ggplot2")      
install.packages("plotly")                 

library(rpart)
library(rpart.plot)
library(caret)
library(dplyr)
library(ggplot2)

```
Substitua o argumento da função read.csv pelo caminho do arquivo do dataset baixado previamente como solicitado

```r
dados <- read.csv("Caminho do arquivo do dataset aqui!!!")
```

Esse projeto está dividido em: 

1. _Instalação e carregamento de bibliotecas e de dataset_
2. _Tratamento de dados_
3. _Criação do modelo_
    * _Primeira Versão do modelo_
    * _Segunda Versão do modelo_
    * _Terceira versão do modelo_

Caso queira analisar o código com mais a atenção é recomendado que execução de uma parte por vez seguindo essa ordem(colocar um gif aqui)

Também é recomendado, para que uma melhor leitura dos comentários dentro do código seja efetuada, que a correção ortográfica do seu Rstudio seja desativada:

_tools_ -> _Global Opotions_ -> _Spelling_ -> _desmarque a caixa use real time spell-checking_


## Uma análise sobre as três versões do modelo


### Criacação de uma variavel artificial através de variaveis reais





