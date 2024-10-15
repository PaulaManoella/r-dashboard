library(openxlsx)
library(readxl)
library(dplyr)
library(tidyr)

#carregando a base de dados 
#obs: adaptar o caminho da base de dados do avalia (discente) para onde o arquivo se encontra em sua máquina
dataSource <- "avalia_23-09.xlsx" 
dataBase <- read_excel(dataSource)

#parametros Curso e Campus para o filtro da base de dados
#curso_input <- "Sistemas de Informação - Bacharelado"
campus_input <- "Belém"

#filtrando base de dados de acordo com o Curso e Campus informado
#filtered <- filter(dataBase, CURSO==curso_input, CAMPUS==campus_input)
filtered2 <- filter(dataBase, CAMPUS==campus_input)

#selecionando somente as colunas de interesse para a análise (DISCIPLINA, DOCENTE, COD_ALUNO e colunas de P1 à P3)
cols_disc <- filtered2 %>% select(2, 3, 4, (5), (37:63))

cursos <- c(unique(cols_disc$CURSO))

for (curso in cursos){
  cols_disc <- filter(dataBase, CAMPUS==campus_input, CURSO==curso)

#dataframe com as médias GERAIS por dimensao e subdimensao (no caso da ação docente) considerando a disciplina e docente
  medias <- cols_disc %>%
    group_by(DISCIPLINA, DOCENTE) %>%
    summarise(
      autoavdisc = mean(rowMeans(across(starts_with('P11')), na.rm = TRUE)),
      acaodocente = mean(rowMeans(across(starts_with('P2')), na.rm = TRUE)),
      atitudeprofissional = mean(rowMeans(across(starts_with('P21')), na.rm = TRUE)),
      gestaodidatica = mean(rowMeans(across(starts_with('P22')), na.rm = TRUE)),
      processoav = mean(rowMeans(across(starts_with('P23')), na.rm = TRUE)),
      instalacoesfisicas = mean(rowMeans(across(starts_with('P3')), na.rm = TRUE)),
  )
  
  #descomente a linha abaixo se desejar vizualizar o dataframe 'medias'
  #print(medias)
  
  #dataframe com as médias de CADA coluna de P1 à P3 considerando a disciplina e docente
  mediasCols <- cols_disc %>%
    group_by(DISCIPLINA, DOCENTE) %>%
    summarise(across(starts_with("P"), mean, na.rm = TRUE))
  
  #descomente a linha abaixo se desejar vizualizar o dataframe 'mediasCols'
  #print(mediasCols)
  
  #contagem distinta da coluna COD_ALUNO para gerar o numero de alunos respondentes considerando a disciplina e docente
  contagem_distintos <- cols_disc %>%
    group_by(DISCIPLINA, DOCENTE) %>%
    summarise(contagem_alunos = n_distinct(COD_ALUNO))
  
  #estruturando dataframe com os dados para a planilha
  tabela <- data.frame(
    Disciplina = c(medias$DISCIPLINA),
    Docente = c(medias$DOCENTE),
    `Número de Discentes` = c(contagem_distintos$contagem_alunos),
    '1.1.1' = c(round((mediasCols$P111),2)),
    '1.1.2' = c(round((mediasCols$P112),2)),
    '1.1.3' = c(round((mediasCols$P113),2)),
    '1.1.4' = c(round((mediasCols$P114),2)),
    '1.1.5' = c(round((mediasCols$P115),2)),
    '1.1.6' = c(round((mediasCols$P116),2)),
    '1.1.7' = c(round((mediasCols$P117),2)),
    `Média Geral Dimensão 1` = c(round((medias$autoavdisc),2)),
    '2.1.1' = c(round((mediasCols$P211),2)),
    '2.1.2' = c(round((mediasCols$P212),2)),
    '2.1.3' = c(round((mediasCols$P213),2)),
    '2.1.4' = c(round((mediasCols$P214),2)),
    `Média Geral 2.1` = c(round((medias$atitudeprofissional),2)),
    '2.2.1' = c(round((mediasCols$P221),2)),
    '2.2.2'= c(round((mediasCols$P222),2)),
    '2.2.3' = c(round((mediasCols$P223),2)),
    '2.2.4' = c(round((mediasCols$P224),2)),
    '2.2.5' = c(round((mediasCols$P225),2)),
    '2.2.6' = c(round((mediasCols$P226),2)),
    '2.2.7' = c(round((mediasCols$P227),2)),
    '2.2.8' = c(round((mediasCols$P228),2)),
    `Média Geral 2.2` = c(round((medias$gestaodidatica),2)),
    '2.3.1' = c(round((mediasCols$P231),2)),
    '2.3.2' = c(round((mediasCols$P232),2)),
    '2.3.3' = c(round((mediasCols$P233),2)),
    '2.3.4' = c(round((mediasCols$P234),2)),
    `Média Geral 2.3` = c(round((medias$processoav),2)),
    `Média Geral Dimensão 2` = c(round((medias$acaodocente),2)),
    '3.1.1' = c(round((mediasCols$P311),2)),
    '3.1.2' = c(round((mediasCols$P312),2)),
    '3.1.3' = c(round((mediasCols$P313),2)),
    '3.1.4' = c(round((mediasCols$P314),2)),
    `Média Geral Dimensão 3` = c(round((medias$instalacoesfisicas),2)),
    check.names=FALSE
  )
  
  wb <- createWorkbook()
  addWorksheet(wb, "Planilha1")
  
  #Estilização das celulas como mesclar e centralizar, alinhamento no centro, cor de fundo da célula e borda da célula
  writeData(wb, sheet = 1, x = "Autoavaliação Discente", startRow = 1, startCol = 4)
  mergeCells(wb, sheet=1, cols=4:11, rows = 1:2)
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F3F1E5", border = "TopBottomLeftRight", borderColour = "black"), cols=4:11, rows=1:2, gridExpand = TRUE)
  
  writeData(wb, sheet = 1, x = "Ação Docente", startRow = 1, startCol = 12)
  mergeCells(wb, sheet=1, cols=12:31 , rows = 1:2)
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#E6EAE1", border = "TopBottomLeftRight", borderColour = "black"), cols=12:31, rows=1:2, gridExpand = TRUE)
  
  writeData(wb, sheet = 1, x = "Instalações Físicas", startRow = 1, startCol = 32)
  mergeCells(wb, sheet=1, cols=32:36 , rows = 1:2)
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F2E9E7", border = "TopBottomLeftRight", borderColour = "black"), cols=32:36, rows=1:2, gridExpand = TRUE)
  
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", border = "TopBottomLeftRight", borderColour = "black"), cols=1:36, rows=3)
  
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F3F1E5", border = "TopBottomLeftRight", borderColour = "black"), cols = 11, rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#E6EAE1", border = "TopBottomLeftRight", borderColour = "black"), cols = 31, rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F2E9E7", border = "TopBottomLeftRight", borderColour = "black"), cols = 36, rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
  addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F5F5F5", border = "TopBottomLeftRight", borderColour = "black"), cols = c(16,25,30), rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
  
  #iniciando o dataframe 'tabela' a partir da linha 3
  writeData(wb, sheet = 1, x = tabela, startRow = 3, startCol = 1)
  
  #salvando planilha em .xlsx
  saveWorkbook(wb, file = paste("Médias AVALIA ", curso, ".xlsx"), overwrite = TRUE)
}

