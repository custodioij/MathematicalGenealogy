## MGP scrapping
library(XML)
library(RCurl)

# Should the year of first degree be added after the name, in parentheses?
add_year = TRUE

# Build the beginning of the tree here.
starting.persons = data.frame("id"=c(1, 2, 3, 4, 5),"mgp.id"=c(NA, 278115, NA, 167610, 125339),
                              name=c("Igor Custodio João", NA,
                                     "Julia Schaumburg (2013)", NA,
                                     NA))
genealogy <- starting.persons
supervise <- cbind(c(1, 1, 3, 3), c(2, 3, 4, 5))

cur.person = 1
while (sum(is.na(genealogy$name)>0)) {
  print(cur.person)
  if (!is.na(genealogy$mgp.id[genealogy$id==cur.person])){
    # create the url for the current person and extract the data from the web
    cur.mgp.id = genealogy$mgp.id[cur.person]
    cur.url = paste(base.url,cur.mgp.id,sep="")
    cur.page = htmlTreeParse(getURL(cur.url), useInternalNodes = TRUE, encoding="utf-8")
    
    # search for the mathematician's name
    cur.name = xpathApply(cur.page, "//h2", xmlValue)
    cur.name = gsub("\n","",cur.name)
    print(cur.name)
    genealogy$name[genealogy$id==cur.person] = cur.name
    
    # search for the number of supervisors
    nbadv = grep("Advisor",xpathApply(cur.page,"//p",xmlValue),value=TRUE)
    countadv = sum(sapply(nbadv, function(x) sum(unlist(sapply(1:10,function(ind)
      grep(as.character(ind),x))))))
    if (countadv==0) {
      if (length(grep("Unknown",nbadv))==0) countadv = 1
    }
    
    # Add the year of first PhD
    if (add_year){
      sYear <- gsub('.*</span>.([0-9]{3,4})</span>.*',"\\1", as(cur.page, "character"))
      if (nchar(sYear) > 4) {sYear = "?"}  # failsafe
      print(sYear)
      genealogy$name[genealogy$id==cur.person] = paste0(cur.name, " (", sYear, ")")
    }
    
    # search for the supervisors ids
    if (countadv>0) {
      advisors = xpathSApply(cur.page, "//a[contains(@href, 'id.php?id')]",
                             xmlAttrs)
      advisors = advisors[1:countadv]
      all.ids = sapply(advisors,function(x) gsub("[id.php?id=]","",x,perl=FALSE))
      # removed already existing supervisors
      existing.ids = all.ids[all.ids%in%genealogy[,2]]
      all.ids = setdiff(all.ids,existing.ids)
      if (length(all.ids)>0) {
        adv.data = data.frame("id"=seq(max(genealogy$id)+1,
                                       max(genealogy$id)+length(all.ids),by=1),
                              "mgp.id"=all.ids,"name"=rep(NA,length(all.ids)))
        # update supervise
        supervise = rbind(supervise,cbind(rep(cur.person,countadv),
                                          c(genealogy$id[match(existing.ids,
                                                               genealogy$mgp.id)],
                                            seq(max(genealogy$id)+1,
                                                max(genealogy$id)+length(all.ids),
                                                by=1))))
        # add new advisors
        genealogy = rbind(genealogy,adv.data)
      } else {
        # if no new advisors, just update supervise
        supervise = rbind(supervise,cbind(rep(cur.person,countadv),
                                          genealogy$id[match(existing.ids,
                                                             genealogy$mgp.id)]))
      }
    }
  }
  cur.person = cur.person+1
}


save(supervise, genealogy ,file="mygenealogy.rda")
# load("mygenealogy.rda")

#--------
# define the tree as an igraph object
library(igraph)
# genealogy.tree = graph.data.frame(cbind(supervise[,2],supervise[,1]),
#                                   directed=TRUE,vertices=genealogy)
genealogy.tree <- graph_from_data_frame(cbind(supervise[,2],supervise[,1]),
                      directed=TRUE,vertices=genealogy)
save(supervise, genealogy, genealogy.tree, file="mynewgenealogy.rda")

# export it for graphviz
V(genealogy.tree)$label = V(genealogy.tree)$name
write.graph(genealogy.tree, file="genealogyTree.dot", format="dot")


#--------
# This needs graphviz. See https://www.graphviz.org/download/ for more information
# On a Mac with Homebrew, it suffices to run "brew install graphviz"
system("dot -Tpng genealogyTree.dot > genealogyTree.png")
