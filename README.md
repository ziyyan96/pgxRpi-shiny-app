# Progenetix API Explorer Shiny App

An interactive web application for querying, analyzing, and visualizing genomic data from the Progenetix Beacon v2 API and Services.

## 🚀 Features
- Data Loaders: Biosamples, Individuals, Variants, CNV Frequencies
- Metadata and Variant Plotting
- CNV Frequency Analysis (pgxfreq / pgxmatrix)
- CNV Frequency Plotting: Genome-wide, Chromosome, Circos
- Simulated Segment CNV Frequency Calculation
- User Upload and segtoFreq Processing
- Download Capabilities

## 🛠️ Technologies
- R / Shiny
- pgxRpi package
- Progenetix Beacon v2 API
- DT for interactive tables

## 💻 Installation & Usage
```r
install.packages(c("shiny", "DT"))
install.packages("devtools")
devtools::install_github("progenetix/pgxRpi")
shiny::runApp()
```

## 📄 License
MIT License. See LICENSE file for details.

## 🤝 Contributing
Feel free to submit issues, pull requests, or feature suggestions.

## 📖 Tutorial
See [tutorial.md](./tutorial.md) for full usage instructions.
