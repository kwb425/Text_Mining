######################################################################################################
# Text mining (through word clouding)
#
### Input(s): directory where all text file(s) is(are) located.
#
### Output(s): png file(s)
#
#                                                                              Written by Kim, Wiback,
#                                                                                2016.06.06. Ver. 1.1.
######################################################################################################





## Loading ###########################################################################################
library(wordcloud)
library(png)
library(tm)
library(RColorBrewer)





## User's Input #####################################################################################
directory = "/Users/KimWiback/Google_Drive/Git/Text_Mining/"
input_dir = paste(directory, "text_r/", sep = "")
output_dir = paste(directory, "result_r/", sep = "")
# Creating output folder
dir.create(output_dir)
# Listing all files in the user's directory
file_list = dir(input_dir)





## Pre-processing ###################################################################################



###############
# Corpus-ifying
###############

### Corpus function will compress all txt files into a big corpus.
txt = Corpus(DirSource(input_dir))

### Now, cut all unnecessary informations from the corpus.
txt = tm_map(txt,removeNumbers) 
txt = tm_map(txt,removePunctuation)
txt = tm_map(txt,stripWhitespace)
txt = tm_map(txt, removeWords, stopwords('english'))

### Forming document
# TermDocumentMatrix(corpus, control = list(wordLengths = c(min, max), tolower = T))
dtm = TermDocumentMatrix(txt, control = list(wordLengths = c(1, Inf), tolower = T))
freq_wise_data = data.frame(as.matrix(dtm))





### Main Word Clouding ##############################################################################



#############
# Single text
#############
if (length(file_list) == 1) {

### Organizing freq_wise_data: column-wise
freq.col = matrix(freq_wise_data[, 1], ncol = length(freq_wise_data[, 1]), byrow = TRUE)
colnames(freq.col) = rownames(freq_wise_data)
# To table, for automatic counting
organized_freq = as.table(freq.col)

### Generating png: single text
png(filename = paste(output_dir, "word_cloud.png", sep = ""))
# Do clouding.
wordcloud( 
rownames(freq_wise_data), # With these words
scale = c (3,.2), # With this range of size of the words
min.freq = 2, # Plot words those are shown more than 2.
max.words = 1000, # Do not plot more than 1000 words.
organized_freq, # Data
random.order = F, 
rot.per = .15, # Proportion of the words with 90 degree rotation
colors = brewer.pal(8, "Accent")) # Coloring
dev.off() # Turn png machine off.



################
# Multiple texts
################
} else {

### Generating png: double texts
png(filename = paste(output_dir, "word_cloud_compare.png", sep = ""))
# Do comparing clouding.
comparison.cloud(freq_wise_data, # Data
max = 400,
scale = c(4, 0.4), 
rot.per = .3,
colors = rep(brewer.pal(8, "Accent"), 2),
title.size = 1)
dev.off()

### Generating png: double texts
png(filename = paste(output_dir, "word_cloud_common.png", sep = ""))
# Do commonizing clouding.
commonality.cloud(freq_wise_data, # Data
scale = c(4, .5),
rot.per = .3, 
colors = brewer.pal(8,"Accent"))
dev.off()
}
