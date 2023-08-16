cd "/Users/xrb/Desktop/文章复现/1公司内部薪酬差距与组织绩效关系的实证研究"



*******************************************************公司内部薪酬差距与组织绩效关系的实证研究实证复现****************************************************


*******************************************************数据清洗与合并*********************************************************************************

global path "/Users/xrb/Desktop/文章复现/1公司内部薪酬差距与组织绩效关系的实证研究/data"


//转换数据格式

import excel "/Users/xrb/Desktop/文章复现/1公司内部薪酬差距与组织绩效关系的实证研究/raw/中国上市公司股权性质文件162720783(仅供北京交通大学使用)/EN_EquityNatureAll.xlsx",firstrow clear //第一行作为变量名

labone, nrow(1 2) concat("_") //使用前两行生成标签，用_连接

drop in 1/2 //删除前两行

destring _all,replace //把所有字符型变量转为数值型

gen year = substr(Accper,1,4) //生成年份变量并转为数值型
destring year,replace

save "$path/股权性质及十大股东占比.dta",replace


//继续
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

order Stkcd year ROA GAP1 GAP2 SIZE H10 CONT

//剔除缺失值
drop if ROA ==.
drop if GAP1 ==.
drop if GAP2 ==.
drop if SIZE ==.

*-在1和99分位上缩尾处理
winsor2 ROA GAP1 GAP2 SIZE H10, replace cut(1 99)
