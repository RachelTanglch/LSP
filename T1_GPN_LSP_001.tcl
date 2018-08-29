#!/bin/sh
# T1_GPN_PTN_LSP_001.tcl \
exec tclsh "$0" ${1+"$@"}
#测试名称：ptn_lsp_001
#-----------------------------------------------------------------------------------------------------------------------------------
#测试目的：MPLS配置
#1-LSP业务创建；
#2-LSP OAM创建；
#3-线性保护组创建；
#4-线性保护组协议使能配置；
#5-线性保护组使能条件
#6-删除配置
#-----------------------------------------------------------------------------------------------------------------------------------
#测试拓扑类型二：（仅以7600/S为例）                                                                                                                             
#                                                                              
#                                    ___________                               
#                                   |   4GE/ge  |
#  _______                          |   8fx     |    
# |       |                         |           |
# |  PC   |_______Internet连接 _____|           |
# |_______|                         |           |       
#    /__\                           |GPN(7600/S)|                  
#                                   |           |            
#                                   |___________|           
#                                          
#                                                                         
#                                                                                                                  
#---------------------------------------------------------------------------------------------------------------------------------
#脚本运行条件：
#1、按照测试拓扑搭建测试环境:将GPN的管理端口（U/D）和PC的网口与Internet相连，GPN的2个上联口
#   与STC端口（ 9/9）（9/10）
#2、在GPN上清空所有 配置，建立管理vlan vid=4000，在该vlan上设置管理IP，并untagged方式添加管理端口（U/D）
#-----------------------------------------------------------------------------------------------------------------------------------
#测试过程：
#1、搭建Test Case 1测试环境
#   <1>配置PW所在的端口为NNI口
#   <2>配置vlan，加入端口和Ip，创建不同的VLANIF接口
#   <3>创建工作LSP，配置目的地址
#   <4>创建保护LSP，目的地址和工作LSP的地址一致，确认配置成功。
#   <5>配置工作LSP和保护LSP的性能统计使能，配置PW性能统计使能，配置以太网接入端口性能统计使能，确认配置成功
#   <6>undo shutdown
#2、搭建Test Case 2测试环境
#   <1>删除线性保护组
#   <2>删除工作LSP的MEP配置
#   <3>删除保护LSP的MEP配置
#3、搭建Test Case 3测试环境
#   <1>无MEP的情况下线性保护使能失败
#   <2>有MEP的情况下线性保护使能成功
#4、搭建Test Case 4测试环境
#   <1>删除线性保护组、OAM，重新配置保护LSP，目的地址和工作LSP不同
#   <2>重新配置线性保护组、OAM
#   <3>线性保护组使能不成功
#2、搭建Test Case 5测试环境   
#   <1>删除线性保护组
#   <2>删除保护LSP
#   <3>删除工作LSP
#   <4>恢复初始化配置
#-----------------------------------------------------------------------------------------------------------------------------------
#use Encode qw/encode decode/;

set startSeconds [clock seconds]
package require gwd 2.0
package require stcPack

