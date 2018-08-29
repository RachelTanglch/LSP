#!/bin/sh
# LSP_Mode_Function.tcl \
exec tclsh "$0" ${1+"$@"}

########################################################################################################
	#函数功能：测试报告中打印的异常输出
	#输入参数：saveflag：=1需要保存配置并打印保存信息  =0不需要保存只需要打印保存信息 
	#	  lSpawn_id：设备spawn_id的列表
	#         lMatchType：匹配命令行节点用字符串列表
	#         lDutType：设备类型列表
	#         fileId：报告文件描述符
	#	  fd_log：测试log的文件描述符
	#	  startSeconds：脚本开始运行的时间，单位s
	#         lIp：设备ip列表
	#         cfgKey：上传的配置文件特殊的文字描述（防止每次上传文件覆盖前面上传的文件）
	#         testFile：测试报告的名字（不包含_report  _log字段）
	#输出参数  ：lFailFile：上传失败的文件名称列表
	#返回值：  flagErr：上传是否成功的标志   [regexp {[^0\s]} $flagErr]==1 失败    =0成功
	#作者：邓娟
########################################################################################################
	proc GWpublic_uploadDevCfg {saveflag lSpawn_id lMatchType lDutType fileId fd_log startSeconds lIp ftp cfgKey testFile lFailFile} {
		upvar $lFailFile lFileTmp
		set lFileTmp ""
		set flagErr 0
		puts $fileId ""
		puts $fileId "===设备配置导出开始...\n"
		if {$saveflag == 1} {
			foreach spawn_id $lSpawn_id matchType $lMatchType dutType $lDutType ip $lIp {
				set uploadFlag 0
				lappend uploadFlag [gwd::GWpublic_SaveCfg $spawn_id $matchType $dutType $fileId]
				lappend uploadFlag [gwd::GW_AddUploadFile $spawn_id $matchType $dutType $fileId [dict get $ftp ip] [dict get $ftp userName] \
						[dict get $ftp passWord] "config" "$testFile\_$cfgKey\_$ip.txt" "" "60"]
				if {[regexp {[^0\s]} $uploadFlag]} {
					lappend flagErr 1
					lappend lFileTmp "$testFile\_$cfgKey\_$ip.txt"
				} else {
					lappend flagErr 0
				}
#        			gwd::GWpublic_printAbnormal $fileId $fd_log $uploadFlag "FLAGF" $startSeconds "在$matchType\上导出配置文件$testFile\_$cfgKey\_$ip.txt到ftp服务器存放目录失败" \
#        				"在$matchType\上导出配置文件到ftp服务器存放目录成功" $testFile
			}
		} else {
			set flagErr [lrepeat [expr [llength $lSpawn_id]+1] 0]
		}
		foreach ip $lIp flag [lrange $flagErr 1 end] {
			if {$saveflag == 1} {
				if {$flag == 0} {
					gwd::GWpublic_print "OK" "ip=$ip\的配置文件上传成功，文件名称为$testFile\_$cfgKey\_$ip.txt" $fileId
				} else {
					gwd::GWpublic_print "NOK" "ip=$ip\的配置文件上传失败，文件名称为$testFile\_$cfgKey\_$ip.txt" $fileId
				}
				
			} else {
				puts $fileId "文件名称为$testFile\_$cfgKey\_$ip.txt"
			}
		}
		puts $fileId ""
		puts $fileId "===设备配置导出结束...\n"
		return [regexp {[^0\s]} $flagErr]
	}
########################################################################################################
	#函数功能：测试报告中打印的异常输出
	#输入参数： fileId：测试报告的文件描述符
	#	  fd_log：测试log的文件描述符
	#         flagErr：测试结果
	#         flagType：答应的错误类型
	#	  startSeconds：脚本开始运行的时间，单位s
	#         printWord1：测试结果错误打印的字符串(如果flagType=FLAGF 此变量为上传失败的配置文件名称列表)
	#         printWord2：测试结果正确打印的字符串
	#         fileName：测试报告的名字（不包含_report  _log字段）
	#输出参数  ：无
	#返回值：  无
	#作者：邓娟
	########################################################################################################
proc GWpublic_printAbnormal {fileId fd_log flagErr flagType startSeconds printWord1 printWord2 fileName} {
		if {[regexp {[^0\s]} $flagErr]} {
			if {[string match "FLAGF" $flagType]} {
				gwd::GWpublic_print "== FLAGF == NOK" "（结论）测试过程中配置文件上传" $fileId
				puts $fileId "上传失败的配置文件有：" 
				foreach f $printWord1 {
					puts $fileId "		$f"
				}
			} else {
				gwd::GWpublic_print "NOK" "== $flagType ==（结论）$printWord1" $fileId
				if {[string match "FLAGE" $flagType] || [string match "FLAGA" $flagType]} {
					chan seek $fileId 0
					puts $fileId ""
					puts $fileId "**************************************************************************************"
					puts $fileId ""
					puts $fileId "**************************************************************************************"
					puts $fileId ""
					set startTime [clock format $startSeconds -format "%Y-%m-%d,%H:%M:%S"]
					set endSeconds [clock seconds]
					set endTime [clock format $endSeconds -format "%Y-%m-%d,%H:%M:%S"]
					
					puts $fileId ""
					puts $fileId "脚本开始运行时间为$startTime"
					puts $fileId "脚本运行结束时间为$endTime"
					puts $fileId "运行时长为：[expr [expr $endSeconds-$startSeconds]/60] 分钟"
					puts $fileId ""
					if {[string match "FLAGE" $flagType]} {
						puts $fileId "== FLAGE ==运行异常：错误为$printWord1"
					} else {
						gwd::GWpublic_print "NOK" "== $flagType ==（结论）$printWord1" $fileId
					}
					puts $fileId ""	
					puts $fileId "===测试未完成......"
					puts $fileId ""	
					puts $fileId "**************************************************************************************"
					puts $fileId ""
					puts $fileId "**************************************************************************************"
					puts $fileId ""
					close $fileId
					file rename "report\\$fileName\_REPORT.txt" "report\\INCOMPLETE_$fileName\_REPORT.txt"
					log_file
					close $fd_log
					file rename "log\\$fileName\_LOG.txt" "log\\INCOMPLETE_$fileName\_LOG.txt"
					exit 1
				}
			}
		} else {
			puts $fileId ""
			gwd::GWpublic_print "OK" "== $flagType ==（结论）$printWord2" $fileId
			return 0
		}
	}

