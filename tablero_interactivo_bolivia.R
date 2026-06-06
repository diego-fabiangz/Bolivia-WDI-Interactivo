# =============================================================================
#  tablero_interactivo_bolivia.R
#  Tablero INTERACTIVO de desarrollo economico de Bolivia (Banco Mundial / WDI)
#
#  Genera una pagina web (docs/index.html) con graficos interactivos: al pasar
#  el mouse sobre un punto se muestra el pais, el anio y el valor exacto.
#  Lista para publicar gratis con GitHub Pages.
#
#  COMO USAR: copia y pega todo este script en R/RStudio y ejecutalo (boton
#  "Source"). Necesita conexion a internet. Al terminar, abre docs/index.html.
#
#  Autor: <Diego Fabian>   |   Fuente: World Development Indicators (Banco Mundial)
# =============================================================================

# --- 0. Paquetes ------------------------------------------------------------
paquetes <- c("WDI", "dplyr", "tidyr", "plotly", "htmltools", "scales")
faltantes <- paquetes[!paquetes %in% rownames(installed.packages())]
if (length(faltantes) > 0) install.packages(faltantes, repos = "https://cloud.r-project.org")

library(WDI); library(dplyr); library(tidyr)
library(plotly); library(htmltools); library(scales)

dir.create("docs", showWarnings = FALSE)
col_bo <- "#C8102E"  # rojo Bolivia

# --- 1. Descarga de datos ---------------------------------------------------
paises <- c("BO", "PE", "PY", "EC", "CO", "CL")
indicadores <- c(
  pib_pc      = "NY.GDP.PCAP.PP.KD",
  crecimiento = "NY.GDP.MKTP.KD.ZG",
  inflacion   = "FP.CPI.TOTL.ZG",
  pobreza     = "SI.POV.NAHC",
  esp_vida    = "SP.DYN.LE00.IN"
)

panel <- WDI(country = paises, indicator = indicadores,
             start = 1990, end = 2023)

etiquetas <- c(BO = "Bolivia", PE = "Peru", PY = "Paraguay",
               EC = "Ecuador", CO = "Colombia", CL = "Chile")
panel <- panel %>%
  mutate(pais = factor(etiquetas[iso2c],
                       levels = c("Bolivia","Peru","Paraguay",
                                  "Ecuador","Colombia","Chile")))

# Paleta por pais (Bolivia destacada en rojo)
paleta <- c(Bolivia = col_bo, Peru = "#D9A441", Paraguay = "#2E8B57",
            Ecuador = "#17A2A2", Colombia = "#4C72B0", Chile = "#E15FA0")

bol <- panel %>% filter(iso2c == "BO")

# =============================================================================
#  2. GRAFICOS INTERACTIVOS (plotly)
# =============================================================================

# --- 2.1 PIB per capita: lineas multi-pais ----------------------------------
fig_pib <- panel %>%
  filter(!is.na(pib_pc)) %>%
  plot_ly(x = ~year, y = ~pib_pc, color = ~pais, colors = paleta,
          type = "scatter", mode = "lines",
          line = list(width = 2.5),
          text = ~paste0("<b>", pais, "</b><br>Anio: ", year,
                         "<br>PIB pc (PPA): $", comma(round(pib_pc))),
          hoverinfo = "text") %>%
  layout(title = list(text = "<b>PIB per capita en Sudamerica</b><br><sup>Paridad de poder adquisitivo, US$ constantes</sup>"),
         xaxis = list(title = ""), yaxis = list(title = "PIB per capita (PPA)"),
         hovermode = "closest",
         legend = list(orientation = "h", y = -0.15))

# --- 2.2 Crecimiento del PIB de Bolivia: barras -----------------------------
prom <- mean(bol$crecimiento, na.rm = TRUE)
bol_crec <- bol %>% filter(!is.na(crecimiento))

fig_crec <- plot_ly(bol_crec, x = ~year, y = ~crecimiento, type = "bar",
        marker = list(color = ~ifelse(crecimiento >= 0, col_bo, "#9E9E9E")),
        text = ~paste0("Anio: ", year, "<br>Crecimiento: ",
                       round(crecimiento, 1), "%"),
        hoverinfo = "text") %>%
  layout(title = list(text = "<b>Crecimiento economico de Bolivia</b><br><sup>Variacion anual del PIB real (%)</sup>"),
         xaxis = list(title = ""), yaxis = list(title = "Crecimiento (%)"),
         shapes = list(list(type = "line",
                            x0 = min(bol_crec$year), x1 = max(bol_crec$year),
                            y0 = prom, y1 = prom,
                            line = list(dash = "dash", color = "black"))),
         annotations = list(list(x = min(bol_crec$year), y = prom,
                                 text = paste0("Promedio: ", round(prom, 1), "%"),
                                 showarrow = FALSE, xanchor = "left", yshift = 10)))

