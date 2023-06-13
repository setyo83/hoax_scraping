library(rvest)
library(tidyverse)
library(mongolite)

url<-"https://www.kominfo.go.id/"
hoax<-read_html(url)

### Judul Berita

h1<-hoax %>% html_nodes(".index--title-hoax") %>% html_text2()
judul <-  gsub("^.*]", "",h1)

### Link Berita

h2<-hoax %>% html_nodes(".index--title-hoax") %>% html_nodes("a") %>% html_attr('href')
link_berita<-paste0(url,h2)

### Tanggal Berita

tanggal<-c()
for (i in 1:length(link_berita)){
  urlb<-read_html(link_berita[i])
  tanggal[i]<-urlb %>% html_nodes(".date") %>% html_text2()
  tanggal[i]<-gsub("\\s","-",tanggal[i])
}


### Kategori Berita

kategori <-  gsub("].*"," ",h1)
kategori <- gsub("\\W","",kategori)

### Data Hasil

hasil <- data.frame(kategori,judul,link_berita,tanggal)

#MONGODB
message('Upload Data To MongoDB Atlas')
atlas_conn <- mongo(
  collection = Sys.getenv("ATLAS_COLLECTION"),
  db         = Sys.getenv("ATLAS_DB"),
  url        = Sys.getenv("ATLAS_URL")
)

atlas_conn$insert(hasil)
rm(atlas_conn)