########################################################################################################
#函数功能：查询vpls表项
#输入参数: fileId:测试报告的文件id
#         type:ac/pw
#     typename:ac/pw名称
#     vplsname:vpls名称
#     GPN_type:设备类型
#       GPN_Id:spawn id
#输出参数：无
#返回值： tableList：vpls表项列表
#作者：吴军妮
########################################################################################################
proc GPN_QueryVPLSForwardTable1 {fileId type typename vplsname GPN_type GPN_Id} {
  set flagErr 0
  set tableList ""
  expect {
    -i $GPN_Id
    -re "$matchType\\(config\\)#" {exp_send -i $GPN_Id "show forward-entry $type $typename vpls $vplsname\r"}
    timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}
  }
  after 30000;exp_send -i $GPN_Id "\r"
 for {set j 1} {$j<=100} {incr j} {
   expect {
     -i $GPN_Id
     -re {.+} {exp_send -i $GPN_Id "\r"}
     after 1000;exp_send -i $GPN_Id "\r"
     }
 }
  expect {
     -i $GPN_Id
     -re {.+} {
     set tableList [regexp  -all -inline -nocase -line "(?:\[0-9|a-f|\.]+){3}\\s+$vplsname\\s+\[a-z|0-9|_]+.+" $expect_out(0,string)]
     exp_send -i $GPN_Id "\r"}   
     timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}  
   }
  puts -nonewline $fileId [format "%-59s" "在GPN上查询vpls表项"]
  if {$flagErr} {
    puts $fileId "NOK"   
  } else {
    puts $fileId "OK" 
  }
  return $tableList
}

########################################################################################################
#函数功能：GPN上报文过滤测试
#输入参数: RunFlag ：测试项标志位
#输出参数：flag:数据转发结果判断标志位
#返回值： 无
########################################################################################################
proc PTN_ElanMessageRestrain {RunFlag flag} {
upvar $flag aTempFlag
set aTempFlag 0
foreach i "GPNPort1Cnt1 GPNPort2Cnt1 GPNPort3Cnt1" {
  array set $i {cnt10 0 cnt11 0 cnt44 0} 
}
gwd::Start_SendFlow "$::hGPNPort4Gen"  $::hGPNPortAnaList
after $::sendTime
classificationStatisticsPortRxCnt4 1 $::hGPNPort2Ana GPNPort2Cnt1
classificationStatisticsPortRxCnt4 1 $::hGPNPort3Ana GPNPort3Cnt1
classificationStatisticsPortRxCnt4 1 $::hGPNPort1Ana GPNPort1Cnt1
gwd::Stop_SendFlow "$::hGPNPort4Gen"  $::hGPNPortAnaList
if {$GPNPort1Cnt1(cnt44) < $::rateL || $GPNPort1Cnt1(cnt44) > $::rateR || $GPNPort1Cnt1(cnt10) < $::rateL0 || $GPNPort1Cnt1(cnt10) > $::rateR0 || $GPNPort1Cnt1(cnt11) < $::rateL || $GPNPort1Cnt1(cnt11) > $::rateR\
 || $GPNPort2Cnt1(cnt44) < $::rateL || $GPNPort2Cnt1(cnt44) > $::rateR || $GPNPort2Cnt1(cnt10) < $::rateL0 || $GPNPort2Cnt1(cnt10) > $::rateR0 || $GPNPort2Cnt1(cnt11) < $::rateL || $GPNPort2Cnt1(cnt11) > $::rateR\
 || $GPNPort3Cnt1(cnt44) < $::rateL || $GPNPort3Cnt1(cnt44) > $::rateR || $GPNPort3Cnt1(cnt10) < $::rateL0 || $GPNPort3Cnt1(cnt10) > $::rateR0 || $GPNPort3Cnt1(cnt11) < $::rateL || $GPNPort3Cnt1(cnt11) > $::rateR} { 
if {$RunFlag==1} {
set aTempFlag 1
puts $::fileId "NE4发送未知单播、广播、组播，取消组播/广播抑制发流验证业务转发异常"
} elseif {$RunFlag==2} {
puts $::fileId "NE4发送未知单播、广播、组播，使能组播/广播抑制发流验证业务转发正常"
} elseif {$RunFlag==3} {
set aTempFlag 1
puts $::fileId "NE4发送未知单播、广播、组播，取消组播/广播抑制发流验证业务恢复异常"
} 
puts $::fileId "NE1设备收到NE4的未知单播，广播，组播分别为：$GPNPort1Cnt1(cnt44) bps $GPNPort1Cnt1(cnt10) bps $GPNPort1Cnt1(cnt11) bps"
puts $::fileId "NE2设备收到NE4的未知单播，广播，组播分别为：$GPNPort2Cnt1(cnt44) bps $GPNPort2Cnt1(cnt10) bps $GPNPort2Cnt1(cnt11) bps"
puts $::fileId "NE3设备收到NE4的未知单播，广播，组播分别为：$GPNPort3Cnt1(cnt44) bps $GPNPort3Cnt1(cnt10) bps $GPNPort3Cnt1(cnt11) bps"
 }
}
########################################################################################################
#函数功能：GPN上报文过滤测试
#输入参数: RunFlag ：测试项标志位
#输出参数：flag:数据转发结果判断标志位
#返回值： 无
#作者：吴军妮
########################################################################################################
proc PTN_EtreeMessageRestrain {RunFlag flag} {
upvar $flag aTempFlag
set aTempFlag 0
foreach i "GPNPort2Cnt1 GPNPort3Cnt1 GPNPort4Cnt1" {
  array set $i {cnt10 0 cnt11 0 cnt13 0} 
}
gwd::Start_SendFlow "$::hGPNPort1Gen"  $::hGPNPortAnaList
after $::sendTime
classificationStatisticsPortRxCnt4 1 $::hGPNPort2Ana GPNPort2Cnt1
classificationStatisticsPortRxCnt4 1 $::hGPNPort3Ana GPNPort3Cnt1
classificationStatisticsPortRxCnt4 1 $::hGPNPort4Ana GPNPort4Cnt1
gwd::Stop_SendFlow "$::hGPNPort1Gen"  $::hGPNPortAnaList
if {$RunFlag==2} {
set rateL0 70000
set rateR0 75000
} else {
set rateL0 $::rateL0
set rateR0 $::rateR0
}
if {$GPNPort4Cnt1(cnt13) < $::rateL || $GPNPort4Cnt1(cnt13) > $::rateR || $GPNPort4Cnt1(cnt10) < $rateL0 || $GPNPort4Cnt1(cnt10) > $rateR0 || $GPNPort4Cnt1(cnt11) < $::rateL || $GPNPort4Cnt1(cnt11) > $::rateR\
 || $GPNPort2Cnt1(cnt13) < $::rateL || $GPNPort2Cnt1(cnt13) > $::rateR || $GPNPort2Cnt1(cnt10) < $rateL0 || $GPNPort2Cnt1(cnt10) > $rateR0 || $GPNPort2Cnt1(cnt11) < $::rateL || $GPNPort2Cnt1(cnt11) > $::rateR\
 || $GPNPort3Cnt1(cnt13) < $::rateL || $GPNPort3Cnt1(cnt13) > $::rateR || $GPNPort3Cnt1(cnt10) < $rateL0 || $GPNPort3Cnt1(cnt10) > $rateR0 || $GPNPort3Cnt1(cnt11) < $::rateL || $GPNPort3Cnt1(cnt11) > $::rateR} {
set aTempFlag 1 
if {$RunFlag==1} {
puts $::fileId "NE1发送未知单播、广播、组播，取消组播/广播抑制发流验证业务转发异常"
} elseif {$RunFlag==2} {
puts $::fileId "NE1发送未知单播、广播、组播，使能组播/广播抑制发流验证业务转发异常"
} elseif {$RunFlag==3} {
puts $::fileId "NE1发送未知单播、广播、组播，取消组播/广播抑制发流验证业务恢复异常"
} 
puts $::fileId "抑制不生效，NE4设备收到NE1的未知单播，广播，组播分别为：$GPNPort4Cnt1(cnt13) bps $GPNPort4Cnt1(cnt10) bps $GPNPort4Cnt1(cnt11) bps"
puts $::fileId "抑制不生效，NE2设备收到NE1的未知单播，广播，组播分别为：$GPNPort2Cnt1(cnt13) bps $GPNPort2Cnt1(cnt10) bps $GPNPort2Cnt1(cnt11) bps"
puts $::fileId "抑制不生效，NE3设备收到NE1的未知单播，广播，组播分别为：$GPNPort3Cnt1(cnt13) bps $GPNPort3Cnt1(cnt10) bps $GPNPort3Cnt1(cnt11) bps"
 }
}