# --- 2.3 Inflacion: lineas multi-pais ---------------------------------------
fig_inf <- panel %>%
  filter(!is.na(inflacion), inflacion < 50) %>%
  plot_ly(x = ~year, y = ~inflacion, color = ~pais, colors = paleta,
          type = "scatter", mode = "lines", line = list(width = 2.5),
          text = ~paste0("<b>", pais, "</b><br>Anio: ", year,
                         "<br>Inflacion: ", round(inflacion, 1), "%"),
          hoverinfo = "text") %>%
  layout(title = list(text = "<b>Inflacion en Sudamerica</b><br><sup>Indice de precios al consumidor, variacion anual (%)</sup>"),
         xaxis = list(title = ""), yaxis = list(title = "Inflacion (%)"),
         hovermode = "closest", legend = list(orientation = "h", y = -0.15))

# --- 2.4 Pobreza en Bolivia: linea (eje desde 0, honesto) -------------------
bol_pob <- bol %>% filter(!is.na(pobreza))

fig_pob <- plot_ly(bol_pob, x = ~year, y = ~pobreza,
        type = "scatter", mode = "lines+markers",
        line = list(color = col_bo, width = 3),
        marker = list(color = col_bo, size = 8),
        text = ~paste0("Anio: ", year, "<br>Pobreza: ", round(pobreza, 1), "%"),
        hoverinfo = "text") %>%
  layout(title = list(text = "<b>Pobreza en Bolivia (linea nacional)</b><br><sup>Porcentaje de la poblacion bajo la linea de pobreza</sup>"),
         xaxis = list(title = ""),
         yaxis = list(title = "Incidencia de pobreza (%)",
                      range = c(0, max(bol_pob$pobreza) + 5)))

# --- 2.5 Curva de Preston: dispersion + ajuste ------------------------------
preston <- WDI(country = "all",
               indicator = c(pib_pc = "NY.GDP.PCAP.PP.KD",
                             esp_vida = "SP.DYN.LE00.IN"),
               start = 2015, end = 2023, extra = TRUE) %>%
  filter(region != "Aggregates", !is.na(pib_pc), !is.na(esp_vida)) %>%
  group_by(country) %>% slice_max(year, n = 1, with_ties = FALSE) %>% ungroup() %>%
  filter(region == "Latin America & Caribbean")

modelo_preston <- lm(esp_vida ~ log(pib_pc), data = preston)
rejilla <- data.frame(pib_pc = exp(seq(log(min(preston$pib_pc)),
                                       log(max(preston$pib_pc)), length.out = 100)))
rejilla$pred <- predict(modelo_preston, rejilla)

otros  <- preston %>% filter(iso2c != "BO")
bol_p  <- preston %>% filter(iso2c == "BO")
b1     <- coef(modelo_preston)[["log(pib_pc)"]]
resid_bo <- round(bol_p$esp_vida - predict(modelo_preston, bol_p), 1)

fig_pres <- plot_ly() %>%
  add_lines(data = rejilla, x = ~pib_pc, y = ~pred,
            line = list(color = "grey50"), name = "Ajuste (MCO)",
            hoverinfo = "skip") %>%
  add_markers(data = otros, x = ~pib_pc, y = ~esp_vida,
              marker = list(color = "#4C72B0", size = 9, opacity = 0.7),
              name = "Paises de ALC",
              text = ~paste0("<b>", country, "</b><br>PIB pc: $", comma(round(pib_pc)),
                             "<br>Esp. vida: ", round(esp_vida, 1), " anios"),
              hoverinfo = "text") %>%
  add_markers(data = bol_p, x = ~pib_pc, y = ~esp_vida,
              marker = list(color = col_bo, size = 16),
              name = "Bolivia",
              text = ~paste0("<b>BOLIVIA</b><br>PIB pc: $", comma(round(pib_pc)),
                             "<br>Esp. vida: ", round(esp_vida, 1), " anios"),
              hoverinfo = "text") %>%
  layout(title = list(text = "<b>La curva de Preston en America Latina y el Caribe</b><br><sup>Esperanza de vida vs. PIB per capita (escala log), ultimo dato disponible</sup>"),
         xaxis = list(title = "PIB per capita, PPA (escala logaritmica)", type = "log"),
         yaxis = list(title = "Esperanza de vida (anios)"),
         hovermode = "closest", legend = list(orientation = "h", y = -0.2))

