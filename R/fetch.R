dir.create('content/post', showWarnings = FALSE)
d = Sys.Date()

if (!file.exists(f <- 'R/list.txt')) writeLines('website, update', f)
m = read.csv(f, colClasses = "character")
d = as.character(d)
x = NULL
n = 0

for (i in 1:NROW(m)) {
    print(i)
    a <- scifetch::getrss(m[i,1])
    # control the abs length
    if(NROW(a)>0){
        description = paste(
            c(a$description, '[...]'), collapse = ' '
        )
        description = gsub('\\s{2,}', ' ', a$description)
        # fewer characters for wider chars
        description = substr(description, 1, 600 * nchar(description) / nchar(description, 'width'))
        a$description = paste(sub(' +[^ ]{1,20}$', '', description), '...')
        n <- sum(as.POSIXct(a$date[1:NROW(a)])>as.POSIXct(m[i,2]))
    }else{
        n <- 0
    }
    if(n>0){
        temp <- a[1:n,]
        x <- rbind(temp,x)
        ## update date
        m[i,2] <- d
    }
}
if(NROW(x)>0){
    for (i in 1:NROW(x)){
        p = sprintf('content/post/%s.md', paste0(d,'-',i))

        sink(p)
        cat('---\n')
        cat(yaml::as.yaml(x[i,],))
        cat('---\n')
        cat(as.character(x[i,5]))
        sink()
    }
}


write.csv(m[order(m$update), , drop = FALSE], f, row.names = FALSE)
