



# Titulo: Dados dos indicadores CepespData (BETA)
# Autor: Rebeca Carvalho


rm(list = ls())


# Pacotes utilizados


library(cepespR)
library(magrittr)
library(dplyr)
library(tidyverse)
library(lubridate)
library(abjutils)
library(data.table)
library(ggplot2)
library(ggfortify)
library(ggExtra)
library(fansi)
library(stringi)
library(readr)


# 1. Dados ----------------------------------------------------------------

# Vagas

vags_fed <- read_csv("vags_fed.csv")
vags_est <- read_csv("vags_est.csv")

# Deputado Federal

df <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Federal",
                    regional_aggregation = "Estado", political_aggregation = "Partido")

dfc <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Federal",
                     regional_aggregation = "Estado", political_aggregation = "Consolidado")

dfc2 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Federal",
                      regional_aggregation = "Brasil", political_aggregation = "Consolidado")

dfc_ <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Federal",
                      regional_aggregation = "Estado", political_aggregation = "Candidato")

# Deputado Estadual

de <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Estadual",
                    regional_aggregation = "Estado", political_aggregation = "Partido")

dec <- get_elections(year = "1998,2002, 2006, 2010, 2014, 2018", position = "Deputado Estadual",
                     regional_aggregation = "Estado", political_aggregation = "Consolidado")

dec2 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Estadual",
                      regional_aggregation = "Brasil", political_aggregation = "Consolidado")

dec_ <- get_elections(year = "1998,2002, 2006, 2010, 2014, 2018", position = "Deputado Estadual",
                      regional_aggregation = "Estado", political_aggregation = "Candidato")


# 2. Tranformacoes primarias ----------------------------------------------

# Votação UF dos partidos

# Deputado Federal

df <- df %>%  
  dplyr::group_by(ANO_ELEICAO, UF, SIGLA_PARTIDO) %>% 
  dplyr::summarise(
    VOT_PART_UF = sum(QTDE_VOTOS))

# Deputado Estadual

de <- de %>% 
  dplyr::group_by(ANO_ELEICAO, UF,SIGLA_PARTIDO) %>% 
  dplyr::summarise(
    VOT_PART_UF = sum(QTDE_VOTOS)
  ) 

# Votos validos de cada eleicao

# Deputado Federal

dfc1 <- dfc %>% 
  dplyr::group_by(ANO_ELEICAO, UF) %>% 
  dplyr::summarise(
    VOTOS_VALIDOS_UF = sum(QT_VOTOS_NOMINAIS,QT_VOTOS_LEGENDA)
  )

# Deputado Estadual

dec1 <- dec %>% 
  dplyr::group_by(ANO_ELEICAO,UF) %>% 
  dplyr::summarise(
    VOTOS_VALIDOS_UF = sum(QT_VOTOS_NOMINAIS,QT_VOTOS_LEGENDA)
  )

#Tratar deputado estadual e deputado distrital
dec <- dec %>% 
  dplyr::group_by(ANO_ELEICAO,UF) %>% 
  dplyr::summarise(
    QTD_APTOS = sum(QTD_APTOS),             
    QTD_APTOS=sum(QTD_APTOS),
    QTD_ABSTENCOES=sum(QTD_ABSTENCOES),
    QT_VOTOS_NOMINAIS=sum(QT_VOTOS_NOMINAIS),
    QT_VOTOS_BRANCOS=sum(QT_VOTOS_BRANCOS),
    QT_VOTOS_NULOS=sum(QT_VOTOS_NULOS),
    QT_VOTOS_LEGENDA=sum(QT_VOTOS_LEGENDA),         
    QT_VOTOS_ANULADOS_APU_SEP=sum(QT_VOTOS_ANULADOS_APU_SEP))
dec$DESCRICAO_CARGO<-"Deputado Estadual"


