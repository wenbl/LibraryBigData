###########################################################
# 根据书名和分类，找出适合表达书的主题 的词汇
# 一个主题词反应出书名属于哪个领域。
# 作者：东北石油大学 计算机与信息技术学院 文必龙 2018.3.29
###########################################################
library(jiebaR)
library(openxlsx)
library(dplyr)
library(tidyr)
library(stringr)

dataPath='数据文件保存路径'
cutter=worker(user=paste(dataPath,"\\library_new_words.txt",sep=""),
     stop_word = paste(dataPath,"\\stopwords.txt",sep=""))#设置分词引擎
book = read.xlsx(paste(dataPath,"\\图书目录.xlsx",sep=""),sheet=1)
book = subset(book,,select=c("图书分类号","书名"))
book$图书分类号 = str_trim(book$图书分类号)
book$书名=str_trim(book$书名)

book$图书分类号=str_extract(book$图书分类号,'([A-Z]+)') #提取图书分类主码
book=na.omit(book) #去掉空值行
book = unique(book) #去掉重复的，保留第1个
book = book[which(str_sub(book$图书分类号,1,1)!="I"),] 

#从书名中通过分词，建立关键字表
book$词条=apply(matrix(book$书名),1,function(x) paste(segment(x,cutter), collapse = "\t"))
words=separate_rows(book, 词条, sep = "\t")
words=words[,c('图书分类号','词条')]

subset(words,词条=="程序设计" & 图书分类号=="TH")

#subset(words,词条=='程序设计')
#统计量：
# (1)dw_count：为词条在图书分类中出现的次数。
# (2)dw_total为图书分类中所有的词条数目。相同图书分类具有相同的值。相同词条重复个数。
# (3)d_total为图书分类总数。只有一个值,不计重复个数。
# (4)d_count为包含词条的图书分类数。相同词条具有相同的值。
# (5)w_total:词条在图书分类中出现的总次数，重复计数。
# (6)cumsum: 相同词条的记录，按词条在分类中出现次数降序排列时，词条出现次数dw_count的累加和
# (7)rank:相同词条的记录，按词条在分类中出现频次降序排列时的顺序号，频次最多的分类的rank值为1。
# (8)tf:词频词频,词条在图书分类中出现的次数占该分类中所有词条的比例。
# (9)cumtf: 词频的累加值，同一词条最后行的累加值总是为1。
# (10)tfidf:TF-IDF权重值

words = summarise(group_by(words, 图书分类号, 词条),dw_count = n()) #1
words = merge(words,summarise(group_by(words, 图书分类号),dw_total = sum(dw_count)),by='图书分类号')
d_total = length(unique(words$图书分类号))
words=merge(words,summarise(group_by(words, 词条),d_count = n()))
words = merge(words,summarise(group_by(words, 词条),w_total = sum(dw_count)),by='词条')

words = arrange(words,词条,desc(dw_count)) # 按词/词数进行排序
words = transform(words,cumsum=unlist(tapply(dw_count,词条,cumsum))) #求dw_count累加和
words = transform(words,rank=unlist(tapply(cumsum,词条,rank))) #组内按累加和排名
words$tf = words$dw_count/words$w_total
words$cumtf = words$cumsum/words$w_total
words =  transform(words,tfidf=tf*log(d_total/(1+d_count),10))
write.xlsx(x = words,file =  paste(dataPath,"\\words_R.xlsx",sep=""),colNames = TRUE)


#按照规则，从关键字中筛选主题词
topicWords=words[which(words$d_count>=3 & words$rank==3 & words$cumtf>0.85 & words$cumsum>20
                  | words$d_count==2 & words$rank==1 & words$w_total>15 
                  | words$d_count==1 & words$w_total>6),]
topicWords = topicWords[which(str_length(topicWords$词条)>1),]
#保存带详细信息的主题词表和简略主题词表
write.xlsx(topicWords,paste(dataPath,"\\TopicWords_detail_R.xlsx",sep=""),colNames=TRUE)
write.xlsx(subset(topicWords, ,select=c("词条")),paste(dataPath,"\\TopicWords_R.xlsx",sep=""),colNames=TRUE)
print('-------------- 主题词表生成完毕 -----------------')