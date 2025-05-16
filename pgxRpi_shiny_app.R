library(shiny)
library(DT)
library(pgxRpi)

ui <- navbarPage("Progenetix API Explorer",
                 
                 tabPanel("Load Data",
                          sidebarLayout(
                            sidebarPanel(
                              selectInput("loader_type", "Data Type:",
                                          choices = c("biosamples", "individuals", "analyses", "filtering_terms", "counts", "g_variants", "cnv_fraction")),
                              
                              conditionalPanel(
                                condition = "input.loader_type != 'g_variants'",
                                textInput("filters", "Filters (e.g., NCIT:C3512):", value = "NCIT:C3512"),
                                numericInput("limit", "Limit:", value = 10, min = 0),
                                numericInput("skip", "Skip:", value = 0, min = 0)
                              ),
                              
                              conditionalPanel(
                                condition = "input.loader_type == 'g_variants'",
                                textInput("biosample_id", "Biosample ID (e.g., pgxbs-kftvki7h):", value = "pgxbs-kftvki7h"),
                                selectInput("output_format", "Output Format:", choices = c("default", "pgxseg", "seg")),
                                checkboxInput("save_file", "Save to File?", value = FALSE),
                                textInput("filename", "Filename:", value = "output.tsv")
                              ),
                              
                              actionButton("load_data", "Load Data"),
                              verbatimTextOutput("loader_example")
                            ),
                            mainPanel(
                              h4("Data Summary"),
                              verbatimTextOutput("data_summary"),
                              h4("Data Table"),
                              DTOutput("data_preview"),
                              downloadButton("download_data", "Download Loaded Data as CSV")
                            )
                          )
                 ),
                 
                 tabPanel("Metadata Plot",
                          sidebarLayout(
                            sidebarPanel(
                              textInput("group_id", "Group ID (e.g., age_iso):", value = "age_iso"),
                              textInput("condition", "Condition (e.g., P70Y):", value = "P70Y"),
                              checkboxInput("show_pval", "Show p-value", value = TRUE),
                              actionButton("generate_plot", "Generate Plot"),
                              verbatimTextOutput("plot_example")
                            ),
                            mainPanel(
                              plotOutput("meta_plot")
                            )
                          )
                 ),
                 
                 tabPanel("Export Variants",
                          sidebarLayout(
                            sidebarPanel(
                              actionButton("export_variants", "Show Export Example")
                            ),
                            mainPanel(
                              verbatimTextOutput("export_example"),
                              downloadButton("download_variant_file", "Download Exported Variant File")
                            )
                          )
                 ),
                 tabPanel("CNV Frequency Loader",
                          sidebarLayout(
                            sidebarPanel(
                              textInput("cnv_filters", "Filters (comma-separated NCIT codes):", value = "NCIT:C3058,NCIT:C3493"),
                              selectInput("cnv_output_format", "Output Format:", choices = c("pgxfreq", "pgxmatrix")),
                              selectInput("cnv_domain", "Domain:", choices = c("progenetix.org", "cancercelllines.org")),
                              actionButton("load_cnv", "Load CNV Frequency Data"),
                              verbatimTextOutput("cnv_loader_example"),
                              downloadButton("download_cnv_data", "Download CNV Data"),
                              
                              hr(),
                              h4("CNV Frequency from Simulated Segments"),
                              actionButton("simulate_seg", "Simulate Example Segment Data"),
                              actionButton("run_segtofreq", "Run segtoFreq()"),
                              verbatimTextOutput("segtofreq_example"),
                              downloadButton("download_segtofreq", "Download CNV Frequency Data"),
                              
                              hr(),
                              h4("Upload Segment File for segtoFreq"),
                              fileInput("seg_file", "Upload Segment File (.tsv, .txt, .seg):", accept = c(".tsv", ".txt", ".seg")),
                              numericInput("cnv_col_idx", "CNV Column Index:", value = 6, min = 1),
                              textInput("cohort_name", "Cohort Name:", value = "uploaded_cohort"),
                              actionButton("run_segtofreq_upload", "Run segtoFreq()"),
                              verbatimTextOutput("upload_example"),
                              downloadButton("download_segtofreq_upload", "Download CNV Frequency Data")
                            ),
                            mainPanel(
                              h4("CNV Frequency Data Summary"),
                              verbatimTextOutput("cnv_data_summary"),
                              h4("CNV Metadata Preview"),
                              verbatimTextOutput("cnv_metadata_preview"),
                              h4("CNV Table Preview"),
                              DTOutput("cnv_data_table")
                            )
                          )
                 ),
                 tabPanel("CNV Frequency Plot",
                          sidebarLayout(
                            sidebarPanel(
                              textInput("cnv_plot_filter", "Filter to Plot (e.g., NCIT:C3058):", value = "NCIT:C3058"),
                              checkboxInput("circos_plot", "Circos Plot?", value = FALSE),
                              textInput("chromosomes", "Chromosomes (comma-separated, e.g., 7,9):", value = ""),
                              numericInput("layout_rows", "Layout Rows:", value = 1),
                              numericInput("layout_cols", "Layout Columns:", value = 1),
                              actionButton("generate_cnv_plot", "Generate CNV Plot"),
                              verbatimTextOutput("cnv_plot_example")
                            ),
                            mainPanel(
                              plotOutput("cnv_plot_output")
                            )
                          )
                 ),
                 
                 
                
                 
                 
                 
                 
)