#########################################################################################################
#函数功能：登录设备串口
#输入参数：comPort：串口号 eg:com1-COM1
#输出参数：无
#返回值： 无
#作者：吴军妮
#########################################################################################################
proc Login_GPNCOM {comPort} {
regexp -nocase {(com[0-9]+)-(com[0-9]+)} $comPort match sun1 sun2
set comh1 [open $sun2 RDWR]
chan configure $comh1 -blocking 0 -buffering none \
	  -mode 9600,n,8,1 -translation binary -eofchar {} 
spawn -open $comh1
return $spawn_id
}
#########################################################################################################
#函数功能：清空设备配置后串口登录配置
#输入参数：case：测试脚本编号
#         Gpn_type：设备型号
#           telnet：设备telent id
#          comPort：串口号 eg:com1-COM1
#         portList：设备的用到的端口列表
#            GpnIp：设备的登录ip
#       managePort：设备的管理口
#输出参数：无
#返回值： 无
#作者：吴军妮
#########################################################################################################
proc PTN_EraseConfig {case Gpn_type matchType telnet comPort GpnIp managePort} {
global Worklevel
gwd::GPN_EraseConfigFile $case $::fileId "config-file" $Gpn_type $telnet
gwd::GPN_Reboot $case $::fileId $telnet
after $::rebootTime
set spawn_id [Login_GPNCOM $comPort]
gwd::Login_GPN $case $::fileId $comPort $spawn_id $Gpn_type
if {[string match "7600S" $Gpn_type] || [string match "7600M" $Gpn_type]} {
  gwd::GPN_CfgPortSpeedAndDup $case $::fileId $managePort "disable" "100" "full" $Gpn_type $spawn_id
  }
  if {[string match "L2" $Worklevel]} {
  gwd::GPN_CfgForwardL2 $case $::fileId $managePort "disable" "enable" $Gpn_type $spawn_id
  gwd::GPN_AddVlan $case $::fileId "4000" $spawn_id
  gwd::GPN_CfgVlanIp $case $::fileId "4000" $GpnIp "24" $spawn_id $Gpn_type
  gwd::GPN_AddPortToVlan $case $::fileId "4000" "untagged" $spawn_id $managePort
  } else {
  gwd::GPN_CfgManagePort $spawn_id $matchType $Gpn_type $::fileId $managePort $GpnIp "24"
  }
set spawn_com $spawn_id
close $spawn_com
}



########################################################################################################
#函数功能：ptn业务nni口添加vlan和ip
#输入参数:      case:测试用例编号
#       Worklevel:L2/L3层模式
#       interface:L2/L3层接口
#              ip:ip的配置
#         GPNPort:NNI接口
#       matchType:匹配命令行节点用字符串
#        Gpn_type:设备类型
#          telnet:spwan_id号
#输出参数：  无
#返回值： 无
#作者：吴军妮
########################################################################################################
proc PTN_NNI_AddInterIp {fileId Worklevel interface ip GPNPort matchType Gpn_type telnet} {
	set flagErr 0
	if {[string match "L2" $Worklevel]} {
		regexp -nocase {(\d+)} $interface match vid
		lappend flagErr [gwd::GWpublic_Addvlan $telnet $matchType $Gpn_type $fileId $vid]
		lappend flagErr [gwd::GWpublic_Addporttovlan $telnet $matchType $Gpn_type $fileId $vid "port" $GPNPort "untagged"]
		lappend flagErr [gwd::GWpublic_CfgVlanIp $telnet $matchType $Gpn_type $fileId $vid $ip 24]
	} else {
		regexp -nocase {(\d+/\d+).(\d+)} $interface match port vid
		lappend flagErr [gwd::GWL3Inter_AddL3 $telnet $matchType $Gpn_type $fileId "ethernet" $GPNPort $vid]
		lappend flagErr [gwd::GWL3port_AddIP $telnet $matchType $Gpn_type $fileId "ethernet" $GPNPort $vid $ip 24]
	}
	return [regexp {[^0\s]} $flagErr]
}
proc PTN_NNI_AddInterIp_tag {fileId Worklevel interface ip GPNPort matchType Gpn_type telnet} {
	set flagErr 0
	if {[string match "L2" $Worklevel]} {
		regexp -nocase {(\d+)} $interface match vid
		lappend flagErr [gwd::GWpublic_Addvlan $telnet $matchType $Gpn_type $fileId $vid]
		lappend flagErr [gwd::GWpublic_Addporttovlan $telnet $matchType $Gpn_type $fileId $vid "port" $GPNPort "tagged"]
		lappend flagErr [gwd::GWpublic_CfgVlanIp $telnet $matchType $Gpn_type $fileId $vid $ip 24]
	} else {
		regexp -nocase {(\d+/\d+).(\d+)} $interface match port vid
		lappend flagErr [gwd::GWL3Inter_AddL3 $telnet $matchType $Gpn_type $fileId "ethernet" $GPNPort $vid]
		lappend flagErr [gwd::GWL3port_AddIP $telnet $matchType $Gpn_type $fileId "ethernet" $GPNPort $vid $ip 24]
	}
	return [regexp {[^0\s]} $flagErr]
}
########################################################################################################
#函数功能：ptn业务uni口添加vlan
#输入参数:      case:测试用例编号
#       Worklevel:L2/L3层模式
#             vid:vlan id号
#      GPNTestEth:接入ac的端口
#       matchType:匹配命令行节点用字符串
#        Gpn_type:设备类型
#          telnet:spwan_id号
#输出参数：  无
#返回值： flagErr
#作者：吴军妮
########################################################################################################
proc PTN_UNI_AddInter {telnet matchType Gpn_type fileId Worklevel vid GPNTestEth} {
   set flagErr 0
   if {[string match "L2" $Worklevel]} {  
   lappend flagErr [gwd::GWpublic_Addvlan $telnet $matchType $Gpn_type $fileId $vid]
   lappend flagErr [gwd::GWpublic_Addporttovlan $telnet $matchType $Gpn_type $fileId $vid "port" $GPNTestEth "tagged"]
   } else {
   lappend flagErr [gwd::GWL3Inter_AddL3 $telnet $matchType $Gpn_type $fileId "ethernet" $GPNTestEth $vid]
   }
   return [regexp {[^0\s]} $flagErr]
}