if {[catch {
    #close stdout
    file mkdir "log"
    set fd_log [open "log\\GPN_PTN_001_LOG.txt" a]
    set stdout $fd_log
    chan configure $fd_log -blocking 0 -buffering none;#非阻塞模式 按行flush
    log_file log\\GPN_PTN_001_LOG.txt
    
    file mkdir "report"
    set fileId [open "report\\GPN_PTN_001_REPORT.txt" a+]
    chan configure $fileId -blocking 0 -buffering none;#非阻塞模式 按行flush
    
    file mkdir "debug"
    set fd_debug [open debug\\GPN_PTN_001_DEBUG.txt a]
    exp_internal -f debug\\GPN_PTN_001_DEBUG.txt 0
    chan configure $fd_debug -blocking 0 -buffering none;#非阻塞模式 按行flush

    source test\\LSP_VarSet.tcl
    source test\\LSP_Mode_Function.tcl

    set flagResult 0
    set flagCase1 0   ;#Test case 1标志位 
    set flagCase2 0   ;#Test case 2标志位
    set flagCase3 0   ;#Test case 3标志位
    set flagCase4 0   ;#Test case 4标志位
    set flagCase5 0   ;#Test case 5标志位
    set cfgId 0
    set lFailFile ""
    set FLAGF 0
    #为测试结论预留空行
    for {set i 0} {$i < 80} {incr i} {
	puts $fileId "                                                                                                                                                                                                                "     
    }

    puts $fileId "Log in to the device under test...\n"
    puts $fileId "\n=====登录被测设备1====\n"
    set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "===MLPS配置开始...\n"
    set cfgFlag 0
    lassign $lDev1TestPort testPort1 testPort2 testPort3 testPort4 testPort5 testPort6
    foreach port $lDev1TestPort {
	if {[string match -nocase "L3" $Worklevel] && [string match -nocase "PTN" $SoftVer]} {
	lappend cfgFlag [gwd::GWL2_AddPort $telnet1 $matchType1 $Gpn_type1 $fileId $port "disable" "enable"]
	    }
	}
	###端口为二三层接口设置参数
	if {[string match "L2" $Worklevel]} {
	    set interface1 v10
	    set interface2 v20
	    set interface3 v101
	    set interface4 v110
	    set interface5 v310
	    set interface6 v200
	    set interface7 v400
	    set interface8 v11
	    set interface9 v12
	    } 
    #    else {
	#    set interface1 $testPort1.100
	#    set interface2 $testPort1.500
	#    set interface3 $testPort3.300
	#    set interface4 $testPort2.110
	#    set interface5 $testPort4.310
	#    set interface6 $testPort6.200
	#    set interface7 $testPort5.400
	#    set interface8 $testPort5.11
	#    set interface9 $testPort5.12
	#}
    #用于导出被测设备用到的变量------
    set lSpawn_id "$telnet1"
    set lMatchType "$matchType1"
    set lDutType "$Gpn_type1"
    set lIp "$gpnIp1"
    regexp -nocase {(\d+)} $interface1 match vid1
    regexp -nocase {(\d+)} $interface2 match vid2
    regexp -nocase {(\d+)} $interface3 match vid3
    #------用于导出被测设备用到的变量
    gwd::GWpublic_printAbnormal $fileId $fd_log $cfgFlag "FLAGA" $startSeconds "MLPS配置失败，测试结束" \
    "MLPS配置成功，继续后面的测试" "GPN_PTN_LSP_001"
    puts $fileId ""
    puts $fileId "===MLPS配置结束..."
    incr cfgId
    ##  上传文件配置
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
    set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    puts $fileId ""
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles  "$fd_debug $fd_log $fileId" "Test Case 1 OAM创建、LSP线性保护组创建，Eline业务创建 测试开始\n"
    #   <1>配置PW所在的端口为NNI口
    #   <2>配置vlan，加入端口和Ip，创建不同的VLANIF接口
    #   <3>创建工作LSP，配置目的地址
    #   <4>创建保护LSP，目的地址和工作LSP的地址一致，确认配置成功。
    #   <5>配置工作LSP和保护LSP的性能统计使能，配置PW性能统计使能，配置以太网接入端口性能统计使能，确认配置成功
    #   <6>创建LSP层OAM，工作和保护LSP各自配置独立的MEP，MEP及RMEPID相互独立，周期3.3ms，确认配置成功
    #   <7>创建线性保护组，等待时间为1，配置工作路径和保护路径，确认配置成功
    
    set flag1_case1 0
    set flag2_case1 0
    set ip1 1.0.0.1 ;#vlanif10 ip
    set ip2 2.0.0.1;#vlanif20 ip

    set address 4.4.4.4 ; #目的网元地址
    set address2 5.5.5.5; #不同的目的网元地址
    ###  配置pw所在的端口为nni口
    if {[string match "L2" $Worklevel]} {
	gwd::GWpublic_CfgVlanStack $telnet1 $matchType1 $Gpn_type1 $fileId $testPort1 "enable"  
	gwd::GWpublic_CfgVlanStack $telnet1 $matchType1 $Gpn_type1 $fileId $testPort2 "enable"  

    }
    ###  为NNI端口配置不同的VLANIF接口-----
    PTN_NNI_AddInterIp $fileId $Worklevel $interface1 $ip1 $testPort1 $matchType1 $Gpn_type1 $telnet1
    puts $fileId "======================================================================================\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====创建工作LSP和保护LSP，目的地址相同，性能统计使能，配置开始=====\n"
    ###  创建工作LSP
    if {[gwd::GWStaLsp_AddLspName $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_101 1"] == 1} {
	gwd::GWpublic_print "OK" "创建工作LSP名字Tunnel_101，序号为1，创建成功" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "创建工作lsp时输入lsp名字Tunnel_101，序号为1，创建失败" $fileId
    }
    ###  工作LSP的目的地址
    gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_101" $address
    ###  配置正确的接口Vlan，下一跳ip，入标签，出标签，lspid能否成功配置lsp
    if {[gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_101" $interface1 $ip2 "101" "401" "normal" 101] == 0} {
	gwd::GWpublic_print "OK" "配置工作lsp的vlanif接口，配置成功" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "配置工作lsp的vlanif接口，配置失败" $fileId
    }
    ###  创建不同的vlanif接口
    PTN_NNI_AddInterIp $fileId $Worklevel $interface2 $ip2 $testPort2 $matchType1 $Gpn_type1 $telnet1
    ###  创建保护LSP
    if {[gwd::GWStaLsp_AddLspName $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_2101 2"] == 1} {
	gwd::GWpublic_print "OK" "创建保护LSP名字Tunnel_2101，序号为2，创建成功" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "创建保护LSP名字Tunnel_2101，序号为2，创建失败" $fileId
    }

    ###  配置和工作LSP一样的目的地址
    gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" $address
    ###  配置正确的接口Vlan，下一跳ip，入标签，出标签，lspid能否成功配置lsp
    if {[gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_2101" $interface2 $ip1 "2101" "2401" "normal" 2101] == 0} {
	gwd::GWpublic_print "OK" "配置保护lsp的vlanif接口，配置成功" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "配置保护lsp的vlanif接口，配置失败" $fileId
    }
    gwd::GWpublic_addLspStat $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_101" "enable"
    if {[gwd::GWStaLsp_AddLspEn $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_101" "undo shutdown"] == 0} {
	gwd::GWpublic_print "OK" "工作LSP使能性能统计后激活LSP，配置成功" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "工作LSP使能性能统计后激活LSP，配置失败" $fileId
	
    }
    gwd::GWpublic_addLspStat $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" "enable"
    if {[gwd::GWStaLsp_AddLspEn $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" "undo shutdown"] == 0} {
	gwd::GWpublic_print "OK" "保护LSP使能性能统计后激活LSP，配置成功" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "保护LSP使能性能统计后激活LSP，配置失败" $fileId
    }
    puts $fileId ""
    if {$flag1_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA1（结论）创建工作LSP和保护LSP，目的地址相同，性能统计使能，创建失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA1（结论）创建工作LSP和保护LSP，目的地址相同，性能统计使能，创建成功" $fileId
    }
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====创建工作LSP和保护LSP，目的地址相同，性能统计使能，配置结束=====\n"
    
    puts $fileId "======================================================================================\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====配置PW性能统计使能，配置以太网接入端口性能统计使能，确认配置成功  测试开始=====\n"
    
    ###  PTN业务UNI口添加vlan
    PTN_UNI_AddInter $telnet1 $matchType1 $Gpn_type1 $fileId $Worklevel $vid3 $testPort2
    gwd::GWStaPw_AddPwName $telnet1 $matchType1 $Gpn_type1 $fd_log "pw101"
    if {[gwd::GWpublic_CfgPw $telnet1 $matchType1 $Gpn_type1 $fileId "pw101" "l2transport" "1" "" $address "1401" "1101" "101" "nochange" "" "1" "0" "0x8100" "0x8100" ""]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "设置正确的静态区间后再配置pw，配置失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "设置正确的静态区间后再配置pw，配置成功" $fileId
    }
    if {[gwd::GWpublic_addPwStatEn $telnet1 $matchType1 $Gpn_type1 $fileId "pw101" "enable"]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "使能PW性能统计，配置失败" $fileId   
    } else {
	gwd::GWpublic_print "OK" "使能PW性能统计，配置成功" $fileId    
    }
    gwd::GWAc_AddName $telnet1 $matchType1 $Gpn_type1 $fd_log "ac101 1"
    if {[gwd::GWAc_AddInfo $telnet1 $matchType1 $Gpn_type1 $fd_log "ac101" "" $testPort2  101 0 "nochange" 101 0 0 "0x8100"] == 0} {
	gwd::GWpublic_print "OK" "配置ac绑定端口，配置成功" $fileId  
    } else {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "配置ac绑定端口，配置失败" $fileId
    }
    if {[gwd::GWpublic_CfgAcBind $telnet1 $matchType1 $Gpn_type1 $fileId "ac101" "pw101" "eline"]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "ac绑定pw的参数都正确，绑定失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "ac绑定pw的参数都正确，绑定成功" $fileId    
    }
    if {[gwd::GWpublic_addAcStatEn $telnet1 $matchType1 $Gpn_type1 $fileId "ac101" "enable"]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "使能ac性能统计，配置失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "使能ac性能统计，配置成功" $fileId    
    }
    puts $fileId ""
    if {$flag2_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA2（结论）配置PW性能统计使能，配置以太网接入端口性能统计使能，确认配置失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA2（结论）配置PW性能统计使能，配置以太网接入端口性能统计使能，确认配置成功" $fileId
    }
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====配置PW性能统计使能，配置以太网接入端口性能统计使能，确认配置成功  测试结束=====\n"
    
    set flag3_case1 0 ;
    puts $fileId "======================================================================================\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====创建LSP层OAM，配置开始=====\n"
    gwd::GWpublic_createMplsMeg $telnet1 $matchType1 $Gpn_type1 $fileId "meg101"
	if {[gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "lsp" "Tunnel_2101" "401" "101"] == 0} {
	    gwd::GWpublic_print "OK" "保护LSP配置独立的MEP，MEP及LMEPID相互独立，配置成功" $fileId
	} else {
	    set flag3_case1 1
	    gwd::GWpublic_print "NOK" "保护LSP配置独立的MEP，MEP及LMEPID相互独立，配置失败" $fileId
	}
    gwd::GWpublic_createMplsMeg $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101"
    if {[gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "lsp" "Tunnel_101" "2401" "2101"] == 0} {
	gwd::GWpublic_print "OK" "工作LSP配置独立的MEP，MEP及LMEPID相互独立，配置成功" $fileId
    } else {
	set flag3_case1 1
	gwd::GWpublic_print "NOK" "工作LSP配置独立的MEP，MEP及LMEPID相互独立，配置失败" $fileId
    }
    if {[gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "3ms"]} {
	set flag3_case1 1
	gwd::GWpublic_print "NOK" "配置保护LSP，CC间隔3ms，配置失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "配置保护LSP，CC间隔3ms，配置成功" $fileId    
    }
    if {[gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "3ms"]} {
	set flag3_case1 1
	gwd::GWpublic_print "NOK" "配置工作LSP，CC间隔3ms，配置失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "配置工作LSP，CC间隔3ms，配置成功" $fileId    
    }
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "enable"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "enable"
    puts $fileId ""
    if {$flag3_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA3（结论）创建LSP层OAM，确认配置失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA3（结论）配置LSP层OAM，确认配置成功" $fileId
    }
    puts $fileId ""
    set flag4_case1 0
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====创建LSP层OAM，测试结束=====\n"
 
    puts $fileId "======================================================================================\n"

    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====创建LSP线性保护组，配置开始=====\n"
    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 1} {
	set flag4_case1 1
    }
    puts $fileId ""
    if {$flag4_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA4（结论）创建LSP线性保护组，确认配置失败" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA4（结论）配置LSP线性保护组，确认配置成功" $fileId
    }
    puts $fileId ""
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
	set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====创建LSP线性保护组，测试结束=====\n"
    if {$flagCase1 == 1} {
	gwd::GWpublic_print "NOK" "Test Case 1测试结论" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 1测试结论" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 1 OAM创建、LSP线性保护组创建，Eline业务创建 测试结束\n"
    puts $fileId ""
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 2 删除线性保护组、删除工作和保护LSP的MEP配置 测试开始\n"
    if {[gwd::GWpublic_DelMlpsPro  $fileId $Gpn_type1 $telnet1 "ac101" "disable"] == 1} {
	    set flagCase2 1
	}
     DelMplsMeg_Me "GPN_PTN_LSP_001" $fileId "meg101" $telnet1 $Gpn_type1
     DelMplsMeg_Me "GPN_PTN_LSP_001" $fileId "meg2101" $telnet1 $Gpn_type1
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
	set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    puts $fileId "======================================================================================\n"
    if {$flagCase2 == 1} {
	gwd::GWpublic_print "NOK" "TestCase 2测试结论" $fileId
	} else {
	gwd::GWpublic_print "OK" "TestCase 2测试结论" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 2 删除线性保护组、删除工作和保护LSP的MEP配置 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 3 有无MEP，线性保护组使能 测试开始\n"
    set flag1_case3 0 ;#Test Case 3 标志位
    set flag2_case3 0 ;
    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 0} {
	set flag1_case3 1
	gwd::GWpublic_print "NOK" "工作和保护LSP无MEP，线性保护组使能配置成功" $fileId
    } else {
	
	gwd::GWpublic_print "OK" "工作和保护LSP无MEP，线性保护组使能配置失败" $fileId
    }
    ### 重新配置工作和保护LSP的MEP
    gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "lsp" "Tunnel_2101" "401" "101"
    gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "lsp" "Tunnel_101" "2401" "2101"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "enable"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "enable"
    gwd::GWpublic_DelMlpsPro $fileId $Gpn_type1 $telnet1 "ac101" "disable"
    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 1} {
	set flag2_case3 1
	gwd::GWpublic_print "NOK" "工作和保护LSP有MEP，线性保护组使能配置失败" $fileId

    } else {
	gwd::GWpublic_print "OK" "工作和保护LSP有MEP，线性保护组使能配置成功" $fileId
    }
    if {$flag1_case3 == 1 || $flag2_case3 == 1} {
	set flagCase3 1
    }
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
	set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    puts $fileId "======================================================================================\n"
    if {$flagCase3 == 1} {
	gwd::GWpublic_print "NOK" "Test Case 3测试结论" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 3测试结论" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 3 有无MEP，线性保护组使能  测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 4 保护LSP和工作LSP目的地址不同，线性保护组使能 测试开始\n"
    set flag1_case4 0 ;#Test Case 4 标志位
    ### 删除并重新配置保护LSP的MEP，保护LSP的目的地址和工作LSP的不同
    gwd::GWpublic_DelMlpsPro $fileId $Gpn_type1 $telnet1 "ac101" "disable" 
    gwd::GPN_DelMplsMeg "GPN_PTN_LSP_001" $fileId "meg101" $telnet1 $Gpn_type1
    gwd::GWStaLsp_DelLspName $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101"
    gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" $address2
    gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_2101" $interface2 $ip1 "2101" "2401" "normal" 2101
    gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "lsp" "Tunnel_2101" "401" "101"

    gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "3ms"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "enable"

    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 1} {
	gwd::GWpublic_print "OK" "工作和保护LSP目的地址不同，线性保护组使能配置失败" $fileId
    } else {
	set flag1_case4 1
	gwd::GWpublic_print "NOK" "工作和保护LSP目的地址不同，线性保护组使能配置成功" $fileId
    }
    if {$flag1_case4 == 1} {
	set flagCase4 1
    }
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
	set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    puts $fileId "======================================================================================\n"
    if {$flagCase4 == 1} {
	gwd::GWpublic_print "NOK" "Test Case 4测试结论" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 4测试结论" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 4 保护LSP和工作LSP目的地址不同，线性保护组使能  测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 5 删除线性保护组后，删除工作LSP、保护LSP工作成功 测试开始\n"
    set flag1_case5 0
    set flag2_case5 0
    ### 删除eline业务
    lappend flagDel [gwd::GWAc_DelActPw $telnet1 $matchType1 $Gpn_type1 $fileId "ac101"]
    lappend flagDel [gwd::GWAc_DelName $telnet1 $matchType1 $Gpn_type1 $fileId "ac101"]
    #lappend flagDel [gwd::GWpublic_delPwStaticPara $telnet1 $matchType1 $Gpn_type1 $fileId "pw101"]
    lappend flagDel [gwd::GWpublic_delPw "GPN_PTN_LSP_001" $fileId "pw101" $telnet1 $matchType1]
    ### 将保护LSP目的地址改为和工作LSP目的地址相同
    lappend flagDel [gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" $address]
    lappend flagDel [gwd::GWpublic_CfgUndoShutLsp $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101"]
    if {[gwd::GWpublic_DelMlpsPro $fileId $Gpn_type1 $telnet1 "ac101" "disable"] == 1} {
	    set flag1_case5 1
	    gwd::GWpublic_print "NOK" "删除线性保护组失败" $fileId
	} else {
	    gwd::GWpublic_print "OK" "删除线性保护组成功" $fileId
	}
    if {[gwd::GPN_DelLsp "GPN_PTN_LSP_001" $fileId "Tunnel_2101" $telnet1 $Gpn_type1] == 1} {
	    set flag2_case5 1
	    gwd::GWpublic_print "NOK" "删除保护LSP失败" $fileId
	} else {
	    gwd::GWpublic_print "OK" "删除保护LSP成功" $fileId
	}
    if {[gwd::GPN_DelLsp "GPN_PTN_LSP_001" $fileId "Tunnel_101" $telnet1 $Gpn_type1] == 1} {
	    set flag2_case5 1
	    gwd::GWpublic_print "NOK" "删除工作LSP失败" $fileId
	} else {
	    gwd::GWpublic_print "OK" "删除工作LSP成功" $fileId
	}
    if {$flag1_case5 == 1 || $flag2_case5 == 1} {
	set flagCase5 1
    }
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
	set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    puts $fileId "======================================================================================\n"
    if {$flagCase5 == 1} {
	gwd::GWpublic_print "NOK" "Test Case 5测试结论" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 5测试结论" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 5 删除线性保护组后，删除工作LSP、保护LSP工作成功 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "===恢复初始化配置...\n"
    lappend flagDel [gwd::GWpublic_delMplsMeg $telnet1 $matchType1 $Gpn_type1 $fileId "meg101"]
    lappend flagDel [gwd::GWpublic_delMplsMeg $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101"]
    lappend flagDel [gwd::GWpublic_Delvlan $telnet1 $matchType1 $Gpn_type1 $fileId $vid1]
    lappend flagDel [gwd::GWpublic_Delvlan $telnet1 $matchType1 $Gpn_type1 $fileId $vid2]
    lappend flagDel [gwd::GWpublic_Delvlan $telnet1 $matchType1 $Gpn_type1 $fileId $vid3]
    if {[string match "L2" $Worklevel]} {
	lappend flagDel [gwd::GWpublic_CfgVlanStack $telnet1 $matchType1 $Gpn_type1 $fileId $testPort1 "none"]
    }
    foreach port $lDev1TestPort {
	if {[string match -nocase "L3" $Worklevel] && [string match -nocase "PTN" $SoftVer]} {
	    lappend flagDel [gwd::GWL2_AddPort $telnet1 $matchType1 $Gpn_type1 $fileId $port "enable" "disable"]
	}
    }
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
	set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    lappend flagDel [gwd::GWpublic_addPwLabelRange $telnet1 $matchType1 $Gpn_type1 $fileId "16" "2047" "2048" "1048575"]
    #修改标签范围需保存重启后修改才生效
    gwd::GWpublic_SaveCfg $telnet1 $matchType1 $Gpn_type1 $fileId
    gwd::GWpublic_Reboot $telnet1 $matchType1 $Gpn_type1 $fileId
    after $rebootTime
    set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
    set lSpawn_id [lreplace $lSpawn_id 0 0 $telnet1]
    gwd::GWpublic_printAbnormal $fileId $fd_log $flagDel "FLAGD" $startSeconds "测试结束后配置恢复" "测试结束后配置恢复" "GPN_PTN_LSP_001"
    gwd::GWpublic_printAbnormal $fileId $fd_log $FLAGF "FLAGF" $startSeconds $lFailFile "测试过程中所有配置文件都上传成功" "GPN_PTN_LSP_001"
    
    chan seek $fileId 0
    puts $fileId "\n**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "GPN_PTN_LSP_001测试目的：MLPS配置\n"
    gwd::GWpublic_printCompletedRunTime $fileId $startSeconds

    if {$flagCase1 == 1 ||$flagCase2 == 1 || $flagCase3 == 1 || $flagCase4 == 1 || $flagCase5 == 1 || [regexp {[^0\s]} $flagDel]} {
    set flagResult 1
    }
    gwd::GWpublic_print [expr {($flagResult == 1) ? "NOK" : "OK"}] "GPN_PTN_LSP_001测试结果" $fileId
    puts $fileId ""
    gwd::GWpublic_print [expr {($flagCase1 == 0) ? "OK" : "NOK"}] "Test Case 1 测试结果" $fileId
    gwd::GWpublic_print [expr {($flagCase2 == 0) ? "OK" : "NOK"}] "Test Case 2测试结果" $fileId
    gwd::GWpublic_print [expr {($flagCase3 == 0) ? "OK" : "NOK"}] "Test Case 3测试结果" $fileId
    gwd::GWpublic_print [expr {($flagCase4 == 0) ? "OK" : "NOK"}] "Test Case 4测试结果" $fileId
    gwd::GWpublic_print [expr {($flagCase5 == 0) ? "OK" : "NOK"}] "Test Case 5测试结果" $fileId
    puts $fileId ""
    gwd::GWpublic_print "== FA1 == [expr {($flag1_case1 == 1) ? "NOK" : "OK"}]" "（结论）创建工作LSP和保护LSP[expr {($flag1_case1 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FA2 == [expr {($flag2_case1 == 1) ? "NOK" : "OK"}]" "（结论）配置PW性能统计使能，配置以太网接入端口性能统计使能，确认配置[expr {($flag2_case1 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FA3 == [expr {($flag3_case1 == 1) ? "NOK" : "OK"}]" "（结论）创建LSP层OAM[expr {($flag3_case1 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FA4 == [expr {($flag4_case1 == 1) ? "NOK" : "OK"}]" "（结论）配置LSP线性保护组[expr {($flag4_case1 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FC1 == [expr {($flag1_case3 == 1) ? "NOK" : "OK"}]" "（结论）工作和保护LSP无MEP，线性保护组使能配置失效[expr {($flag1_case3 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FC2 == [expr {($flag2_case3 == 1) ? "NOK" : "OK"}]" "（结论）工作和保护LSP有MEP，线性保护组使能配置有效[expr {($flag2_case3 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FD1 == [expr {($flag1_case4 == 1) ? "NOK" : "OK"}]" "（结论）工作和保护LSP目的地址不同，线性保护组使能配置失败[expr {($flag1_case4 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FE1 == [expr {($flag1_case5 == 1) ? "NOK" : "OK"}]" "（结论）删除线性保护组[expr {($flag1_case5 == 1) ? "失败" : "成功"}]" $fileId
    gwd::GWpublic_print "== FE2 == [expr {($flag2_case5 == 1) ? "NOK" : "OK"}]" "（结论）删除LSP[expr {($flag2_case5 == 1) ? "失败" : "成功"}]" $fileId
    puts $fileId ""
    puts $fileId "**************************************************************************************"
    puts $fileId ""
    puts $fileId "**************************************************************************************"
} err]} {
    gwd::GWpublic_printAbnormal $fileId $fd_log 1 "FLAGE" $startSeconds "Execution exception!The error is==$err" "" "GPN_PTN_LSP_001"
}
close $fileId
log_file -noappend
close $fd_log

if {$flagResult == 1} {
    file rename "report\\GPN_PTN_001_REPORT.txt" "report\\NOK_GPN_PTN_001_REPORT.txt"
    file rename "log\\GPN_PTN_001_LOG.txt" "log\\NOK_GPN_PTN_001_LOG.txt"
} else {
    file rename "report\\GPN_PTN_001_REPORT.txt" "report\\OK_GPN_PTN_001_REPORT.txt"
    file rename "log\\GPN_PTN_001_LOG.txt" "log\\OK_GPN_PTN_001_LOG.txt"
}
if {[regexp {[^0\s]} $flagDel]} {
    exit 1
}