server <- function(input, output, session) {
  loaded_data <- reactiveVal(NULL)
  
  observeEvent(input$load_data, {
    if (input$loader_type == "g_variants") {
      data <- pgxLoader(
        type = input$loader_type,
        biosample_id = input$biosample_id,
        output = if (input$output_format == "default") NULL else input$output_format,
        save_file = input$save_file,
        filename = input$filename
      )
    } else {
      data <- pgxLoader(
        type = input$loader_type,
        filters = input$filters,
        limit = input$limit,
        skip = input$skip
      )
    }
    loaded_data(data)
  })
  
  output$data_summary <- renderPrint({
    req(loaded_data())
    data <- loaded_data()
    if (is.data.frame(data)) {
      paste0("Data dimensions: ", nrow(data), " rows x ", ncol(data), " columns\n",
             "Columns: ", paste(colnames(data), collapse = ", "))
    } else {
      str(data)
    }
  })
  
  output$data_preview <- renderDT({
    req(loaded_data())
    data <- loaded_data()
    if (is.data.frame(data)) {
      datatable(data, options = list(pageLength = 5))
    } else {
      datatable(data.frame(Message = "Non-tabular data - see summary above."))
    }
  })
  
  output$loader_example <- renderText({
    if (input$loader_type == "g_variants") {
      paste0("Example:\npgxLoader(type = 'g_variants', biosample_id = '", input$biosample_id,
             "', output = '", input$output_format, "', save_file = ", input$save_file,
             ", filename = '", input$filename, "')")
    } else {
      paste0("Example:\npgxLoader(type = '", input$loader_type,
             "', filters = '", input$filters,
             "', limit = ", input$limit,
             ", skip = ", input$skip, ")")
    }
  })
  
  observeEvent(input$generate_plot, {
    req(loaded_data())
    output$meta_plot <- renderPlot({
      pgxMetaplot(
        data = loaded_data(),
        group_id = input$group_id,
        condition = input$condition,
        pval = input$show_pval
      )
    })
  })
  
  output$plot_example <- renderText({
    paste0("Example:\nluad_inds <- pgxLoader(type = 'individuals', filters = 'NCIT:C3512')\n",
           "pgxMetaplot(data = luad_inds, group_id = '", input$group_id,
           "', condition = '", input$condition,
           "', pval = ", input$show_pval, ")")
  })
  
  # Download loaded data as CSV or TXT
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("loaded_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data <- loaded_data()
      if (is.data.frame(data)) {
        write.csv(data, file, row.names = FALSE)
      } else {
        writeLines(capture.output(str(data)), file)
      }
    }
  )
  
  observeEvent(input$export_variants, {
    output$export_example <- renderText({
      paste0("Example:\npgxLoader(type = 'g_variants', output = 'pgxseg', biosample_id = 'pgxbs-kftvki7h', save_file = TRUE, filename = '", input$filename, "')")
    })
  })
  
  # Download saved variant file
  output$download_variant_file <- downloadHandler(
    filename = function() {
      input$filename
    },
    content = function(file) {
      file.copy(input$filename, file)
    }
  )
  
  cnv_data <- reactiveVal(NULL)
  
  observeEvent(input$load_cnv, {
    filters_list <- unlist(strsplit(input$cnv_filters, ","))
    data <- pgxLoader(
      type = "cnv_frequency",
      output = input$cnv_output_format,
      filters = filters_list,
      domain = input$cnv_domain
    )
    cnv_data(data)
  })
  
  output$cnv_loader_example <- renderText({
    paste0("Example:\npgxLoader(type = 'cnv_frequency', output = '", input$cnv_output_format,
           "', filters = c('", gsub(",", "','", input$cnv_filters), "'), domain = '", input$cnv_domain, "')")
  })
  
  output$cnv_data_summary <- renderPrint({
    req(cnv_data())
    str(cnv_data())
  })
  
  output$cnv_metadata_preview <- renderPrint({
    req(cnv_data())
    data <- cnv_data()
    if (input$cnv_output_format == "pgxfreq") {
      mcols(data)
    } else {
      colData(data)
    }
  })
  
  output$cnv_data_table <- renderDT({
    req(cnv_data())
    data <- cnv_data()
    if (input$cnv_output_format == "pgxmatrix") {
      datatable(as.data.frame(assay(data, "lowlevel_cnv_frequency")), options = list(pageLength = 5))
    } else {
      datatable(as.data.frame(mcols(data)), options = list(pageLength = 5))
    }
  })
  
  output$download_cnv_data <- downloadHandler(
    filename = function() { paste0("cnv_data_", Sys.Date(), ".csv") },
    content = function(file) {
      data <- cnv_data()
      if (input$cnv_output_format == "pgxmatrix") {
        write.csv(as.data.frame(assay(data, "lowlevel_cnv_frequency")), file)
      } else {
        write.csv(as.data.frame(mcols(data)), file)
      }
    }
  )
  
  output$cnv_plot_example <- renderText({
    paste0("Example:\npgxFreqplot(data = cnv_data, filters = '", input$cnv_plot_filter,
           "', chrom = c(", input$chromosomes, "), layout = c(", input$layout_rows, ", ", input$layout_cols,
           "), circos = ", input$circos_plot, ")")
  })
  
  observeEvent(input$generate_cnv_plot, {
    req(cnv_data())
    output$cnv_plot_output <- renderPlot({
      chrom_list <- if (nzchar(input$chromosomes)) unlist(strsplit(input$chromosomes, ",")) else NULL
      pgxFreqplot(
        data = cnv_data(),
        filters = input$cnv_plot_filter,
        chrom = chrom_list,
        layout = c(input$layout_rows, input$layout_cols),
        circos = input$circos_plot
      )
    })
  })
  
  # Reactive storage for simulated segment data and segtoFreq result
  simulated_seg_data <- reactiveVal(NULL)
  segtofreq_result <- reactiveVal(NULL)
  
  # Simulate example segment data
  observeEvent(input$simulate_seg, {
    variants <- pgxLoader(type = "g_variants", biosample_id = c("pgxbs-kftvhmz9", "pgxbs-kftvhnqz", "pgxbs-kftvhupd"), output = "pgxseg")
    segdata <- variants[variants$variant_type %in% c("DUP", "DEL"), ]
    simulated_seg_data(segdata)
  })
  
  # Example usage text
  output$segtofreq_example <- renderText({
    "Example:\nsegtoFreq(data = simulated_seg_data, cnv_column_idx = 6, cohort_name = 'c1')"
  })
  
  # Run segtoFreq on simulated data
  observeEvent(input$run_segtofreq, {
    req(simulated_seg_data())
    result <- segtoFreq(simulated_seg_data(), cnv_column_idx = 6, cohort_name = "c1")
    segtofreq_result(result)
  })
  
  # Summary and preview
  output$segtofreq_summary <- renderPrint({
    req(segtofreq_result())
    str(segtofreq_result())
  })
  
  output$segtofreq_table <- renderDT({
    req(segtofreq_result())
    datatable(as.data.frame(mcols(segtofreq_result())), options = list(pageLength = 5))
  })
  
  # Download Handler
  output$download_segtofreq <- downloadHandler(
    filename = function() { paste0("segtofreq_result_", Sys.Date(), ".csv") },
    content = function(file) { write.csv(as.data.frame(mcols(segtofreq_result())), file) }
  )
  
  # Reactive storage for uploaded segment data and result
  uploaded_seg_data <- reactiveVal(NULL)
  segtofreq_upload_result <- reactiveVal(NULL)
  
  # Validate uploaded file structure
  observeEvent(input$seg_file, {
    req(input$seg_file)
    seg_data <- read.table(input$seg_file$datapath, header = TRUE, sep = "\t")
    
    if (ncol(seg_data) < 6) {
      showModal(modalDialog(
        title = "Invalid File",
        "Uploaded file must have at least 6 columns (Sample ID, Chromosome, Start, End, ..., CNV State).",
        easyClose = TRUE
      ))
      uploaded_seg_data(NULL)
    } else {
      uploaded_seg_data(seg_data)
    }
  })
  
  # Example usage display
  output$upload_example <- renderText({
    paste0("Example:\nsegtoFreq(data = uploaded_seg_data, cnv_column_idx = ", input$cnv_col_idx, ", cohort_name = '", input$cohort_name, "')")
  })
  
  # Run segtoFreq on uploaded data
  observeEvent(input$run_segtofreq_upload, {
    req(uploaded_seg_data())
    result <- segtoFreq(uploaded_seg_data(), cnv_column_idx = input$cnv_col_idx, cohort_name = input$cohort_name)
    segtofreq_upload_result(result)
  })
  
  # Summary and preview
  output$uploaded_seg_summary <- renderPrint({
    req(uploaded_seg_data())
    str(uploaded_seg_data())
  })
  
  output$segtofreq_upload_table <- renderDT({
    req(segtofreq_upload_result())
    datatable(as.data.frame(mcols(segtofreq_upload_result())), options = list(pageLength = 5))
  })
  
  # Download Handler
  output$download_segtofreq_upload <- downloadHandler(
    filename = function() { paste0("uploaded_segtofreq_result_", Sys.Date(), ".csv") },
    content = function(file) { write.csv(as.data.frame(mcols(segtofreq_upload_result())), file) }
  )
  
  
}

shinyApp(ui = ui, server = server)