########################################################################################################
#函数功能：ptn业务子接口vlan添加静态arp
#输入参数:      case:测试用例编号
#       Worklevel:L2/L3层模式
#       interface:L2/L3层接口
#              ip:arp的配置
#              ip:mac的配置
#         GPNPort:NNI接口
#       matchType:匹配命令行节点用字符串
#        Gpn_type:设备类型
#          telnet:spwan_id号
#输出参数：  无
#返回值： FlagErr
#作者：吴军妮
########################################################################################################
proc PTN_AddInterArp {fileId Worklevel interface ip mac GPNPort matchType Gpn_type telnet} {
   set FlagErr 0
   if {[string match "L2" $Worklevel]} {
   regexp -nocase {(\d+)} $interface match vid
   set FlagErr [GPN_CfgVlanArpAddr $matchType $fileId $Gpn_type $vid $ip $mac $GPNPort $telnet]
   } else {
   set FlagErr [GPN_CfgInterArpAddr $telnet $matchType $Gpn_type $fileId $interface $ip $mac]
   }
   return $FlagErr
}
########################################################################################################
#函数功能：GPN上设置某个子接口的绑定arp和mac
#输入参数:  spawn_id:TELNET进程
#       matchType:匹配命令行节点用字符串
#	  dutType:设备类型。
#	   fileId:报告输出的文件标识符
#           inter：子接口号
#             arp：绑定ARP地址
#             mac：绑定MAC地址
#输出参数：无
#返回值： flagErr  =0：添加成功       =1：添加失败            =2：ip地址添加达到最大值，无法继续添加  =3：不能绑定广播ip  =4不能绑定组播ip
########################################################################################################
proc GPN_CfgInterArpAddr {spawn_id matchType dutType fileId inter arp mac} {
  set flagErr 0
  expect {
    -i $spawn_id
    -nocase -re "$matchType\\(config\\)#" {exp_send -i $spawn_id "interface eth $inter\r"}     
    timeout {set flagErr 1;exp_send -i $spawn_id "\r"}  
  }
  expect {
     -i $spawn_id
     -re {Unknown command} {set flagErr 1;send -i $spawn_id "\r"} 
     -re ".+" {send -i $spawn_id "\r"}
     timeout {set flagErr 1}  
   }
  expect {
    -i $spawn_id
    -nocase -re "$matchType\\(config-subinterface-eth$inter\\)#" {exp_send -i $spawn_id "ip static-arp $arp $mac\r"}     
    timeout {set flagErr 1;exp_send -i $spawn_id "\r"}  
  }
  expect {
    -i $spawn_id
    -nocase -re {There are too many static ARP items} {exp_send -i $spawn_id "exit\r";set flagErr 2}
    -nocase -re {Interface need configure ip address} {exp_send -i $spawn_id "exit\r";set flagErr 2}
    -nocase -re {Can't set broadcast IP address} {exp_send -i $spawn_id "exit\r";set flagErr 3}
    -nocase -re {Can't set multicast IP address} {exp_send -i $spawn_id "exit\r";set flagErr 4}
    -nocase -re "$matchType\\(config-subinterface-eth$inter\\)#" {exp_send -i $spawn_id "exit\r"}
    timeout {set flagErr 1;exp_send -i $spawn_id "exit\r"}  
  }
  expect {
    -i $spawn_id
    -nocase -re "$matchType\\(config\\)#" {exp_send -i $spawn_id "\r"}
    timeout {set flagErr 1;exp_send -i $spawn_id "\r"}
  } 
  gwd::GWpublic_print [expr {($flagErr == 0) ? "OK" : "NOK"}] "在子接口$inter\中绑定ip:$arp\且绑定mac:$mac" $fileId
  return $flagErr  
}
proc dget {dict args} {
	if {[dict exist $dict (*)$args]} {
		set result [dict get $dict{*}$args]
	} else {
		set result null
	}
	return $result
}

proc AddportAndIptovlan {spawn_id matchType dutType fileId vid type inter mode ip mask} {
	set errorTmp 0
	send -i $spawn_id "\r"
	expect {
	    -i $spawn_id
	    -re "$matchType\\(config\\)#" {
		    send -i $spawn_id "\r"
	    }
	    -timeout 5
	    timeout {
		    gwd::GWpublic_toConfig $spawn_id $matchType
	    }
	}
	expect {
	    -i $spawn_id
	    -re "$matchType\\(config\\)#" {
		  send -i $spawn_id "vlan $vid\r"
	    }
	}
	if {$inter != ""} {
		expect {
		    -i $spawn_id
		    -re "$matchType\\(vlan.*\\)#" {
			send -i $spawn_id "add $type $inter $mode\r" 
		    }
		}
		expect {
			    -i $spawn_id
			-re {Unknown command} {
				      set errorTmp 1
				gwd::GWpublic_print NOK "$matchType\上vlan$vid中添加端口，失败。命令参数有误" $fileId
				      send -i $spawn_id "\r"
			      }
			      -re {untagged in another non-default VLAN} {
				  set errorTmp 1
				gwd::GWpublic_print NOK "$matchType\上vlan$vid中添加端口，失败。端口已untag方式加入了非default vlan" $fileId
				  send -i $spawn_id "\r"
			      }
			      -re {Layer 2 forwarding has been disabled on this port} {
				  set errorTmp 1
				gwd::GWpublic_print NOK "$matchType\上vlan$vid中添加端口，失败。端口的二层转发功能没有使能" $fileId    
			      }
			      -re "$matchType\\(vlan.*\\)#" {
				  send -i $spawn_id "\r"
				gwd::GWpublic_print OK "$matchType\上vlan$vid中添加端口，成功" $fileId    
			}
		}
		
	}
	if {$ip != ""} {
		expect {
			-i $spawn_id
			-re "$matchType\\(vlan.*\\)#" {
			    send -i  $spawn_id "ip address $ip/$mask\r" 
			}
		}
		expect {
			-i $spawn_id
			-re {Unknown command} {
			    set errorTmp 1
			    gwd::GWpublic_print NOK "$matchType\设置vlan$vid\的ip为$ip，失败。命令参数有误" $fileId
			    send -i $spawn_id "exit\r"
			}
			-re {Connot set ip address} {
			    set errorTmp 1
			    gwd::GWpublic_print NOK "$matchType\设置vlan$vid\的ip为$ip，失败。不支持ip地址配置" $fileId
			    send -i $spawn_id "exit\r"
			}
			-re "$matchType\\(vlan.*\\)#" {
			    gwd::GWpublic_print OK "$matchType\设置vlan$vid\的ip为$ip，成功" $fileId
			    send -i $spawn_id "\r" 
			}
		}
		
	}
	expect {
		-i $spawn_id
		-re "$matchType\\(vlan.*\\)#" {
			send -i $spawn_id "exit\r"
		}
	}
	return $errorTmp
}


########################################################################################################
#函数功能：查询vpls表项
#输入参数: fileId:测试报告的文件id
#         tableList:实际查询到的转发表字典 格式：mac1 "name1" mac2 "name2"
#     expectTable:期望表项列表 mac1 name1 mac2 name2 mac3 name3 mac4 name4
#     vplsname:vpls名称
#     printWord:打印报告的说明字符串
#       spawn_id:spawn id
#输出参数：无
#返回值： tableList：vpls表项列表
########################################################################################################

proc TestVplsForwardEntry {fileId printWord dTable expectTable} {
	set flag 0
	foreach {mac name} $expectTable {
		if {[dict exists $dTable $mac]} {
			if {[string match -nocase $name [dict get $dTable $mac portname]]} {
				gwd::GWpublic_print "OK" "$printWord\mac地址$mac\学习到了$name上" $fileId
			} else {
				set flag 1
				gwd::GWpublic_print "NOK" "$printWord\mac地址$mac\学习到了[dict get $dTable $mac portname]上" $fileId
			}
		} else {
			set flag 1
			gwd::GWpublic_print "NOK" "$printWord\没有mac=$mac\的转发表项" $fileId
		}
	}
	return $flag
}


########################################################################################################
#函数功能：删除meg的me  根据删除meg的部分进行修改得到
#输入参数：testCase：测试用例编号
#	    fileId：测试报告的文件id
#	      name：meg名
#            GPN_Id：spwan ID号
#          GPN_type：GPN的类型
#输出参数：无
#返回值：  无
#作者：吴军妮(唐丽春修改)
########################################################################################################
proc DelMplsMeg_Me {testCase fileId name GPN_Id GPN_type} {
	set flagErr 0
  expect {
    -i $GPN_Id
    -re {GPN.*\(config\)#} {exp_send -i $GPN_Id "mpls-tp-meg $name\r"}     
      timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}  
  } 
  expect {
    -i $GPN_Id
    -re {Name conflict with ethernet ma name} {set flagErr 1;exp_send -i $GPN_Id "\r"} 
    -re {GPN.*\(config-mpls-tp-meg\)#} {exp_send -i $GPN_Id "undo me\r";after 2000}
      timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}
  }
  expect {
    -i $GPN_Id
    -re {Command run failed} {set flagErr 1;exp_send -i $GPN_Id "\r"} 
    -re {GPN.*\(config-mpls-tp-meg\)#} {exp_send -i $GPN_Id "exit\r"} 
      timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}
  }
  gwd::GWpublic_print [expr {($flagErr == 0) ? "OK" : "NOK"}] "$GPN_type\上删除$name\的me" $fileId
  
}
########################################################################################################
#函数功能：创建过滤器(32位)
#输入参数：
#输出参数：无
#返回值：  无
#作者：唐丽春(20180807)
########################################################################################################
proc LSP_Analyzer32BitFilter {hanalyzer FilterName Offset LocationType StartOfRange EndOfRange Mask} {
	stc::create Analyzer32BitFilter -under $hanalyzer \
	-FilterName "$FilterName" \
	-Offset "$Offset" \
	-LocationType "$LocationType" \
	-StartOfRange "$StartOfRange" \
	-EndOfRange "$EndOfRange" \
	-Mask "$Mask" 
}
########################################################################################################
#函数功能：创建过滤器(16位)
#输入参数：
#输出参数：无
#返回值：  无
#作者：唐丽春(20180807)
########################################################################################################
proc LSP_Analyzer16BitFilter {hanalyzer FilterName Offset LocationType StartOfRange EndOfRange Mask} {
	stc::create Analyzer16BitFilter -under $hanalyzer \
	-FilterName "$FilterName" \
	-Offset "$Offset" \
	-LocationType "$LocationType" \
	-StartOfRange "$StartOfRange" \
	-EndOfRange "$EndOfRange" \
	-Mask "$Mask" 
}
########################################################################################################
#函数功能：创建过滤器
#输入参数：
#输出参数：无
#返回值：  无
#作者：唐丽春(20180807)
########################################################################################################
proc LSP_CaptureAnalyzerFilter {hCaptureFilter IsSelected FilterDescription  Offset Value Mask} {
	# upvar $hCaptureFilter tmpCaptureFilter
	# upvar $IsSelected tmpSelected
	# upvar $FilterDescription tmpFilterDescription
	# upvar $Offset tmpOffset
	# upvar $Value tmpValue
	stc::create CaptureAnalyzerFilter -under $hCaptureFilter \
	-IsSelected "$IsSelected" \
	-FilterDescription "$FilterDescription" \
	-Offset "$Offset" \
	-Value "$Value" \
	-Mask "$Mask" \
	-FrameConfig {<frame><config><pdus></pdus></config></frame>}
}

########################################################################################################
#函数功能：根据分析器的设置统计各条流的收发情况（对于设备发出APS报文进行统计）
#输入参数：            
#                   hAna：端口分析器handle
#               apsvalue：APS报文字段预期的信息
#返回值：无
#输出参数：
#	         aRecCnt：统计结果
#唐丽春移动PWBH的PWBH_ClassStatisticsPortRxCnt3函数
########################################################################################################
	proc LSP_ClassStatisticsPortRxCnt3 {hAna apsvalue RecCnt} {
		upvar $RecCnt TmpCnt
#		同步分析器和发生器统计延时2s  
		after 5000
		send_log "\n children:[stc::get $hAna -children-FilteredStreamResults]\n"
		set i 1
		foreach resultsObj [stc::get $hAna -children-FilteredStreamResults] {
			send_log "\n第$i次进入FOREACH：\n"
			send_log "\n result:[set d [stc::get $resultsObj]]\n"
			array set aResults $d
			if {[string match -nocase "APS (hex)" $aResults(-FilteredName_1)]\
			&& [string match -nocase  $apsvalue $aResults(-FilteredValue_1)]} {
				set TmpCnt [expr $aResults(-FrameCount)]
				break
			}
			incr i
		}
	}
########################################################################################################
#函数功能：在接收端使用抓包分析过滤抓取所收到数据包
#输入参数：       capArr:      抓包匹配参数，各个元素说明如下：
#           capMode：             抓包模式
#         capSource：             抓包源
#        captureObj：             capture对象指针
#输出参数：无
#返回值：    无
########################################################################################################
	proc GWpublic_StartCapAllData1 {capArr captureObj} {
		upvar $capArr proCapArr
		set capCount  0  
		stc::config $captureObj -mode $proCapArr(capMode) -srcMode $proCapArr(capSource)
		stc::apply
		stc::perform CaptureStart -captureProxyId $captureObj
	 }
########################################################################################################
#函数功能：停止抓包
#输入参数：captureObj：capture对象指针
#         saveFlag：是否保存抓到数据包=1：保存，  =0不保存
#         capFile： 抓到的包存放的文件名
#输出参数：无
#返回值：    capCount：抓包个数
########################################################################################################
	proc GWpublic_StopCapData {captureObj saveFlag captureFile} {
		stc::perform CaptureStop -captureProxyId $captureObj
		if {$saveFlag} {
			stc::perform CaptureDataSave -captureProxyId $captureObj -FileName $captureFile
		}
		set capCount  [stc::get $captureObj -PktCount]
		return $capCount
	}
########################################################################################################
#函数功能：对预期收到报文进行流量统计（对于APS报文）
#输入参数：            
#                 		waitetime：抓包等待时间:设备1远端BFD会话状态
#                    	caseId：端口抓包文件编号
#               		apsvalue：APS报文字段预期的信息
#						pcapNum:需要生成的pcap编号
#返回值：无
#输出参数：
#	aGPNPort1Cnt1：端口1收到APS报文统计值
#	aGPNPort2Cnt1：端口2收到APS报文统计值
#作者：唐丽春根据PWBH中的PWBH_ApsCaptureStatistics函数
########################################################################################################
	proc  LSP_ApsCaptureStatistics {waitetime caseId apsvalue1 apsvalue2 GPNPort1Cnt1 GPNPort2Cnt1} {
		upvar $GPNPort1Cnt1 tmp_GPNPort1Cnt1
		upvar $GPNPort2Cnt1 tmp_GPNPort2Cnt1
		set tmp_GPNPort1Cnt1 0 
		set tmp_GPNPort2Cnt1 0 
		stc::perform ResultsClearAll -PortList $::hport1
		stc::perform ResultsClearAll -PortList $::hport2
		if {$::cap_enable} {
			GWpublic_StartCapAllData1 ::acapture $::hcapture1 
			GWpublic_StartCapAllData1 ::acapture $::hcapture2 
		}
		after $waitetime
		if {$::cap_enable} {

			GWpublic_StopCapData $::hcapture1 1 "$caseId\_GPN_LSP_002_GPNPort1.pcap"
			GWpublic_StopCapData $::hcapture2 1 "$caseId\_GPN_LSP_002_GPNPort2.pcap"
		}
		
		after 500
		set errorCode [catch {
			LSP_ClassStatisticsPortRxCnt3 $::hanalyzer1 $apsvalue1 tmp_GPNPort1Cnt1
			LSP_ClassStatisticsPortRxCnt3 $::hanalyzer2 $apsvalue2 tmp_GPNPort2Cnt1
		} err]
		send_log "\n Info:$err\n"
	}
	proc  LSP_ApsCaptureStatistics1 {waitetime caseId apsvalue GPNPort1Cnt1} {
		upvar $GPNPort1Cnt1 tmp_GPNPort1Cnt1
		stc::perform ResultsClearAll -PortList $::hport1
		set tmp_GPNPort1Cnt1 0 
		if {$::cap_enable} {
			GWpublic_StartCapAllData1 ::acapture $::hcapture1 
		}
		after $waitetime
		if {$::cap_enable} {

			GWpublic_StopCapData $::hcapture1 1 "$caseId\_GPN_LSP_002_GPNPort1_.pcap"
		}
		after 500
		set errorCode [catch {
			LSP_ClassStatisticsPortRxCnt3 $::hanalyzer1 $apsvalue tmp_GPNPort1Cnt1
		} err]
		send_log "\n Info:$err\n"
	}
	proc  LSP_ApsCaptureStatistics2 {waitetime caseId apsvalue GPNPort2Cnt1} {
		upvar $GPNPort2Cnt1 tmp_GPNPort2Cnt1
		set tmp_GPNPort2Cnt1 0 
		stc::perform ResultsClearAll -PortList $::hport2
		if {$::cap_enable} {
			GWpublic_StartCapAllData1 ::acapture $::hcapture2 
		}
		after $waitetime
		after 500
		set errorCode [catch {
			LSP_ClassStatisticsPortRxCnt3 $::hanalyzer2 $apsvalue tmp_GPNPort2Cnt1
		} err]
		if {$::cap_enable} {
			GWpublic_StopCapData $::hcapture2 1 "$caseId\_GPN_LSP_002_GPNPort2.pcap"
		}
		
		
		send_log "\n Info:$err\n"
	}

########################################################################################################
#函数功能：对预期收到报文进行确认（APS报文）
#输入参数：            
#                 waitetime：抓包等待时间:设备1远端BFD会话状态
#                    caseId：端口抓包文件编号
#             a16BitFilCfg0：配置自定义16位过滤器各参数（EndOfRange、FilterName等信息）
#                    Value1：预期收到APS报文的最小FrameRate
#                  apsvalue：APS报文字段预期的信息
#					pcapNum: pcap的编号值
#				 GPNPortNum: 设备编号
#返回值：0：代表收到BFD报文符合预期要求；1：代表收到BFD报文不符合预期要求
#输出参数：无
#唐丽春根据PWBH中的PWBH_ApsMessageConfirm
########################################################################################################
	proc LSP_ApsMessageConfirm {waitetime caseId Value1 apsvalue1 apsvalue2} {
		set errorTmp 0
		LSP_ApsCaptureStatistics $waitetime $caseId $apsvalue1 $apsvalue2 ApsCnt1 ApsCnt2
		send_log "\Port1APSResult:$ApsCnt1\n"
		send_log "\Port2APSResult:$ApsCnt2\n"
		if {$ApsCnt1 > $Value1} {
			gwd::GWpublic_print OK "设备$::matchType1\发出APS报文且报文信息为$apsvalue1\，正确。" $::fileId
		} else {
			set errorTmp 1
			gwd::GWpublic_print NOK "设备$::matchType1\发出APS报文，报文信息不为$apsvalue1\，存在异常，请查看报文$caseId\_GPN_LSP_002_GPNPort1.pcap" $::fileId
		}
		if {$ApsCnt2 > $Value1} {
			gwd::GWpublic_print OK "设备$::matchType1\发出APS报文且报文信息为$apsvalue2\，正确。" $::fileId
		} else {
			set errorTmp 1
			gwd::GWpublic_print NOK "设备$::matchType1\发出APS报文，报文信息不为$apsvalue2\，存在异常，请查看报文$caseId\_GPN_LSP_002_GPNPort2.pcap。" $::fileId
		}
		 return $errorTmp
	} 
########################################################################################################
#函数功能：对预期收到报文进行确认（APS报文）
#输入参数：            
#                 waitetime：抓包等待时间:设备1远端BFD会话状态
#                    caseId：端口抓包文件编号
#             a16BitFilCfg0：配置自定义16位过滤器各参数（EndOfRange、FilterName等信息）
#                    Value1：预期收到APS报文的最小FrameRate
#                  apsvalue：APS报文字段预期的信息
#					pcapNum: pcap的编号值
#				 GPNPortNum: 设备编号
#返回值：0：代表收到BFD报文符合预期要求；1：代表收到BFD报文不符合预期要求
#输出参数：无
#唐丽春根据PWBH中的PWBH_ApsMessageConfirm
########################################################################################################
	proc LSP_ApsMessageConfirm1 {waitetime caseId Value1 apsvalue} {
		set errorTmp 0
		LSP_ApsCaptureStatistics1 $waitetime $caseId $apsvalue ApsCnt1
		send_log "\Port1APSResult:$ApsCnt1\n"

		# send_log "\Port2APSResult:$ApsCnt2\n"
		if {$ApsCnt1 > $Value1} {
			gwd::GWpublic_print OK "设备$::matchType1\发出APS报文且报文信息为$apsvlaue\，正确。" $::fileId
		} else {
			set errorTmp 1
			gwd::GWpublic_print NOK "设备$::matchType1\发出APS报文，报文信息不为$apsvlaue\，存在异常，请查看报文$caseId\_GPN_LSP_002_GPNPort1.pcap" $::fileId
		}
		 return $errorTmp
	} 

########################################################################################################
#函数功能：统计业务流的丢包情况
#输入参数：            
#                   hAna：端口分析器handle
#					vid：vlan的id
#					smac：源mac地址
#					DropCnt：统计结果
#返回值：无
#输出参数：
#唐丽春移动PWBH的PWBH_ClassStatisticsPortDrop函数
########################################################################################################
proc LSP_ClassStatisticsPortDrop {infoObj vidmin vidmax DropCntmin DropCntmax} {
		upvar $DropCntmin tmp_DropCntmin
		upvar $DropCntmax tmp_DropCntmax
		set tmp_DropCntmin -1
		set tmp_DropCntmax -1
#		同步分析器和发生器统计延时2s  
		after 2000
		set i 1
		set totalPage [stc::get $infoObj -TotalPageCount]
		for {set pageNum 1} {$pageNum <= $totalPage} {incr pageNum} {
			stc::config $infoObj -PageNumber $pageNum
			stc::apply
			after 4000
			set lstRxResults [stc::get $infoObj -ResultHandleList]
		# send_log "\n children:[stc::get $hAna -children-FilteredStreamResults]\n"
		foreach resultsObj $lstRxResults {
			set d [stc::get $resultsObj]]
			array set aResults $d
			#after 3000
			gwd::Clear_ResultViewStat $resultsObj
			if {[string match -nocase $vidmin $aResults(-FilteredValue_1)]} {
				set tmp_DropCntmin [expr $aResults(-DroppedFrameCount)]
			} elseif {[string match -nocase $vidmax $aResults(-FilteredValue_1)]} {
				set tmp_DropCntmax [expr $aResults(-DroppedFrameCount)]
				send_log "这个结果是对的吗$d"
				break
			}
			incr i
			stc::perform ResultsClearView -ResultList $resultsObj
		}
	}
		send_log "DroppedFrameCount:$tmp_DropCntmin,$tmp_DropCntmax"	
	}
########################################################################################################
#函数功能：GPN上设置某个vlan的绑定arp和mac
#输入参数: GPNType：GPN的类型
#         vid：vlan id号
#         arp：绑定ARP地址
#         mac：绑定MAC地址
#        port：绑定端口
#输出参数：无
#返回值： flagErr  =0：添加成功       =1：添加失败            =2：ip地址添加达到最大值，无法继续添加  =3：不能绑定广播ip  =4不能绑定组播ip
########################################################################################################
proc GPN_CfgVlanArpAddr {matchType fileId GPNType vid arp mac port GPN_Id} {
  set flagErr 0
  expect {
    -i $GPN_Id
    -nocase -re "$matchType\\(config\\)#" {exp_send -i $GPN_Id "vlan $vid\r"}     
    timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}  
  }
  expect {
    -i $GPN_Id
    -nocase -re "$matchType\\(vlan-v$vid\\)#" {exp_send -i $GPN_Id "ip static-arp $arp $mac $port\r"}  
    -timeout 20
    timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}  
  }
  expect {
    -i $GPN_Id 
    -nocase -re {There are too many static ARP items} {exp_send -i $GPN_Id "exit\r";set flagErr 2}
    -nocase -re {Vlan need configure ip address} {exp_send -i $GPN_Id "exit\r";set flagErr 2}
    -nocase -re {Can't set broadcast IP address} {exp_send -i $GPN_Id "exit\r";set flagErr 3}
    -nocase -re {Can't set multicast IP address} {exp_send -i $GPN_Id "exit\r";set flagErr 4}
    -nocase -re "$matchType\\(vlan-v$vid\\)#" {exp_send -i $GPN_Id "exit\r"}
    -timeout 20
    timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}  
  }
  expect {
    -i $GPN_Id
    -nocase -re "$matchType\\(config\\)#" {exp_send -i $GPN_Id "\r"}
    -timeout 20
    timeout {set flagErr 1;exp_send -i $GPN_Id "\r"}
  }  
  
  gwd::GWpublic_print [expr {($flagErr == 0) ? "OK" : "NOK"}] "在vlan$vid\中绑定ip:$arp\且绑定mac:$mac" $fileId
  return $flagErr  
}

