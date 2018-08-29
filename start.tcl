

###测试脚本变量修改开始------
set gpnIp1 10.10.104.31   ;#拓扑中NE1的IP地址
set userName1 admin       ;#拓扑中NE1的用户名
set password1 greenway    ;#拓扑中NE1的密码
set matchType1 "GPN7600"  ;#拓扑中NE1的host name，例如设备“Device1(config)#”的matchType1为Device1
set Gpn_type1 "7600"      ;#拓扑中NE1的设备类型
### Case2以上增加
set gpnIp2 10.10.104.34
set userName2 admin       ;#拓扑中NE2的用户名
set password2 greenway    ;#拓扑中NE2的密码
set matchType2 "GPN7600"  ;#拓扑中NE2的host name，例如设备“Device2(config)#”的matchType2为Device2
set Gpn_type2 "7600"      ;#拓扑中NE2的设备类型

set gpnIp3 10.10.104.41
set userName3 admin       ;#拓扑中NE1的用户名
set password3 greenway    ;#拓扑中NE1的密码
set matchType3 "GPN7600"  ;#拓扑中NE1的host name，例如设备“Device1(config)#”的matchType1为Device1
set Gpn_type3 "7600"      ;#拓扑中NE1的设备类型

set gpnIp4 10.10.104.42
set userName4 admin       ;#拓扑中NE1的用户名
set password4 greenway    ;#拓扑中NE1的密码
set matchType4 "GPN7600"  ;#拓扑中NE1的host name，例如设备“Device1(config)#”的matchType1为Device1
set Gpn_type4 "7600"      ;#拓扑中NE1的设备类型

set managePort1 "17/1";#NE1设备的管理口
set managePort2 "17/1";#NE2设备的管理口
set managePort3 "17/1";#NE3设备的管理口
set managePort4 "17/1";#NE4设备的管理口

dict set ftp ip "10.10.32.23"  ;#ftp服务器的ip地址
dict set ftp userName "racheltang"  ;#ftp服务器的用户名
dict set ftp passWord "123456" ;#ftp服务器的密码

set stcIp 10.16.50.195 ;#STC的ip地址

set GPNStcPort1 "//10.16.50.195/7/4"; #拓扑中TC1(TC的端口号)
set GPNTestEth1 2/3;				  #拓扑中与TC1连接的设备端口号
set GPNEth1Media ethernetFiber;              #拓扑中TC1使用的截止Copper(电口)	1gf(千兆光口)	10gf(万兆光口) 
set GPNTestEthMgt 1/2;                #将NE1设备设为网关网元

set GPNStcPort2 "//10.16.50.195/7/3"; #拓扑中TC1(TC的端口号)
set GPNTestEth2 4/4;				  #拓扑中与TC1连接的设备端口号
set GPNEth2Media ethernetFiber;              #拓扑中TC1使用的截止Cooper(电口)	1gf(千兆光口)	10gf(万兆光口) 

###请根据拓扑图修改下面的端口的值（对应P1-P24），对于被测拓扑中没有用的端口可以忽略不做修改------
set GPNPort1 2/1
set GPNPort2 1/1
set GPNPort3 13/2
set GPNPort4 13/1
set GPNPort5 1/4
set GPNPort6 4/1
set GPNPort7 7/4
set GPNPort8 7/2
set GPNPort9 2/3
set GPNPort10 4/4
set GPNPort11 1/1
set GPNPort12 7/1
set GPNPort13 2/4
set GPNPort14 1/1
set GPNPort15 16/1
set GPNPort16 1/4
set GPNPort17 1/1
set GPNPort18 1/2
set GPNPort19 16/7
set GPNPort20 16/8
###------请根据拓扑图修改下面的端口的值（对应P5-P24），对于被测拓扑中没有用的端口可以忽略不做修改

###------请选择需要创建进行测试的LSP组数
set lsp_num 128
###------设置LSP1:1组数结束
set Worklevel "L2"   ;#设备工作的层数  = L3/l2
set SoftVer "PTN"  ;#软件版本  = IPRAN /PTN
set trunkLevel "L2"  ;#trunk口工作的层数                   
set lDev1TestPort "1/1 1/2 1/3 1/4 10/1 10/2" ;#NE1被测端口列表，请添加任意6个实际存在的端口
set topology "T1"  ;# 举例： ="T1" 说明使用拓扑一   ="T2" 说明使用拓扑二 
###------测试脚本变量修改结束



###程序运行区请勿修改----------
package require gwd 2.0
package require stcPack
file mkdir "report"
set fileId [open "report\\start_REPORT.txt" a+]
set fd_log [open "report\\start_log.txt" a+]

set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
gwd::GWpublic_SaveCfg $telnet1 $matchType1 $Gpn_type1 $fileId
set upCnt 3
while {[gwd::GW_AddUploadFile $telnet1 $matchType1 $Gpn_type1 $fileId [dict get $ftp ip] [dict get $ftp userName] \
			[dict get $ftp passWord] "config" "NE1.txt" "" "60"]} {
		incr upCnt -1
		if {$upCnt == 0} {
			puts "连续3次上传$matchType1\的config文件都失败，请检查ftp服务器的连通性"
			exit
		}
}
if {![string match -nocase "T1" $topology]} {
	set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
	gwd::GWpublic_SaveCfg $telnet2 $matchType2 $Gpn_type2 $fileId
	set upCnt 3
	while {[gwd::GW_AddUploadFile $telnet2 $matchType2 $Gpn_type2 $fileId [dict get $ftp ip] [dict get $ftp userName] \
			[dict get $ftp passWord] "config" "NE2.txt" "" "60"]} {
			incr upCnt -1
			if {$upCnt == 0} {
				puts "连续3次上传$matchType2\的config文件都失败，请检查ftp服务器的连通性"
				exit
			}
	}
}

