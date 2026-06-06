# Bolivia en datos — Tablero interactivo de desarrollo económico

Tablero **interactivo** que resume la trayectoria de desarrollo económico de Bolivia en perspectiva sudamericana, con datos del Banco Mundial (*World Development Indicators*). Al pasar el cursor sobre cualquier punto se muestra el país, el año y el valor exacto. Hecho enteramente en R con `plotly`, y publicable gratis como página web mediante **GitHub Pages**.

> **Ver el tablero en vivo:** https://diego-fabiangz.github.io/Bolivia-WDI-Interactivo/

## Lectura del economista

El tablero cuenta una historia coherente y verificada de la economía boliviana:

- **PIB per cápita.** Bolivia es la economía de menor ingreso per cápita del grupo. Durante el auge del gas (2006–2014) hubo convergencia parcial, pero la brecha con Chile persiste.
- **Crecimiento.** Promedio cercano al 3,7% anual. La pandemia provocó una contracción de **−8,7% en 2020** (la peor en décadas), seguida de un rebote de **+6,1% en 2021** (cifras confirmadas con el Banco Mundial). El dato anual suaviza una volatilidad trimestral extrema en 2020.
- **Inflación.** Tras la hiperinflación de los años 80, Bolivia consolidó una inflación baja y estable, anclada al tipo de cambio. *Advertencia:* los WDI tienen rezago de 1–2 años y no capturan las presiones cambiarias y de precios más recientes.
- **Pobreza.** Reducción sostenida por línea nacional, con repunte en 2020 por la pandemia. El eje vertical arranca en 0 para no exagerar visualmente las variaciones.
- **Curva de Preston.** El hallazgo central: **Bolivia se ubica por debajo de la línea** que relaciona ingreso y esperanza de vida en América Latina (residuo ≈ −4,4 años). Es decir, vive menos de lo que su ingreso predeciría: el reto es de **salud pública** (mortalidad materno-infantil, acceso, altitud), no de ingreso puro.

## Cómo generar el tablero

Abre `R/tablero_interactivo_bolivia.R` en RStudio y ejecútalo con el botón **Source** (requiere internet). El script instala los paquetes que falten (`WDI`, `dplyr`, `tidyr`, `plotly`, `htmltools`, `scales`), descarga los datos y crea la página en **`docs/index.html`**. Ábrela con doble clic para verla en tu navegador.

> Importante: el script usa rutas relativas. Asegúrate de que la carpeta de trabajo de R sea la **raíz del proyecto** (`Session → Set Working Directory → To Source File Location` si el script está en la raíz, o `Choose Directory…` apuntando a la carpeta del proyecto).

## Cómo subirlo a GitHub y publicarlo

### Opción A — GitHub Desktop (la más fácil, recomendada en Mac)

1. Instala GitHub Desktop: `https://desktop.github.com`.
2. Inicia sesión con tu cuenta de GitHub.
3. *File → Add Local Repository…* y elige la carpeta `Bolivia-WDI-Interactivo`. Si te dice que no es un repositorio, pulsa *create a repository* (Initialize).
4. Escribe un resumen (p. ej. "Tablero interactivo Bolivia WDI") y pulsa **Commit to main**.
5. Pulsa **Publish repository** (déjalo público para usar Pages).

### Opción B — Terminal (línea de comandos)

Primero crea un repositorio **vacío** en `https://github.com/new` (sin README). Luego, en la Terminal de Mac, dentro de la carpeta del proyecto:

```bash
cd ruta/a/Bolivia-WDI-Interactivo
git init
git add .
git commit -m "Tablero interactivo: Bolivia en datos (WDI)"
git branch -M main
git remote add origin https://github.com/TU_USUARIO/Bolivia-WDI-Interactivo.git
git push -u origin main
```

La primera vez que uses `git` en Mac, te ofrecerá instalar las *Command Line Tools*; acéptalo.

### Activar GitHub Pages (para que el tablero quede en línea)

1. En tu repositorio en github.com: pestaña **Settings → Pages**.
2. En *Source*, elige **Deploy from a branch**.
3. *Branch*: `main`; *Folder*: **`/docs`**. Guarda.
4. Espera 1–2 minutos. Tu tablero quedará público en `https://TU_USUARIO.github.io/Bolivia-WDI-Interactivo/`.

> El archivo `docs/.nojekyll` ya está incluido: evita que GitHub Pages ignore los archivos de `plotly` (carpeta `docs/lib/`). Asegúrate de subir **toda** la carpeta `docs/`.

## Estructura

```
Bolivia-WDI-Interactivo/
├── README.md
├── R/
│   └── tablero_interactivo_bolivia.R
├── docs/
│   ├── .nojekyll
│   ├── index.html      # se genera al correr el script
│   └── lib/            # dependencias de plotly (se generan al correr)
└── .gitignore
```

## Referencias

- Preston, S. H. (1975). The Changing Relation between Mortality and Level of Economic Development. *Population Studies*, 29(2).
- World Bank, *World Development Indicators*.
- Sievert, C. (2020). *Interactive Web-Based Data Visualization with R, plotly, and shiny*.

## Licencia

MIT.
