###########################################################
# 根据书名和分类，找出适合表达书籍的主题 的词汇
# 一个主题词反应出书名属于哪个领域。
# 作者：东北石油大学 计算机与信息技术学院 文必龙 2018.3.29
###########################################################
import jieba.analyse
import pandas as pd
import math
#求累加百分比
def fun_cumpct(arr):
    return arr.cumsum()/arr.sum()

dataPath='数据文件保存路径'
jieba.load_userdict(dataPath+"\\library_new_words.txt")

book = pd.DataFrame(pd.read_excel(dataPath+'\\图书目录.xlsx'))
book=book.loc[:,['书名','图书分类号']] #

book['图书分类号']=book['图书分类号'].str.strip()  #去掉图书分类号前后的空格
book['书名']=book['书名'].str.strip()  #去掉书名前后的空格
book['图书分类号']=book['图书分类号'].str.extract('([A-Z]+)', expand=False) #提取图书分类主码
book=book[book['书名'].notnull() & book['图书分类号'].notnull()] #去掉空值行
book=book.drop_duplicates(['图书分类号','书名']) #去掉重复的，保留第1个
book=book.loc[~ book['图书分类号'].str.startswith('I')] #去掉文学作品，文学作品不参加主题词筛选
book=book.reset_index(drop=True) #重置索引

#从书名中通过分词，建立词条表
words = book.drop('书名', axis=1).join(pd.DataFrame(jieba.analyse.extract_tags(x) for x in book['书名']).stack().reset_index(level=1, drop=True).rename('词条'))

#统计量
# (1)dw_count：为词条在图书分类中出现的次数。
# (2)dw_total为图书分类中所有的词条数目。相同图书分类具有相同的值。相同词条重复个数。
# (3)d_total为图书分类总数。只有一个值,不计重复个数。
# (4)d_count为包含词条的图书分类数。相同词条具有相同的值。
# (5)w_total:词条在图书分类中出现的总次数，重复计数。
# (6)cumsum: 相同词条的记录，按词条在分类中出现次数降序排列时，词条出现次数dw_count的累加和。
# (7)rank:相同词条的记录，按词条在分类中出现次数降序排列时的顺序号，出现频次最多的分类的rank值为1。
# (8)tf:词频,词条在图书分类中出现的次数占该分类中所有词条的比例。
# (9)cumtf: 词频的累加值，同一词条最后行的累加值总是为1。
# (10)tfidf

words['dw_count']=1
words=words.groupby(['图书分类号','词条']).sum()
words.reset_index(inplace=True)
words['dw_total']=words.groupby('图书分类号')['dw_count'].transform('sum')
d_total=book.describe()['图书分类号']['unique']
words['d_count']=words.groupby('词条')['dw_count'].transform('count')
words['w_total']=words.groupby('词条')['dw_count'].transform('sum')
words=words.sort_values(['词条','dw_count'],ascending=[True, False])
words['cumsum']=words.groupby('词条')['dw_count'].cumsum()
words['rank']=words.groupby('词条')['cumsum'].rank()
words['tf']=words['dw_count']/words['w_total']
words['cumtf']=words.groupby('词条')['tf'].cumsum()
words['tfidf'] = words['tf']*(1+d_total/words['d_count']).transform(math.log)
words.to_excel(dataPath+'\\words.xlsx',index=None)

#按照规则，从词条中筛选主题词
topicWords=words.loc[((words['d_count']>=3) & (words['rank']==3) & (words['cumtf']>0.85) & (words['cumsum']>20)) \
                  | ((words['d_count']==2) & (words['w_total']>15)) \
                  | ((words['d_count']==1) & (words['w_total']>6))]

#保存带详细信息的主题词表和简略主题词表
topicWords.to_excel(dataPath+'\\TopicWords_detail.xls',index=None)
topicWords = topicWords.loc[:,['词条']]
topicWords.to_excel(dataPath+'\\TopicWords.xls',index=None)
print('-------------- 主题词表生成完毕 -----------------')