set telnet3 [gwd::GWpublic_loginGpn $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 $fileId]
gwd::GWpublic_SaveCfg $telnet3 $matchType3 $Gpn_type3 $fileId

set upCnt 3
while {[gwd::GW_AddUploadFile $telnet3 $matchType3 $Gpn_type3 $fileId [dict get $ftp ip] [dict get $ftp userName] \
		[dict get $ftp passWord] "config" "NE3.txt" "" "60"]} {
	incr upCnt -1
	if {$upCnt == 0} {
		puts "连续3次上传$matchType3\的config文件都失败，请检查ftp服务器的连通性"
			exit
	}
}

 set telnet4 [gwd::GWpublic_loginGpn $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $fileId]
	gwd::GWpublic_SaveCfg $telnet4 $matchType4 $Gpn_type4 $fileId
	set upCnt 3
	while {[gwd::GW_AddUploadFile $telnet4 $matchType4 $Gpn_type4 $fileId [dict get $ftp ip] [dict get $ftp userName] \
		[dict get $ftp passWord] "config" "NE4.txt" "" "60"]} {
		incr upCnt -1
		if {$upCnt == 0} {
			puts "连续3次上传$matchType4\的config文件都失败，请检查ftp服务器的连通性"
			exit
		}
	}  


set GPNPortList "GPNPort1 $GPNPort1 GPNPort2 $GPNPort2 GPNPort3 $GPNPort3 GPNPort4 $GPNPort4 GPNPort5 $GPNPort5 GPNPort6 $GPNPort6 GPNPort7 $GPNPort7 \
  GPNPort8 $GPNPort8 GPNPort9 $GPNPort9 GPNPort10 $GPNPort10 GPNPort11 $GPNPort11 GPNPort12 $GPNPort12 GPNPort13 $GPNPort13 GPNPort14 $GPNPort14 \
  GPNPort15 $GPNPort15 GPNPort16 $GPNPort16 GPNPort17 $GPNPort17 GPNPort18 $GPNPort18 GPNPort19 $GPNPort19 GPNPort20 $GPNPort20"
set path {test}              
if {0 == [file isdirectory $path] } {
   puts "file directory error!"
   exit
}

## 获取文件列表
set fileList ""
set pattern "$topology*tcl"
set fileList [glob -nocomplain $path/$pattern]
if {$fileList == ""} {
	puts "没有需要运行的脚本，请检查变量topology的值是否填写正确"
} else {
	puts "需要运行的脚本："
	foreach i $fileList {
		puts $i
	} 
}

### 执行该目录下所有tcl脚本
foreach i $fileList {
    puts "[clock format [clock seconds]]  $i\开始执行"
    if {[catch {
	exec tclsh $i $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $managePort1 $GPNPortList $ftp $Worklevel $SoftVer $trunkLevel $lDev1TestPort \
		      $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 \
		      $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $stcIp $GPNStcPort1 $GPNTestEth1 $GPNEth1Media \
		      $GPNStcPort2 $GPNTestEth2 $GPNEth2Media $managePort2 $managePort3 $managePort4 $GPNTestEthMgt $lsp_num

    } err]} {
    	puts $err
		puts "脚本运行异常"    
	    #set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
		#gwd::GWmanage_ftpDownload $telnet1 $matchType1 $Gpn_type1 $fileId $fd_log 60 "config" [dict get $ftp ip] [dict get $ftp userName] \
		#	[dict get $ftp passWord] "NE1.txt" ""
		#gwd::GWpublic_Reboot $telnet1 $matchType1 $Gpn_type1 $fileId
	#
		#set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
		#gwd::GWmanage_ftpDownload $telnet2 $matchType2 $Gpn_type2 $fileId $fd_log 60 "config" [dict get $ftp ip] [dict get $ftp userName] \
		#	[dict get $ftp passWord] "NE2.txt" ""
		#gwd::GWpublic_Reboot $telnet2 $matchType2 $Gpn_type2 $fileId
#
        #set telnet3 [gwd::GWpublic_loginGpn $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 $fileId]
		#gwd::GWmanage_ftpDownload $telnet3 $matchType3 $Gpn_type3 $fileId $fd_log 60 "config" [dict get $ftp ip] [dict get $ftp userName] \
		#	[dict get $ftp passWord] "NE3.txt" ""
		#gwd::GWpublic_Reboot $telnet3 $matchType3 $Gpn_type3 $fileId
		#set telnet4 [gwd::GWpublic_loginGpn $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $fileId]
		#	gwd::GWmanage_ftpDownload $telnet4 $matchType4 $Gpn_type4 $fileId $fd_log 60 "config" [dict get $ftp ip] [dict get $ftp userName] \
		#		[dict get $ftp passWord] "NE4.txt" "" 
		#	gwd::GWpublic_Reboot $telnet4 $matchType4 $Gpn_type4 $fileId
    }
	after 6000
    puts "[clock format [clock seconds]]  $i\执行结束"
  
}
after 5000
puts [clock format [clock seconds]]
puts "end end end"
###----------程序运行区请勿修改