dec2 <- dec2 %>% 
  dplyr::group_by(ANO_ELEICAO) %>% 
  dplyr::summarise(
    QTD_APTOS = sum(QTD_APTOS),             
    QTD_APTOS=sum(QTD_APTOS),
    QTD_ABSTENCOES=sum(QTD_ABSTENCOES),
    QT_VOTOS_NOMINAIS=sum(QT_VOTOS_NOMINAIS),
    QT_VOTOS_BRANCOS=sum(QT_VOTOS_BRANCOS),
    QT_VOTOS_NULOS=sum(QT_VOTOS_NULOS),
    QT_VOTOS_LEGENDA=sum(QT_VOTOS_LEGENDA),         
    QT_VOTOS_ANULADOS_APU_SEP=sum(QT_VOTOS_ANULADOS_APU_SEP))
dec2$DESCRICAO_CARGO<-"Deputado Estadual"

# 3. Join -----------------------------------------------------------------

# Deputado Federal

vags_fed <- left_join(vags_fed,dfc1, by = "UF")

vags_fed <- left_join(vags_fed, df, by = c("ANO_ELEICAO", "UF"))


# Deputado Estadual

vags_est <- left_join(vags_est,dec1, by = "UF")


vags_est <- left_join(vags_est, de, by = c("ANO_ELEICAO", "UF"))


# 4. Calculo --------------------------------------------------------------


# 4.1. Indicadores de distribuicao das cadeiras ---------------------------  


# 4.1.1. Quociente eleitoral -------------------------------------------------

# Deputado Federal

vags_fed$QUOCIENTE_ELEITORAL <- vags_fed$VOTOS_VALIDOS_UF/as.numeric(vags_fed$VAGAS)

# Deputado Estadual

vags_est$QUOCIENTE_ELEITORAL <- vags_est$VOTOS_VALIDOS_UF/as.numeric(vags_est$VAGAS)


# 4.1.2. Quociente partidario ------------------------------------------------

# Deputado Federal

vags_fed$QUOCIENTE_PARTIDARIO <- vags_fed$VOT_PART_UF/vags_fed$QUOCIENTE_ELEITORAL


# Deputado Estadual


vags_est$QUOCIENTE_PARTIDARIO <- vags_est$VOT_PART_UF/vags_est$QUOCIENTE_ELEITORAL



# 4.2. Indicadores de fragmentacao legislativa ----------------------------


# 4.2.1. Numero de cadeiras -----------------------------------------------

# Deputado Federal

