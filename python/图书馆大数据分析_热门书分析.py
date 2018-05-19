##################################################
# 基于图书馆书籍借阅数据，对书籍借阅情况进行分析
# 哪些书被借次数最多，反映出读者学习方向
#作者：东北石油大学 计算机与信息技术学院 文必龙
###################################################
import jieba
import jieba.analyse
#from scipy.misc import imread
from wordcloud import WordCloud
import pandas as pd
import matplotlib.pyplot as plt

dataPath='数据文件保存路径'
jieba.load_userdict(dataPath+"\\library_new_words.txt")
topicWords = pd.DataFrame(pd.read_excel(dataPath+'\\TopicWords.xls'))
book = pd.DataFrame(pd.read_excel(dataPath+'\\图书目录.xlsx'))
book['书名']=book['书名'].str.strip()

book=book[book['书名'].notnull() & book['图书分类号'].notnull()] #去掉空值行
book=book.drop_duplicates(['图书分类号','书名']) #去掉重复的，保留第1个
book=book.reset_index(drop=True) #重置索引

operation = pd.DataFrame(pd.read_excel(dataPath+'\\图书借还2017.xlsx'))
borrowed = operation.loc[(operation['操作类型']=='借'),['图书ID']]
borrowed=pd.merge(borrowed,book,how='left').loc[:,['图书分类号','书名']]  #按"图书ID"进行关联
borrowed=borrowed[borrowed['书名'].notnull() & borrowed['图书分类号'].notnull()] #去掉空值行
borrowed=borrowed.reset_index(drop=True)

#borrowed = borrowed.loc[borrowed['图书分类号'].str.startswith('I')]
words=borrowed.loc[borrowed['图书分类号'].str.startswith('I')]['书名'] #文学类的不分词，直接用书名作主题词
words = pd.DataFrame(words.rename('词条'))
#words = words.rename(columns={'词条'})
words_noi = borrowed.loc[~borrowed['图书分类号'].str.startswith('I'),['书名']] #非文学类的
words_noi = pd.DataFrame(jieba.analyse.extract_tags(x) for x in words_noi['书名']).stack().reset_index(level=1,drop=True).rename('词条')
words_noi=pd.merge(pd.DataFrame(words_noi),topicWords,how='inner')  #求words_noi与topicWords交集
words = words.append(words_noi)

words['count']=1
words=words.groupby('词条').sum()
words = words.sort_values(['count'],ascending=[False])[0:300]
words.reset_index(inplace=True)
words.to_excel(dataPath+'\\借书2017_top300.xls',index=None)

words_freq= dict(zip(words['词条'], words['count'])) #将DataFrame的两列转换为字典
word_cloud = WordCloud(font_path = 'C:\Windows\Fonts\simhei.ttf' # 设置字体,simsun.ttc,simhei.ttf
    ,width=1024, height=800, background_color='white'  # 背景颜色
                       , max_words=300  # 词云显示的最多词数
                       , max_font_size=80  # 最大字体的尺寸
                       )
word_cloud.generate_from_frequencies(words_freq)
plt.imshow(word_cloud)
plt.axis("off")
plt.show()
word_cloud.to_file(dataPath+'\\借书2017_top300.png') # 保存图片
print('-------------- 热门书分析完毕 -----------------')