########################################################################################################
#函数功能：业务在无故障和故障时的丢包情况分析
#输入参数：            
#                   flag：=1 主备链路正常情况下；=2 主备链路有异常情况，有倒换事件发生
#                   time：有倒换事件发生情况下，业务倒换可接受时间（单位为：ms）
#                  hAna1：本端端口分析器handle
#                  hAna2：对端端口分析器handle
#返回值：无
#输出参数：                     value1: flag=1时 ，该值代表业务丢包情况；flag=2时 ，该值代表业务倒换时间（单位为：ms）
#唐丽春移动PWBH的PWBH_ClassDropStatisticsAna函数
#########################################################################################################
proc LSP_ClassDropStatisticsAna {flag infoObj1 infoObj2 vidmin vidmax time valuemin valuemax} {
		upvar $valuemin value1
		upvar $valuemax value2
		set value1 0
		set vlaue2 0
		set errorTmp 0
		LSP_ClassStatisticsPortDrop $infoObj1 $vidmin $vidmax DropCntmin1 DropCntmax1
		LSP_ClassStatisticsPortDrop $infoObj2 $vidmin $vidmax DropCntmin2 DropCntmax2
		if ([string equal -nocase "1" $flag]) {
			if {$DropCntmin1 > 0 || $DropCntmin2 > 0 || $DropCntmax1 > 0 || $DropCntmax2 > 0} {
				if {$DropCntmin1 >= $DropCntmin2} {
					set value1 $DropCntmin2
				} else {
					set value1 $DropCntmin1
				}
				if {$DropCntmax1 >= $DropCntmax2} {
					set value2 $DropCntmax1
				} else {
					set value2 $DropCntmax2
				}
				set errorTmp 1
				gwd::GWpublic_print NOK "在主备链路正常且无倒换事件发生情况下对发流量发包速率为10000fps，业务存在丢包现象，最小丢包数为$valuemin，最大丢包数为$valuemax" $::fileId
			} else {
				gwd::GWpublic_print OK "在主备链路正常且无倒换事件发生情况下对发流量发包速率为10000fps，业务正常无丢包现象。" $::fileId
			}
		} elseif {[string equal -nocase "2" $flag]} {
			if {$DropCntmin1 > 0 || $DropCntmin2 > 0 || $DropCntmax1 > 0 || $DropCntmax2 > 0} {
				if {$DropCntmin1 >= $DropCntmin2} {
					set value1 $DropCntmin2
				} else {
					set value1 $DropCntmin1
				}
				if {$DropCntmax1 >= $DropCntmax2} {
					set value2 $DropCntmax1
				} else {
					set value2 $DropCntmax2
				}
			}
			if {$time == ""} {
				set time 0
				if {$value1 > 0 || $vlaue2 > 0} {
					set errorTmp 1
					gwd::GWpublic_print NOK "在有倒换事件发生情况下预期业务不丢包，业务存在丢包，最小丢包数为$valuemin，最大丢包数为$valuemax。" $::fileId
				} else {
					gwd::GWpublic_print OK "在有倒换事件发生情况下预期业务不丢包，满足要求业务无丢包。" $::fileId
				}
			} else {
				set value1 [expr $value1/10]
				set value2 [expr $value2/10]
				if {$value1 > $time || $value2 > $time} {
					set errorTmp 1
					gwd::GWpublic_print NOK "在有倒换事件发生情况下可接受时间为$time ms，业务倒换时间最少约为$valuemin ms\,最大约为$vlauemax ms。" $::fileId
				} else {
					gwd::GWpublic_print OK "在有倒换事件发生情况下可接受时间为$time ms，业务倒换时间最少约为$valuemin ms\,最大约为$vlauemax ms。" $::fileId
				}
			}
		}
		return $errorTmp 
	}

	proc LSP_ClassDropStatisticsAna1 {flag infoObj1 vidmin vidmax valuemin valuemax} {
		upvar $valuemin valuemin
		set valuemin 0
		set errorTmp 0
		LSP_ClassStatisticsPortDrop $infoObj1 $vidmin vidmax DropCntmin DropCntmax
		
			set valuemin $DropCntmin
			set valuemax $DropCntmax
			if {$time == ""} {
				set time 0
				if {$valuemin > 0 || $valuemax >0} {
					set errorTmp 1
					gwd::GWpublic_print NOK "在有倒换事件发生情况下预期业务不丢包，业务存在丢包，最小丢包数为$valuemin，最大丢包数为$valuemax。" $::fileId
				} else {
					gwd::GWpublic_print OK "在有倒换事件发生情况下预期业务不丢包，满足要求业务无丢包。" $::fileId
				}
			} else {
				set valuemin [expr $valuemin/10]
				set valuemax [expr $valuemax/10]
				if {$valuemin > $time || $valuemax > $time} {
					set errorTmp 1
					gwd::GWpublic_print NOK "在有倒换事件发生情况下可接受时间为$time ms，业务倒换时间最少约为$valuemin ms\,最大约为$vlauemax ms。" $::fileId
				} else {
					gwd::GWpublic_print OK "在有倒换事件发生情况下可接受时间为$time ms，业务倒换时间最少约为$valuemin ms\,最大约为$vlauemax ms。" $::fileId
				}
		}
		return $errorTmp 
	}
  ########################################################################################################
  #函数功能：定制发送和接收信息
  #输入参数：projectObj：信息定制的 父指针
  #          resultParentObj： 信息定制的 结果父指针
  #          paraArr：定制信息的属性参数
  #输出参数： infoObj：       信息对象指针
  ########################################################################################################
  proc TxAndRx_Info {hproject hport infoObj} {
  	upvar $infoObj proInfo
  	set proInfo [stc::subscribe -parent $hproject \
		-resultParent $hport \
		-configType Analyzer \
		-resultType FilteredStreamResults]
  	stc::apply
  }
  proc Create_Analyzer16Bit {AnalyzerFrameConfigFilter startRange endRange} {
  	set Analyzer16BitFilter1 [stc::create "Analyzer16BitFilter" \
        -under $AnalyzerFrameConfigFilter \
        -Mask "4095" \
        -StartOfRange "$startRange" \
        -EndOfRange "$endRange" \
        -LocationType "VLAN_TAG" \
        -Offset "2" \
        -FilterName {Vlan 0 - ID^Vlan 0 - ID} ]
    }