#criando planilha
# wb <- createWorkbook()
# addWorksheet(wb, "Planilha1")
# 
# #Estilização das celulas como mesclar e centralizar, alinhamento no centro, cor de fundo da célula e borda da célula
# writeData(wb, sheet = 1, x = "Autoavaliação Discente", startRow = 1, startCol = 4)
# mergeCells(wb, sheet=1, cols=4:11, rows = 1:2)
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F3F1E5", border = "TopBottomLeftRight", borderColour = "black"), cols=4:11, rows=1:2, gridExpand = TRUE)
# 
# writeData(wb, sheet = 1, x = "Ação Docente", startRow = 1, startCol = 12)
# mergeCells(wb, sheet=1, cols=12:31 , rows = 1:2)
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#E6EAE1", border = "TopBottomLeftRight", borderColour = "black"), cols=12:31, rows=1:2, gridExpand = TRUE)
# 
# writeData(wb, sheet = 1, x = "Instalações Físicas", startRow = 1, startCol = 32)
# mergeCells(wb, sheet=1, cols=32:36 , rows = 1:2)
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F2E9E7", border = "TopBottomLeftRight", borderColour = "black"), cols=32:36, rows=1:2, gridExpand = TRUE)
# 
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", border = "TopBottomLeftRight", borderColour = "black"), cols=1:36, rows=3)
# 
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F3F1E5", border = "TopBottomLeftRight", borderColour = "black"), cols = 11, rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#E6EAE1", border = "TopBottomLeftRight", borderColour = "black"), cols = 31, rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F2E9E7", border = "TopBottomLeftRight", borderColour = "black"), cols = 36, rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
# addStyle(wb, sheet = 1, style = createStyle(halign = "center", valign = "center", textDecoration = "bold", fgFill = "#F5F5F5", border = "TopBottomLeftRight", borderColour = "black"), cols = c(16,25,30), rows = 3:(nrow(tabela)+3), gridExpand = TRUE)
# 
# #iniciando o dataframe 'tabela' a partir da linha 3
# writeData(wb, sheet = 1, x = tabela, startRow = 3, startCol = 1)
# 
# #salvando planilha em .xlsx
# saveWorkbook(wb, file = "medias por disciplina.xlsx", overwrite = TRUE)
