library(shiny)
library(shinythemes)
library(tidyverse)
library(reticulate)
#library(lubridate)

setwd('C:/Users/ma_gi/Desktop/gp')
gp <- import('gp')
builtins <- import_builtins()

qr_mio <- builtins$open('./Marco.txt')$read()
d <- gp$green_pass_decoder(qr_mio)

formatta_dati_gp <- function(gp_dic) {
    gpd <- (gp_dic$`-260`)$`1` # occhio, sono stringhe! Se metti i numeri cerca di effettuare l'indexing visto che in R le named list fondono i dizionari e le liste di python
    gpd_nam <- gpd$nam

    tipi_di_gp <- c('v','t','r') # vaccino, test (tampone), recovered (guarito)
    for (tipo in tipi_di_gp) {
        if (tipo %in% names(gpd)) tipo_di_gp <- tipo
    }
    # significato pezzi vari: https://ec.europa.eu/health/sites/default/files/ehealth/docs/covid-certificate_json_specification_en.pdf
    if (tipo_di_gp == 'v') {
        gpd_v <- gpd$v[[1]] # nel dizionario alla chiave 'v' corrisponde una lista contenente un dizionario anziché direttamente il dizionario
        vp <- c('1119305005' = 'SARS-CoV-2 antigen vaccine', '1119349007' = 'SARS-CoV-2 mRNA vaccine', 'J07BX03' = 'vaccines that are neither an antigen nor an mRNA vaccine or this information is not known')
        # magari scarico e uso dei json come ad esempio fa lui https://github.com/jumpjack/greenpass anziché copiare manualmente da https://ec.europa.eu/health/sites/default/files/ehealth/docs/digital-green-certificates_dt-specifications_en.pdf
        tmp <- tibble('virus' = 'COVID-19', 'vaccino/profilassi' = vp[gpd_v$vp])
    }

    if (tipo_di_gp == 't') {
        tmp <- tibble()
    }

    if (tipo_di_gp == 'r') {
        tmp <- tibble()
    }

    tibble(
        'cognome' = gpd_nam$fn,
        'cognome std' = gpd_nam$fnt,
        'nome' = gpd_nam$gn,
        'nome std' = gpd_nam$gnt,
        'data di nascita' = gpd$dob, # %>% lubridate::ymd, # %>% as.Date('%Y-%m-%d'), convertire a data con uno qualunque di questi metodi rompe il display quando uso tableOutput/renderTable... lascio a char
        'versione gp' = gpd$ver,
        'tipo di green pass' = c('v' = 'vaccino', 't' = 'tampone', 'r' = 'guarizione')[tipo_di_gp]
    ) %>% bind_cols(tmp)
}


ui <- fluidPage(
    # 'gp decoder',
    theme = shinytheme('paper'),
    navbarPage( # navlistPanel o navbarPage con titolo generale
        title = 'GP decoder',
        tabPanel(
            'decoder', # qrs = qr_string, qrd = qr_dictionary, qrt = qr_tibble
            textInput('qrs', label = 'Inserisci la stringa ottenuta leggendo il qr code'), #, value = qr_mio # di default ho value = '' cioè la stringa vuota
            tableOutput('qrt'),
            checkboxInput('mostra_output_grezzo', 'Mostra output grezzo', value = TRUE),
            tableOutput('qrd') # l'alternativa è verbatimTextOutput('qrd') ma viene lungo, con la barra di scorrimento orizzontale... brutto
        ),
        tabPanel(
            'info'
        )
    )    
)

server <- function(input, output, session){
    output$qrt <- renderTable({
        if (input$qrs != '') formatta_dati_gp(gp$green_pass_decoder(input$qrs))
    })
    
    output$qrd <- renderPrint({
        if (input$mostra_output_grezzo) {
            if (input$qrs != '') builtins$str(gp$green_pass_decoder(input$qrs))
        }
    })
}

runApp(shinyApp(ui, server))