num_df <- dfc_ %>% 
  filter(DESC_SIT_TOT_TURNO == "ELEITO"|DESC_SIT_TOT_TURNO == "ELEITO POR QP"|DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA")

num_df <- num_df %>% 
  dplyr::group_by(ANO_ELEICAO,DESCRICAO_CARGO, SIGLA_PARTIDO, UF) %>% 
  dplyr::summarise("Cadeiras conquistadas por UF" = n())

num_df1 <- num_df %>% 
  dplyr::group_by(ANO_ELEICAO,DESCRICAO_CARGO, SIGLA_PARTIDO) %>% 
  dplyr::summarise(
    "Total de cadeiras conquistadas" = sum(`Cadeiras conquistadas por UF`))

numc_df <- left_join(num_df, num_df1, by = c("ANO_ELEICAO", "DESCRICAO_CARGO", "SIGLA_PARTIDO"))

numc_df <- numc_df %>% 
  dplyr::select(ANO_ELEICAO, UF,DESCRICAO_CARGO, SIGLA_PARTIDO, `Cadeiras conquistadas por UF`, `Total de cadeiras conquistadas`) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Sigla do partido" = "SIGLA_PARTIDO")

numc_df$Cargo <- str_to_title(numc_df$Cargo)

# Deputado Estadual

num_de <- dec_ %>% 
  filter(DESC_SIT_TOT_TURNO == "ELEITO"|DESC_SIT_TOT_TURNO == "ELEITO POR QP"|DESC_SIT_TOT_TURNO == "ELEITO POR MEDIA")

num_de <- num_de %>% 
  dplyr::group_by(ANO_ELEICAO, DESCRICAO_CARGO, SIGLA_PARTIDO, UF) %>% 
  dplyr::summarise("Cadeiras conquistadas" = n())

numc_de <- num_de %>% 
  dplyr::select(ANO_ELEICAO, UF,DESCRICAO_CARGO, SIGLA_PARTIDO, `Cadeiras conquistadas`)


 numc_de <- dplyr::rename(numc_de, "Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Sigla do partido" = "SIGLA_PARTIDO")

numc_de$Cargo <- str_to_title(numc_de$Cargo)


# 4.2.2. Fracionalizacao --------------------------------------------------

# Deputado Federal

num_df1$`Percentual de cadeiras` <- num_df1$`Total de cadeiras conquistadas`/513

numc_df$`Percentual de cadeiras` <- numc_df$`Total de cadeiras conquistadas`/513


fracio <- function(x){
  
  1-(sum(x^2))
}

t98df <- num_df1 %>% 
  filter(ANO_ELEICAO == 1998) 

t98df$Fracionalização <- fracio(t98df$`Percentual de cadeiras`)

t02df <- num_df1 %>% 
  filter(ANO_ELEICAO == 2002) 

t02df$Fracionalização <- fracio(t02df$`Percentual de cadeiras`)

t06df <- num_df1 %>% 
  filter(ANO_ELEICAO == 2006) 

t06df$Fracionalização <- fracio(t06df$`Percentual de cadeiras`)

t10df <- num_df1 %>% 
  filter(ANO_ELEICAO == 2010) 

t10df$Fracionalização <- fracio(t10df$`Percentual de cadeiras`)

t14df <- num_df1 %>% 
  filter(ANO_ELEICAO == 2014)

t14df$Fracionalização <- fracio(t14df$`Percentual de cadeiras`)

t18df <- num_df1 %>% 
  filter(ANO_ELEICAO == 2018) 

t18df$Fracionalização <- fracio(t18df$`Percentual de cadeiras`)

# 4.2.3. Fracionalizacao maxima  ------------------------------------------


fracio_max <- function(N, n){
  
  (N*(n-1))/(n*(N-1))
  
}


t98df$`Fracionalização máxima`<- fracio_max(513,18)

t02df$`Fracionalização máxima`<- fracio_max(513,19) 

t06df$`Fracionalização máxima`<- fracio_max(513,21)

t10df$`Fracionalização máxima`<- fracio_max(513,22)

t14df$`Fracionalização máxima`<- fracio_max(513,28)

t18df$`Fracionalização máxima`<- fracio_max(513,30)

# 4.2.4. Fragmentacao -----------------------------------------------------


frag <- function(fracio, fracio_max){
  
  fracio/fracio_max
}



t98df$Fragmentação <- frag(t98df$Fracionalização, t98df$`Fracionalização máxima`)

t02df$Fragmentação <- frag(t02df$Fracionalização, t02df$`Fracionalização máxima`)

t06df$Fragmentação <- frag(t06df$Fracionalização, t06df$`Fracionalização máxima`)

t10df$Fragmentação <- frag(t10df$Fracionalização, t10df$`Fracionalização máxima`)

t14df$Fragmentação <- frag(t14df$Fracionalização, t14df$`Fracionalização máxima`)

t18df$Fragmentação <- frag(t18df$Fracionalização, t18df$`Fracionalização máxima`)


frag_partdf <- bind_rows(t98df, t02df, t06df, t10df, t14df, t18df) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Sigla do partido" = SIGLA_PARTIDO)

frag_partdf$Cargo <- str_to_title(frag_partdf$Cargo)


# 4.2.5.  Desproporcionalidade de Gallagher -------------------------------

# Deputado Federal

# 4.2.6. Número efetivo de partidos por votos ---------------------------------------



# 4.2.7. Número efetivo de partidos por cadeiras ---------------------------------------

options(scipen=999)
NEP<-NA
NEPC <- function(p){
  for(i in 1:length(p)){
    NEP[[i]]<-(p[[i]]*p[[i]])
  }
  1/sum(NEP)}

p<-t98df$`Percentual de cadeiras`
p[[1]]*p[[1]]
X<-NEPC(p)

t98df$`Numero efetivo de partidos por cadeiras` <- NEPC(t98df$`Percentual de cadeiras`)
t02df$`Numero efetivo de partidos por cadeiras` <- NEPC(t02df$`Percentual de cadeiras`)
t06df$`Numero efetivo de partidos por cadeiras` <- NEPC(t06df$`Percentual de cadeiras`)
t10df$`Numero efetivo de partidos por cadeiras` <- NEPC(t10df$`Percentual de cadeiras`)
t14df$`Numero efetivo de partidos por cadeiras` <- NEPC(t14df$`Percentual de cadeiras`)
t18df$`Numero efetivo de partidos por cadeiras` <- NEPC(t18df$`Percentual de cadeiras`)


frag_partdf <- bind_rows(t98df, t02df, t06df, t10df, t14df, t18df) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Sigla do partido" = SIGLA_PARTIDO)

frag_partdf$Cargo <- str_to_title(frag_partdf$Cargo)

frag_partdf$Fracionalização <- format(round(frag_partdf$Fracionalização, digits = 2),  nsmall = 2)
frag_partdf$`Fracionalização máxima` <- format(round(frag_partdf$`Fracionalização máxima`, digits = 2), nsmall = 2)
frag_partdf$Fragmentação <- format(round(frag_partdf$Fragmentação, digits = 2), nsmall = 2)
frag_partdf$`Numero efetivo de partidos por cadeiras` <- format(round(frag_partdf$`Numero efetivo de partidos por cadeiras`, digits = 2), nsmall = 2)

# 4.3. Indicadores de renovacao das bancadas ------------------------------



# 4.4. Indicadores de alienacao -------------------------------------------

# Deputado Federal BR

dfc2 <- dfc2 %>% 
  select(ANO_ELEICAO, DESCRICAO_CARGO, QTD_ABSTENCOES, QT_VOTOS_BRANCOS, QT_VOTOS_NULOS, QTD_APTOS) %>% 
  rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Quantidade de abstenções" = "QTD_ABSTENCOES",
         "Quantidade de votos brancos" = "QT_VOTOS_BRANCOS", "Quantidade de votos nulos" = "QT_VOTOS_NULOS", 
         "Quantidade de eleitores aptos" = "QTD_APTOS") 

