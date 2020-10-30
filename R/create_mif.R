#' Create Multiplex Immunoflourescent object 
#'
#' @description Creates an MIF object for use in spatialIF functions
#' @param spatial_lsit A named list of data frames with the spatial data from 
#' each sample making up each individual data frame
#' @param clinical_data A data frame containing patient level data. Patient ID
#' indicated with variable `patient_id`
#' @param sample_data A data frame containing sample level data. Sample ID 
#' should be indicated with variable `image.tag` while patient ID should 
#' be indicated with variable  `patient_id`. 
#' 
#' @return Returns a custom MIF
#'    \item{spatial}{Named list of spatial data}
#'    \item{clinical}{Data frame of clinical data}
#'    \item{sample}{Data frame of sample data}
#'    \item{derived}{List of data derived using the MIF object}
#'    
#' @export
create_mif <- function(spatial_list, clinical_data = NULL, sample_data = NULL){
  
  # if spatial data list is unnamed - name each element according to 
  # image tag (does every file come with image.tage and is it always named
  # "image.tag")
  if(is.null(names(spatial_list))) {
    spatial_names <- lapply(spatial_list, function(x) {x$image.tag[[1]]})
    spatial_names <- unlist(spatial_names)
    
    names(spatial_list) <- spatial_names
  }

  # create empty data frames assuming a single sample per patient
  if(is.null(clinical_data)){
    clinical_data <- data.frame(patient_id = names(spatial_list))
  }
  if(is.null(sample_data)){
    sample_data <- data.frame(image.tag = names(spatial_list),
                              patient_id = names(spatial_list))
  }
  
  # clean names in clinical and sample data? 
  # have the column name be "image.tag" ?
  spatial_sample_names <- intersect(sample_data[["image.tag"]], 
                                    names(spatial_list))
  
  clinical_sample_names <- intersect(sample_data[["patient_id"]],
                                     clinical_data[["patient_id"]])
  
  sample_data <- sample_data %>% 
    dplyr::filter(image.tag %in% spatial_sample_names | 
                    patient_id %in% clinical_sample_names)
  
  clinical_data <- clinical_data %>%
    dplyr::filter(patient_id %in% clinical_sample_names)
  
  spatial_list <- spatial_list[spatial_sample_names]
  
  mif <- list(spatial = spatial_list,
              clinical = clinical_data,
              sample = sample_data,
              derived = list())
  
  # class(mif) <- c("mif", class(mif))
  
  structure(mif, class="mif")
  
  # return(mif)

}