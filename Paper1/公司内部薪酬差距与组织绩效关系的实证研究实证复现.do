cd "/Users/xrb/Desktop/文章复现/Paper_Replication/Paper1"



*******************************************************公司内部薪酬差距与组织绩效关系的实证研究实证复现****************************************************

***************************************************************************************************************************************************
*******************************************************数据清洗与合并*********************************************************************************
***************************************************************************************************************************************************

global path "/Users/xrb/Desktop/文章复现/1公司内部薪酬差距与组织绩效关系的实证研究/data"


//转换数据格式

import excel "/Users/xrb/Desktop/文章复现/1公司内部薪酬差距与组织绩效关系的实证研究/raw/中国上市公司股权性质文件162720783(仅供北京交通大学使用)/EN_EquityNatureAll.xlsx",firstrow clear //第一行作为变量名

labone, nrow(1 2) concat("_") //使用前两行生成标签，用_连接

drop in 1/2 //删除前两行

destring _all,replace //把所有字符型变量转为数值型

gen year = substr(Accper,1,4) //生成年份变量并转为数值型
destring year,replace

save "$path/股权性质及十大股东占比.dta",replace


//继续，此处复制粘贴更换文件路径即可，没有继续用代码形式呈现
import excel "/Users/xrb/Desktop/文章复现/1公司内部薪酬差距与组织绩效关系的实证研究/raw/内控评价报告信息表182325784(仅供北京交通大学使用)/IC_EvaluationRepInfo.xlsx",firstrow clear //第一行作为变量名
labone, nrow(1 2) concat("_") //使用前两行生成标签，用_连接
drop in 1/2 //删除前两行
destring _all,replace //把所有字符型变量转为数值型
gen year = substr(Accper,1,4) //生成年份变量并转为数值型
destring year,replace
save "$path/行业.dta",replace






//匹配合并
use "$path/高管薪酬.dta",clear


//逐个文档合并
merge 1:1 Stkcd year using "$path/行业.dta"
drop if _merge != 3 //删除未匹配样本
drop _merge //删除merge变量
save "$path/merged_data.dta",replace

//调整一下变量名，保留有用的变量，提高可读性

//生成论文所需的变量

gen ROA = Profit/total_assets
label variable ROA "总资产收益率"

gen GAP1 = ln(top3_pay/3 - (totaltop_pay-top3_pay)/(top_num-3)) 
label variable GAP1 "高管内部薪资差距"

gen SIZE = ln(total_assets) // 产生一个新变量，公司规模用资产的对数表示
label var SIZE "公司规模"  // 为变量加标签

gen GAP2 = ln((totaltop_pay - top3_pay)/(top_num - 3)-(Emp_salary-totaltop_pay)/(Emp_num-top_num))
label var GAP2 "高管与员工间的薪资差距"

//把行业代码转换为数值型分类变量，用来控制行业固定效应
encode IndustryCode, gen(Ind)
encode CONT, gen(CONT1)  //股权性质分类变量


order Stkcd year ROA GAP1 GAP2 SIZE H10 CONT1 Ind

//剔除缺失值
drop if ROA ==.
drop if GAP1 ==.
drop if GAP2 ==.
drop if SIZE ==.

*-在1和99分位上缩尾处理
winsor2 ROA GAP1 GAP2 SIZE H10, replace cut(1 99)


***************************************************************************************************************************************************
*******************************************************。实证回归*********************************************************************************
***************************************************************************************************************************************************
use "/Users/xrb/Desktop/文章复现/Paper_Replication/Paper1/data/merged_data.dta",clear //重新导入数据

*-描述性统计
logout,save(描述性统计) word replace :tabstat  ROA GAP1 GAP2 SIZE H10 CONT1,stat(n mean sd min max p25 p50 p75 ) col (stat) f(%9.3f)
// logout,save(1) word replace : sum ROA GAP1 GAP2 SIZE H10 CONT1 

*-相关性系数
// pwcorr_a ROA GAP1 GAP2 SIZE H10 CONT1  
logout,save(相关性分析) word replace : pwcorr_a ROA GAP1 GAP2 SIZE H10 CONT1 

**回归，文中提到用FGLS 广义最小二乘法，那奈何小哥哥不会呀，没办法那就用OLS 和带固定效应模型来回归吧hhhhh

*简单的回归，不控制行业和年度
reg ROA GAP1  SIZE H10 CONT1 
eststo m1 
reg ROA GAP2 SIZE H10 CONT1
eststo m2
*回归，控制行业和年度；前面加xi：后面加i.ind i.Accper，程序会自动控制
reg ROA GAP1 SIZE H10 CONT1 i.Ind i.year
estadd local Time_fix "YES" 
estadd local Ind_fix "YES"
eststo m3
reg ROA GAP2 SIZE H10 CONT1 i.Ind i.year
estadd local Time_fix "YES" 
estadd local Ind_fix "YES"
eststo m4
*加入固定效应，回归
xtset Stkcd year // 申明面板数据
xtreg ROA GAP1 SIZE H10 CONT1 i.Ind i.year, fe
estadd local Time_fix "YES" 
estadd local Ind_fix "YES"
estadd local Indiv_fix "YES"
// estadd local 时间固定效应 "YES" 
// estadd local 行业固定效应 "YES"
// estadd local 个体固定效应 "YES"
eststo m5
xtreg ROA GAP2 SIZE H10 CONT1 i.Ind i.year, fe
// estadd local 时间固定效应 "YES" 
// estadd local 行业固定效应 "YES"
// estadd local 个体固定效应 "YES"
estadd local Time_fix "YES" 
estadd local Ind_fix "YES"
estadd local Indiv_fix "YES"
eststo m6

//导出结果
esttab m1 m2 m3 m4 m5 m6 using 回归结果.rtf, se drop(*.year *.Ind) s(N r2 Time_fix Ind_fix Indiv_fix) nogap title(Regression Results) star compress replace