dfc2$Cargo <- str_to_title(dfc2$Cargo)

dfc2$`Alienação Absoluta` <- dfc2$`Quantidade de abstenções` + dfc2$`Quantidade de votos brancos` + dfc2$`Quantidade de votos nulos` 
dfc2$`Alienação Percentual` <- round(100*(dfc2$`Quantidade de abstenções` + dfc2$`Quantidade de votos brancos` + dfc2$`Quantidade de votos nulos`)/dfc2$`Quantidade de eleitores aptos`,2)

dfc2 <- dfc2 %>% 
  arrange(`Ano da eleição`)



# Deputado Federal UF


dfc <- dfc %>% 
  dplyr::select(ANO_ELEICAO,UF, DESCRICAO_CARGO, QTD_ABSTENCOES, QT_VOTOS_BRANCOS, QT_VOTOS_NULOS, QTD_APTOS) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Quantidade de abstenções" = "QTD_ABSTENCOES",
                "Quantidade de votos brancos" = "QT_VOTOS_BRANCOS", "Quantidade de votos nulos" = "QT_VOTOS_NULOS", 
                "Quantidade de eleitores aptos"="QTD_APTOS")

dfc$`Alienação Absoluta` <- dfc$`Quantidade de abstenções` + dfc$`Quantidade de votos brancos` + dfc$`Quantidade de votos nulos` 
dfc$`Alienação Percentual` <- round(100*(dfc$`Quantidade de abstenções` + dfc$`Quantidade de votos brancos` + dfc$`Quantidade de votos nulos`)/dfc$`Quantidade de eleitores aptos`,2)


dfc$Cargo <- str_to_title(dfc$Cargo) 

dfc <- dfc %>% 
  arrange(`Ano da eleição`)

# Deputado Estadual BR

