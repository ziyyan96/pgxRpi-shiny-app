# Progenetix API Explorer Tutorial

## 📝 Getting Started Tutorial

### 1. Install R Packages
```r
install.packages(c("shiny", "DT"))
install.packages("devtools")
devtools::install_github("progenetix/pgxRpi")
```

### 2. Launch the App
```r
shiny::runApp("path_to_your_app_directory")
```
Or use the RStudio "Run App" button.

### 3. Using the App

#### Step 1: Load Data
- Select data type: biosamples, individuals, variants, cnv_fraction, etc.
- Set filters or biosample IDs.
- Click "Load Data".
- Preview and download data.
![Workflow Diagram](./images/load_data.png)
#### Step 2: Metadata Plot
- Set grouping and condition.
- Click "Generate Plot".
![Workflow Diagram](./images/metadata.png)
#### Step 3: CNV Frequency Loader
- Enter NCIT filters.
- Choose pgxfreq or pgxmatrix.
- Load data and download results.
![Workflow Diagram](./images/load_frequency.png)
#### Step 4: CNV Frequency Plot
- Choose plot type: Genome-wide, Chromosome, Circos.
- Set layout.
- Generate plot.
![Workflow Diagram](./images/frequency_plot.png)
#### Step 5: Simulate or Upload Segment Data
- Simulate example segment data or upload your own.
- Run segtoFreq.
- View and download frequency results.

## 🗃️ Deployment Options
- **shinyapps.io**: Deploy using RSConnect.
- **Shiny Server / Docker**: Follow your platform's deployment guide.
