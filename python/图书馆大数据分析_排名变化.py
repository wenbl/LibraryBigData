##################################################
# 根据分析结果绘制4 年热门图书排名变化图
#作者：东北石油大学 计算机与信息技术学院 文必龙
###################################################
import pandas as pd
import matplotlib.pyplot as plt
dataPath='数据文件保存路径'
years =['2014','2015','2016','2017']
index=[1,2,3,4]
words_years = pd.DataFrame()
top_words = pd.DataFrame()
for year in range(len(years)):
    words_year = pd.DataFrame(pd.read_excel(dataPath+'\\借书名TOP20：2014-2017排名变化.xlsx',sheet_name=years[year]))
    words_year['year'] = year
    words_year = words_year.reset_index(drop=False).rename(columns={'index': 'rank1'})
    words_years = words_years.append(words_year)
    top_words = top_words.append(words_year.iloc[0:20])

top_words=top_words['词条'].drop_duplicates()
top_words=pd.DataFrame(top_words.reset_index(drop=True))
words_count = top_words.describe()['词条']['count']
words=pd.merge(pd.DataFrame(top_words),words_years,how='inner')
words['rank2']=  (words.groupby('year')['rank1'].rank()-1).astype(int)

plt.rcParams['font.sans-serif'] = ['SimHei']
plt.figure("图书馆大数据-年度Top20变化")
plt.title(u"图书馆大数据-年度Top20变化")
for word in top_words['词条']:
    points=[]
    for year in range(len(years)):
        theWord = words.loc[(words['词条'] == word) & (words['year'] == year)]
        rank1 = list(theWord['rank1'])[0]
        rank2 = list(theWord['rank2'])[0]
        rank = rank1
        if rank1>=20:
            rank = rank2
            plt.text(year+0.97, 20-rank2-0.7, str(rank1),fontsize = 9)
        points = points+[20-rank]
    plt.plot(index, points, 'o-')
    plt.text(4.1, 20-rank-0.33, word)
plt.plot([0.7,4.7],[0.5,0.5],'--')
plt.xlim(xmax=4.7, xmin=0.7)
plt.xticks(index, years)
plt.xlabel('年度')
ylabel = []
for i in range(20) :
    ylabel = ylabel + [str(20-i)]
plt.yticks(range(1,21), ylabel)
plt.ylabel('排名')
plt.show()