dec2 <- dec2 %>% 
  select(ANO_ELEICAO, DESCRICAO_CARGO, QTD_ABSTENCOES, QT_VOTOS_BRANCOS, QT_VOTOS_NULOS, QTD_APTOS) %>% 
  rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Quantidade de abstenções" = "QTD_ABSTENCOES",
         "Quantidade de votos brancos" = "QT_VOTOS_BRANCOS", "Quantidade de votos nulos" = "QT_VOTOS_NULOS", 
         "Quantidade de eleitores aptos"="QTD_APTOS") 

dec2$Cargo <- str_to_title(dec2$Cargo)

dec2$`Alienação Absoluta` <- dec2$`Quantidade de abstenções` + dec2$`Quantidade de votos brancos` + dec2$`Quantidade de votos nulos`
dec2$`Alienação Percentual` <- round(100*(dec2$`Quantidade de abstenções` + dec2$`Quantidade de votos brancos` + dec2$`Quantidade de votos nulos`)/dec2$`Quantidade de eleitores aptos`,2)

dec2 <- dec2 %>% 
  arrange(`Ano da eleição`)


# Deputado Estadual UF

dec <- dec %>% 
  dplyr::select(ANO_ELEICAO,UF, DESCRICAO_CARGO, QTD_ABSTENCOES, QT_VOTOS_BRANCOS, QT_VOTOS_NULOS, QTD_APTOS) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "DESCRICAO_CARGO", "Quantidade de abstenções" = "QTD_ABSTENCOES",
                "Quantidade de votos brancos" = "QT_VOTOS_BRANCOS", "Quantidade de votos nulos" = "QT_VOTOS_NULOS", 
                "Quantidade de eleitores aptos"="QTD_APTOS")

dec$`Alienação Absoluta` <- dec$`Quantidade de abstenções` + dec$`Quantidade de votos brancos` + dec$`Quantidade de votos nulos`
dec$`Alienação Percentual` <- round(100*(dec$`Quantidade de abstenções` + dec$`Quantidade de votos brancos` + dec$`Quantidade de votos nulos`)/dec$`Quantidade de eleitores aptos`,2)


dec$Cargo <- str_to_title(dec$Cargo)

dec <- dec %>% 
  arrange(`Ano da eleição`)

# OUTROS CARGOS - BR
alien1 <- get_elections(year = "2002,2006,2010,2014,2018", position = "Presidente",
                        regional_aggregation = "Brasil", political_aggregation = "Consolidado")
alien2 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Governador",
                        regional_aggregation = "Brasil", political_aggregation = "Consolidado")
alien3 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Senador",
                        regional_aggregation = "Brasil", political_aggregation = "Consolidado")
alien4 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Federal",
                        regional_aggregation = "Brasil", political_aggregation = "Consolidado")
alien5 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Estadual",
                        regional_aggregation = "Brasil", political_aggregation = "Consolidado")

alienacao_br<-rbind(alien1, alien2, alien3, alien4, alien5)
rm(alien1, alien2, alien3, alien4, alien5)


alienacao_br$DESCRICAO_CARGO<-ifelse(alienacao_br$DESCRICAO_CARGO=="DEPUTADO DISTRITAL", "Deputado Estadual", alienacao_br$DESCRICAO_CARGO)

alienacao_br <- alienacao_br %>% 
  dplyr::select(ANO_ELEICAO, NUM_TURNO, DESCRICAO_CARGO, QTD_ABSTENCOES, QT_VOTOS_BRANCOS, QT_VOTOS_NULOS, QTD_APTOS) %>% 
  group_by(ANO_ELEICAO,NUM_TURNO, DESCRICAO_CARGO) %>% 
  summarise(QTD_ABSTENCOES = sum(QTD_ABSTENCOES),
            QT_VOTOS_BRANCOS = sum(QT_VOTOS_BRANCOS),
            QT_VOTOS_NULOS = sum(QT_VOTOS_NULOS), 
            QTD_APTOS = sum(QTD_APTOS)) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Turno"="NUM_TURNO",
                "Cargo" = "DESCRICAO_CARGO", "Quantidade de abstenções" = "QTD_ABSTENCOES",
                "Quantidade de votos brancos" = "QT_VOTOS_BRANCOS", "Quantidade de votos nulos" = "QT_VOTOS_NULOS", 
                "Quantidade de eleitores aptos"="QTD_APTOS")