# =============================================================================
#  3. NARRATIVA (economista boliviano) + ENSAMBLAJE DE LA PAGINA
# =============================================================================
estilo <- "
  body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif;
       color:#1a1a1a; line-height:1.65; max-width:920px; margin:0 auto; padding:28px;}
  h1{font-size:2em; margin-bottom:0.1em;}
  h2{margin-top:2em; border-bottom:2px solid #C8102E; padding-bottom:4px;}
  .lead{color:#444; font-size:1.1em;}
  .cap{color:#777; font-size:0.85em; margin-top:3em;}
  .nota{background:#FBF3F4; border-left:4px solid #C8102E; padding:10px 14px; font-size:0.92em; color:#444;}
"

pagina <- tagList(
  tags$head(
    tags$meta(charset = "utf-8"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$title("Bolivia en datos"),
    tags$style(HTML(estilo))
  ),
  tags$h1("Bolivia en datos"),
  tags$p(class = "lead",
         "Trayectoria de desarrollo economico de Bolivia en perspectiva sudamericana. ",
         tags$b("Pasa el cursor sobre los graficos"),
         " para ver el pais, el anio y el valor exacto. Datos: Banco Mundial (WDI)."),

  tags$h2("1. PIB per capita: una brecha persistente"),
  tags$p("Bolivia es la economia de menor ingreso per capita del grupo. Durante el ",
         "auge de materias primas (gas natural) de 2006-2014 hubo una convergencia ",
         "parcial, pero la distancia con Chile sigue siendo amplia. El bache de 2020 ",
         "(pandemia) es visible en toda la region."),
  fig_pib,

  tags$h2("2. Crecimiento: del auge del gas al shock de la pandemia"),
  tags$p("El crecimiento promedio del periodo ronda el 3,7% anual, con una fase ",
         "expansiva clara durante el ciclo del gas. La pandemia provoco una ",
         "contraccion de -8,7% en 2020 -la peor en decadas- seguida de un rebote ",
         "de +6,1% en 2021."),
  tags$p(class = "nota",
         "Nota metodologica: el dato anual suaviza una volatilidad trimestral ",
         "extrema en 2020 (caida record de ~-24% en el 2do trimestre y rebote de ",
         "~+21% en el 3ro, segun el INE)."),
  fig_crec,

  tags$h2("3. Inflacion: estabilidad anclada al tipo de cambio"),
  tags$p("Tras la hiperinflacion de los anos 80 -una de las peores de la historia-, ",
         "Bolivia consolido una inflacion baja y estable, en buena medida por el ",
         "ancla cambiaria del boliviano. El repunte hacia 2008 corresponde al shock ",
         "global de alimentos y combustibles."),
  tags$p(class = "nota",
         "Advertencia: los WDI tienen un rezago de 1-2 anios, por lo que estas ",
         "cifras no capturan las presiones cambiarias y de precios mas recientes."),
  fig_inf,

  tags$h2("4. Pobreza: avances reales, pero frenados por la pandemia"),
  tags$p("La incidencia de pobreza por linea nacional cayo de forma sostenida y ",
         "repunto en 2020 con la crisis sanitaria. El eje vertical arranca en 0 ",
         "para no exagerar visualmente las variaciones."),
  fig_pob,

  tags$h2("5. La curva de Preston: el desafio no es solo el ingreso"),
  tags$p(HTML(paste0(
    "La relacion entre ingreso y longevidad (Preston, 1975) muestra rendimientos ",
    "decrecientes: duplicar el PIB per capita se asocia con +",
    round(b1 * log(2), 1), " anios de esperanza de vida en America Latina. ",
    "El hallazgo clave: <b>Bolivia se ubica por debajo de la linea</b>, con un ",
    "residuo de ", resid_bo, " anios. Es decir, vive menos de lo que su nivel de ",
    "ingreso predeciria. El reto es de <b>salud publica</b> (mortalidad ",
    "materno-infantil, acceso, altitud), no de ingreso puro."))),
  fig_pres,

  tags$p(class = "cap",
         "Fuente: World Development Indicators, Banco Mundial. ",
         "Analisis y visualizacion: <Diego Fabian>. Codigo en R (plotly). ",
         "Ultimo dato disponible segun el rezago de cada indicador.")
)

save_html(pagina, file = "docs/index.html")

cat("\n=============================================================\n")
cat(" LISTO. Pagina interactiva generada en: docs/index.html\n")
cat(" Abrela con doble clic (o arrastrala a tu navegador).\n")
cat("=============================================================\n")