alienacao_br$`Alienação Absoluta` <- alienacao_br$`Quantidade de abstenções` + alienacao_br$`Quantidade de votos brancos` + alienacao_br$`Quantidade de votos nulos`
alienacao_br$`Alienação Percentual` <- round(100*(alienacao_br$`Quantidade de abstenções` + alienacao_br$`Quantidade de votos brancos` + alienacao_br$`Quantidade de votos nulos`)/alienacao_br$`Quantidade de eleitores aptos`,2)


alienacao_br$Cargo <- str_to_title(alienacao_br$Cargo)

alienacao_br <- alienacao_br %>% 
  arrange(`Ano da eleição`)

# OUTROS CARGOS - UF
alien1 <- get_elections(year = "2002,2006,2010,2014,2018", position = "Presidente",
                      regional_aggregation = "State", political_aggregation = "Consolidado")
alien2 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Governador",
                    regional_aggregation = "State", political_aggregation = "Consolidado")
alien3 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Senador",
                    regional_aggregation = "State", political_aggregation = "Consolidado")
alien4 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Federal",
                        regional_aggregation = "State", political_aggregation = "Consolidado")
alien5 <- get_elections(year = "1998, 2002, 2006, 2010, 2014, 2018", position = "Deputado Estadual",
                        regional_aggregation = "State", political_aggregation = "Consolidado")

alienacao_uf<-rbind(alien1, alien2, alien3, alien4, alien5) %>% filter(UF!="ZZ")
rm(alien1, alien2, alien3, alien4, alien5)

alienacao_uf$DESCRICAO_CARGO<-ifelse(alienacao_uf$DESCRICAO_CARGO=="DEPUTADO DISTRITAL", "Deputado Estadual", alienacao_uf$DESCRICAO_CARGO)

alienacao_uf <- alienacao_uf %>% 
  dplyr::select(ANO_ELEICAO,UF, NUM_TURNO, DESCRICAO_CARGO, QTD_ABSTENCOES, QT_VOTOS_BRANCOS, QT_VOTOS_NULOS, QTD_APTOS) %>% 
  group_by(ANO_ELEICAO,UF, NUM_TURNO, DESCRICAO_CARGO) %>% 
  summarise(QTD_ABSTENCOES = sum(QTD_ABSTENCOES),
            QT_VOTOS_BRANCOS = sum(QT_VOTOS_BRANCOS),
            QT_VOTOS_NULOS = sum(QT_VOTOS_NULOS), 
            QTD_APTOS = sum(QTD_APTOS)) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Turno"="NUM_TURNO",
                "Cargo" = "DESCRICAO_CARGO", "Quantidade de abstenções" = "QTD_ABSTENCOES",
                "Quantidade de votos brancos" = "QT_VOTOS_BRANCOS", "Quantidade de votos nulos" = "QT_VOTOS_NULOS", 
                "Quantidade de eleitores aptos"="QTD_APTOS")

alienacao_uf$`Alienação Absoluta` <- alienacao_uf$`Quantidade de abstenções` + alienacao_uf$`Quantidade de votos brancos` + alienacao_uf$`Quantidade de votos nulos`
alienacao_uf$`Alienação Percentual` <- round(100*(alienacao_uf$`Quantidade de abstenções` + alienacao_uf$`Quantidade de votos brancos` + alienacao_uf$`Quantidade de votos nulos`)/alienacao_uf$`Quantidade de eleitores aptos`,2)


alienacao_uf$Cargo <- str_to_title(alienacao_uf$Cargo)

alienacao_uf <- alienacao_uf %>% 
  arrange(`Ano da eleição`)


# 5. Tabelas --------------------------------------------------------------

# 5.1. Quociente eleitoral ------------------------------------------------

gabi<-function(string){
  ifelse(string>1000000, 
         (paste0(floor(string/1000000),".",floor(string/1000)-floor(string/1000000)*1000,".", substr(floor(string), start = nchar(floor(string))- 2, stop = nchar(floor(string))),
           ifelse(round(string,2)==floor(string),"",
                  paste0(",",substr(1 + round(string,2)-round(string,0),start = 3, stop = 4))))),
    (paste0(floor(string/1000),".", substr(floor(string), start = nchar(floor(string))- 2, stop = nchar(floor(string))),
         ifelse(round(string,2)==round(string,0),"",
                paste0(",",substr(1 + round(string,2)-floor(string),start = 3, stop = 4))))))
}


vags_fed$QUOCIENTE_ELEITORAL <- gabi(vags_fed$QUOCIENTE_ELEITORAL)

vags_fed$QUOCIENTE_PARTIDARIO <- round(vags_fed$QUOCIENTE_PARTIDARIO, digits = 2)

vags_est$QUOCIENTE_ELEITORAL <-gabi(vags_est$QUOCIENTE_ELEITORAL)

vags_est$QUOCIENTE_PARTIDARIO <- round(vags_est$QUOCIENTE_PARTIDARIO, digits = 2)

dec$`Alienação Absoluta` <- gabi(dec$`Alienação Absoluta`)

dec2$`Alienação Absoluta` <- gabi(dec2$`Alienação Absoluta`)

dfc$`Alienação Absoluta` <- gabi(dfc$`Alienação Absoluta`)

dfc2$`Alienação Absoluta` <- gabi(dfc2$`Alienação Absoluta`)

alienacao_uf$`Alienação Absoluta` <- gabi(alienacao_uf$`Alienação Absoluta`)
alienacao_br$`Alienação Absoluta` <- gabi(alienacao_br$`Alienação Absoluta`)

# Deputado Federal

vags_fed <- vags_fed %>% 
  dplyr::select(ANO_ELEICAO, UF, CARGO, VAGAS, VOTOS_VALIDOS_UF,SIGLA_PARTIDO, VOT_PART_UF, QUOCIENTE_ELEITORAL, QUOCIENTE_PARTIDARIO) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "CARGO", "Cadeiras oferecidas" = "VAGAS", "Votos válidos " = "VOTOS_VALIDOS_UF",
                "Sigla do partido" = "SIGLA_PARTIDO", "Votos válidos do partido" = "VOT_PART_UF", "Quociente eleitoral" = "QUOCIENTE_ELEITORAL",
                "Quociente partidário" = "QUOCIENTE_PARTIDARIO") 

vags_fed$Cargo <- str_to_title(vags_fed$Cargo)

# Deputado Estadual


vags_est <- vags_est %>% 
  dplyr::select(ANO_ELEICAO, UF, CARGO, VAGAS, VOTOS_VALIDOS_UF,SIGLA_PARTIDO, VOT_PART_UF, QUOCIENTE_ELEITORAL, QUOCIENTE_PARTIDARIO) %>% 
  dplyr::rename("Ano da eleição" = "ANO_ELEICAO", "Cargo" = "CARGO", "Cadeiras oferecidas" = "VAGAS", "Votos válidos " = "VOTOS_VALIDOS_UF",
                "Sigla do partido" = "SIGLA_PARTIDO", "Votos válidos do partido" = "VOT_PART_UF", "Quociente eleitoral" = "QUOCIENTE_ELEITORAL",
                "Quociente partidário" = "QUOCIENTE_PARTIDARIO") 

objects<-list(dec=dec,
              dec_=dec_, 
              dec1=dec1, 
              dec2=dec2, 
              df=df,
              dfc=dfc,
              dfc_=dfc_, 
              dfc1=dfc1, 
              dfc2=dfc2,
              frag_partdf, 
              num_de=num_de,
              num_df=num_df,
              num_df1=num_df1,
              numc_de=numc_de, 
              numc_df=numc_df,
              frag_partdf=frag_partdf,
              vags_est=vags_est,
              vags_fed=vags_fed,
              alienacao_br=alienacao_br,
              alienacao_uf=alienacao_uf) 

mapply(write.csv, objects, file=paste0("data/",names(objects), ".csv"), fileEncoding="UTF-8")


