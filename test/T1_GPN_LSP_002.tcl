#!/bin/sh
# T1_GPN_PTN_LSP_002.tcl \
exec tclsh "$0" ${1+"$@"}
#-----------------------------------------------------------------------------------------------------------------------------------
#测试目的:MPLS业务验证
#1-搭建LSP1:1、搭建EVPL业务
#2-抓包分析APS、OAM的CC正常，无告警
#测试拓扑类型一:(仅以7600为例)                               
#                      
#                                                   ___________
#                                                  |   4GE/ge  |
#                                           	   |   8fx     |
#                                           	   |           |
#                                           	   |           |
#                                           	   |           |
#                                           	   |GPN(7600)  |
#                                        (13/2 P3) |           |  (13/1 P4)
#                                     _____________|___________|_____________     
#                                    |                                       |
#                                    |                                       |
#                                    |  (2/1 P1)                   (1/4 P5)  |      
#                               _____|______                            _____|_____                               
#                              |   4GE/ge  |                           |   4GE/ge  |
#  _______                     |   8fx     |                           |   8fx     |――――――――――――TC2(7/1 TC2)     
# |       |                    |           |                           |           | (15/1 P11) 
# |  PC   |___Internet连接 ____|           |                           |           |
# |_______|                    |           |                           |           |
#    /__\                      |GPN(7600)  |                           |GPN(7600)  |       
#          (7/2 TC1)TC1――――――――|           |                           |           |    
#                     (16/1 P9)|___________|                           |_____ _____|
#                                    |                                       |
#                                    |                                       |
#                                    | (1/1 P2)                    (4/1 P6)  |
#                                    |_____________ ___________ _____________|
#                                         		   |   4GE/ge  |
#                                        (7/4 P7)  |   8fx     |  (7/2 P8)
#                                                  |           |
#                                                  |           |
#                                                  |           |
#                                                  |GPN(7600)  |
#                                                  |           |
#                                                  |___________|                                                        
#                                                                                                  
#-----------------------------------------------------------------------------------------------------------------------------------
#脚本运行条件
##1、按照测试拓扑搭建测试环境:将GPN的管理端口（U/D）和PC的网口与Internet相连，GPN的2个上联口（A,B）
#   与STC端口（ 9/9）（9/10）相连，GPN的C口和与STC的9/11相连
#2、在GPN上清空所有 配置，建立管理vlan vid=4000，在该vlan上设置管理IP，并untagged方式添加管理端口（U/D）
#3、对于7600插有8fx/8fe板卡时不支持交换盘和主控板主备倒换，7600S不支持交换盘和主控板主备倒换
#-----------------------------------------------------------------------------------------------------------------------------------
#测试过程：
#1、搭建Test Case 1测试环境
#   <1>按照拓扑搭建环境：NE1，NE2，NE3，NE4之间的相互连接的端口角色为NNI，使用GE接口连接；
#      使用DCN管理，配置NE1为网关网元，NE2，NE3，NE4为非网管网元
#   <2>NE1和NE2及NE2和NE3及NE1和NE4及NE4和NE3之间，承载工作LSP和承载保护LSP的NNI端口位于不
#      同的板卡，使用不同的VLANIF接口，配置不同网段地址，并配置静态ARP表项
#   <3>创建NE1到NE3之间的一条专线业务EPL或EVPL，ac使用GE端口，创建LSP1：1，工作路径NE1-NE2
#      -NE3，保护路径NE1-NE4-NE3(建立LSP1:1的组数由测试人员选定)
#   <4>在NE1和NE3上创建之间创建一条专线业务，并创建保护LSP，配置工作和保护LSP的OAM，配置
#      LSP1:1保护组，恢复模式为恢复，WTR时间1分钟，并使能协议
#   <5>在NE2和NE4上配置对工作及保护LSP标签交换，配置工作及保护OAM的MIP，确认配置正确
#   <6>确认NE1和NE3的线性保护组的协议状态为使能，当前实际工作为工作路径，倒换状态为无请求(NR)，确认正确
#2、搭建Test Case 2测试环境
#   <1>镜像NE1和NE3承载保护LSP的NNI端口，抓包分析APS报文，报文数据为0f00 0000(NR)，确认正确
#   <2>NE1和NE3之间对发流量，发包速率为10000fps，NE1到NE3之间业务正常无丢包，工作和保护LSP的OAM的CC正常，且无告警
#   <3>业务正常情况下，查看各设备dcn状态均正确并可正常管理，并作出forwarding和discarding端口的记录；
#3、搭建Test Case 3测试环境
#4、搭建Test Case 4测试环境
#3、搭建Test Case 4测试环境
set startSeconds [clock seconds]
package require gwd 2.0
package require stcPack
package require md5
if {[catch {
	close stdout
	file mkdir "log"
	set fd_log [open "log\\GPN_PTN_LSP_002_LOG.txt" a]
	set stdout $fd_log
	log_file log\\GPN_PTN_LSP_002_LOG.txt
	chan configure $stdout -blocking 0 -buffering none;#非阻塞模式 按行flush
	
	file mkdir "report"
	set fileId [open "report\\GPN_PTN_LSP_002_REPORT.txt" a+]
	chan configure $fileId -blocking 0 -buffering none;#非阻塞模式 按行flush
	
	file mkdir "debug"
	set fd_debug [open debug\\GPN_PTN_LSP_002_DEBUG.txt a]
	exp_internal -f debug\\GPN_PTN_LSP_002_DEBUG.txt 0
	chan configure $fd_debug -blocking 0 -buffering none;#非阻塞模式 按行flush
	
	source test\\LSP_VarSet.tcl
	source test\\LSPBH_Mode_Function.tcl

	array set acapture {capMode "REGULAR_MODE" capSource "Tx_Rx_MODE"}

	set flagCase1 0                         ; #Test Case 1标志位
	set flagCase2 0                         ; #Test Case 2标志位
	set flagCase3 0             			; #Test Case 3标志位
	set flagCase4 0							; #Test Case 4标志位
	set flagCase5 0							; #Test Case 5标志位
	set flagResult 0
	set FLAGE 0
	set cfgId 0

	set tcId 0 								; #生成的xml文件标志位
	set capId 0								; #生成的pcap文件标志位
	set FLAGF 0
	set ip1 192.168.1.10
	set ip2 192.168.1.11
	set ip3 192.168.1.12
	set ip4 192.168.1.13

	set destAddr1 4.4.4.4
	set destAddr2 1.1.1.1

	
    #为测试结论预留空行 
	for {set i 0} {$i < 80} {incr i} {
	    puts $fileId "                                                                                                                                                                                                                "	
	}

	regsub {/} $GPNTestEth1 {_} GPNTestEth1_cap
	regsub {/} $GPNTestEth2 {_} GPNTestEth2_cap
	
	puts $fileId "登录被测设备...\n"
	puts $fileId "\n=====登录被测设备1====\n"
	set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
	puts $fileId "\n=====登录被测设备2====\n"
	set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
	puts $fileId "\n=====登录被测设备3====\n"
	set telnet3 [gwd::GWpublic_loginGpn $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 $fileId]
	puts $fileId "\n=====登录被测设备4====\n"
	set telnet4 [gwd::GWpublic_loginGpn $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $fileId]
	puts $fileId "**************************************************************************************\n"
	puts $fileId "**************************************************************************************\n" 
	#用于导出被测设备用到的变量
	set lSpawn_id "$telnet1 $telnet2 $telnet3 $telnet4"
	set lMatchType "$matchType1 $matchType2 $matchType3 $matchType4"
	set lDutType "$Gpn_type1 $Gpn_type2 $Gpn_type3 $Gpn_type4"
	set lIp "$gpnIp1 $gpnIp2 $gpnIp3 $gpnIp4"

	puts $fileId "===MPLS业务验证 LSP交换基础配置开始..."
	set portList1 "$GPNPort1 $GPNPort2"
	set portList2 "$GPNPort3 $GPNPort4"
	set portList3 "$GPNPort5 $GPNPort6"
	set portList4 "$GPNPort7 $GPNPort8"
	foreach port $portList1 {
		if {[string match -nocase "PTN" $SoftVer]} {
			lappend cfgFlag [gwd::GWL2_AddPort $telnet1 $matchType1 $Gpn_type1 $fileId $port "enable" "enable"]
				}
	}
	set rebootSlotlist1 [gwd::GWpulic_getWorkCardList $portList1]
	gwd::GWpublic_print "OK" "获取设备NE1($gpnIp1)业务板卡槽位号$rebootSlotlist1" $fileId
	set mslot1 [gwd::GWpulic_getWorkCardList $managePort1]
	gwd::GWpublic_print "OK" "获取设备NE1($gpnIp1)管理口所在槽位号$mslot1" $fileId
	lappend cfgFlag [gwd::GWpublic_GetSysMac $telnet1 $matchType1 $Gpn_type1 $fileId gpnMac1]
		regexp -nocase {([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})} $gpnMac1 match a b c d e f
		set dev_sysmac1 $a$b.$c$d.$e$f

	foreach port $portList2 {
		if {[string match -nocase "PTN" $SoftVer]} {
			lappend cfgFlag [gwd::GWL2_AddPort $telnet2 $matchType2 $Gpn_type2 $fileId $port "enable" "enable"]
				}
	}
	set rebootSlotlist2 [gwd::GWpulic_getWorkCardList $portList2]
	gwd::GWpublic_print "OK" "获取设备NE2($gpnIp2)业务板卡槽位号$rebootSlotlist2" $fileId
	set mslot2 [gwd::GWpulic_getWorkCardList $managePort2]
	gwd::GWpublic_print "OK" "获取设备NE1($gpnIp2)管理口所在槽位号$mslot2" $fileId
	lappend cfgFlag [gwd::GWpublic_GetSysMac $telnet2 $matchType2 $Gpn_type2 $fileId gpnMac2]
		regexp -nocase {([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})} $gpnMac2 match a b c d e f
		set dev_sysmac2 $a$b.$c$d.$e$f

	foreach port $portList3 {
		if {[string match -nocase "PTN" $SoftVer]} {
			lappend cfgFlag [gwd::GWL2_AddPort $telnet3 $matchType3 $Gpn_type3 $fileId $port "enable" "enable"]
		}
	}
	set rebootSlotlist3 [gwd::GWpulic_getWorkCardList $portList3]
	gwd::GWpublic_print "OK" "获取设备NE3($gpnIp3)业务板卡槽位号$rebootSlotlist3" $fileId
	set mslot3 [gwd::GWpulic_getWorkCardList $managePort3]
	gwd::GWpublic_print "OK" "获取设备NE3($gpnIp3)管理口所在槽位号$mslot3" $fileId
	lappend cfgFlag [gwd::GWpublic_GetSysMac $telnet3 $matchType3 $Gpn_type3 $fileId gpnMac3]
		regexp -nocase {([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})} $gpnMac3 match a b c d e f
		set dev_sysmac3 $a$b.$c$d.$e$f

	foreach port $portList4 {
		if {[string match -nocase "PTN" $SoftVer]} {
			lappend cfgFlag [gwd::GWL2_AddPort $telnet4 $matchType4 $Gpn_type4 $fileId $port "enable" "enable"]
				}
	}
	set rebootSlotlist4 [gwd::GWpulic_getWorkCardList $portList4]
	gwd::GWpublic_print "OK" "获取设备NE4($gpnIp4)业务板卡槽位号$rebootSlotlist4" $fileId
	set mslot4 [gwd::GWpulic_getWorkCardList $managePort4]
	gwd::GWpublic_print "OK" "获取设备NE1($gpnIp1)管理口所在槽位号$mslot2" $fileId
	lappend cfgFlag [gwd::GWpublic_GetSysMac $telnet4 $matchType4 $Gpn_type4 $fileId gpnMac4]
		regexp -nocase {([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})\.([0-9|a-f]{2})([0-9|a-f]{2})} $gpnMac4 match a b c d e f
		set dev_sysmac4 $a$b.$c$d.$e$f

	###  MPLS业务基础配置
	#	<1>NE1，NE2，NE3，NE4之间的相互连接的端口角色为NNI，使用GE接口连接；
	#	<2>使用DCN管理，配置NE1为网关网元，NE2，NE3，NE4为非网管网元
	#	<3>承载工作LSP和承载保护LSP的NNI端口位于不同的板卡，使用不同的VLANIF接口，配置不同网段地址，并配置静态ARP表项
	#	<4>创建NE1到NE3之间的一条专线业务EPL或EVPL，ac使用GE端口，创建LSP1：1，工作路径NE1-NE2-NE3，保护路径NE1-NE4-NE3
	if {[string match "L2" $Worklevel]} {
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet1 $matchType1 $Gpn_type1 $fileId $GPNPort1 "enable"]
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet1 $matchType1 $Gpn_type1 $fileId $GPNPort2 "enable"]
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet2 $matchType2 $Gpn_type2 $fileId $GPNPort3 "enable"]
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet2 $matchType2 $Gpn_type2 $fileId $GPNPort4 "enable"]
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet3 $matchType3 $Gpn_type3 $fileId $GPNPort5 "enable"]
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet3 $matchType3 $Gpn_type3 $fileId $GPNPort6 "enable"]
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet4 $matchType4 $Gpn_type4 $fileId $GPNPort7 "enable"]
		lappend cfgFlag [gwd::GWpublic_CfgVlanStack $telnet4 $matchType4 $Gpn_type4 $fileId $GPNPort8 "enable"]
		###  配置DCN管理
		gwd::GWpublic_addDCN $telnet1 $matchType1 $Gpn_type1 $fileId "gat" "4094" "253"  "$GPNTestEthMgt $GPNPort1 $GPNPort2" "mgt ne-to-ne ne-to-ne"
		AddportAndIptovlan $telnet1 $matchType1 $Gpn_type1 $fileId "4094" "port" $GPNTestEthMgt "untagged" "$ip1" 24
		gwd::GWpublic_addDCN $telnet2 $matchType2 $Gpn_type2 $fileId "ne" "4094" "253"  "$GPNPort3 $GPNPort4" "ne-to-ne ne-to-ne"
		AddportAndIptovlan $telnet2 $matchType2 $Gpn_type2 $fileId "4094" "port" $GPNPort3 "tagged" "$ip2" 24
		gwd::GWpublic_addDCN $telnet3 $matchType3 $Gpn_type3 $fileId "ne" "4094" "253"  "$GPNPort5 $GPNPort6" "ne-to-ne ne-to-ne"
		AddportAndIptovlan $telnet3 $matchType3 $Gpn_type3 $fileId "4094" "port" $GPNPort5 "tagged" "$ip3" 24
		gwd::GWpublic_addDCN $telnet4 $matchType4 $Gpn_type4 $fileId "ne" "4094" "253"  "$GPNPort7 $GPNPort8" "ne-to-ne ne-to-ne"
		AddportAndIptovlan $telnet4 $matchType4 $Gpn_type4 $fileId "4094" "port" $GPNPort7 "tagged" "$ip4" 24
	} 
	###  建立不同的vlanif接口，并配置ARP表项
	for {set i 1} {$i < [expr 1+$lsp_num]} {incr i} {
	set address10 11.11.$i.1
	set address41 41.41.$i.2
	set address11 11.11.$i.2
	set address20 21.21.$i.1
	set address21 21.21.$i.2
	set address30 31.31.$i.1
	set address40 41.41.$i.1
	set address31 31.31.$i.2

	set interface10 v[expr 2*$i]
	set interface11 v[expr 2*$i]
	set interface20 v[expr 2*$i+1]
	set interface21 v[expr 2*$i+1]
	set interface30 v[expr 2*$i]
	set interface31 v[expr 2*$i]
	set interface40 v[expr 2*$i+1]
	set interface41 v[expr 2*$i+1]

	set interface1101 [expr 1100+$i]

	set tunnel_work "Tunnel_[expr 2*$i-1]"
	set tunnel_protect "Tunnel_[expr 2*$i]"
	set in_label_1 "[expr 14+2*$i]";				#16开始
	set out_label_1 "[expr 15+2*$i]";				#17开始
	set ident_lsp_1 "[expr 14+2*$i]";				#16开始
	set in_label_2 "[expr 1014+2*$i]";				#1016开始
	set out_label_2 "[expr 1015+2*$i]";				#1017开始
	set ident_lsp_2 "[expr 1014+2*$i]";				#1016开始
	set pw_name "pw$i"
	set ac_name "ac$i"
	set meg_work "meg[expr 2*$i-1]"
	set meg_protect "meg[expr 2*$i]"
	set local_mepid "[expr 2*$i-1]"
	set remote_mepid "[expr 2*$i]"
	set remote_label "[expr 2109+2*$i]"
	set local_label "[expr 2110+2*$i]"

	regexp -nocase {(\d+)} $interface10 match vid10
	regexp -nocase {(\d+)} $interface41 match vid41
	regexp -nocase {(\d+)} $interface11 match vid11
	regexp -nocase {(\d+)} $interface20 match vid20
	regexp -nocase {(\d+)} $interface21 match vid21
	regexp -nocase {(\d+)} $interface30 match vid30
	regexp -nocase {(\d+)} $interface40 match vid40
	regexp -nocase {(\d+)} $interface31 match vid31
	
	lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface10 $address10 $GPNPort1 $matchType1 $Gpn_type1 $telnet1]
	lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface41 $address41 $GPNPort2 $matchType1 $Gpn_type1 $telnet1]
	 lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface11 $address11 $GPNPort3 $matchType2 $Gpn_type2 $telnet2]
	 lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface20 $address20 $GPNPort4 $matchType2 $Gpn_type2 $telnet2]
	lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface21 $address21 $GPNPort5 $matchType3 $Gpn_type3 $telnet3]
	lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface30 $address30 $GPNPort6 $matchType3 $Gpn_type3 $telnet3]
	 lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface40 $address40 $GPNPort7 $matchType4 $Gpn_type4 $telnet4]
	 lappend cfgFlag [PTN_NNI_AddInterIp_tag $fileId $Worklevel $interface31 $address31 $GPNPort8 $matchType4 $Gpn_type4 $telnet4]
	lappend cfgFlag [GPN_CfgVlanArpAddr $matchType1 $fileId $Gpn_type1 $vid10 $address11 $dev_sysmac2 $GPNPort1 $telnet1]
	lappend cfgFlag [GPN_CfgVlanArpAddr $matchType1 $fileId $Gpn_type1 $vid41 $address40 $dev_sysmac4 $GPNPort2 $telnet1]
	 lappend cfgFlag [GPN_CfgVlanArpAddr $matchType2 $fileId $Gpn_type2 $vid11 $address10 $dev_sysmac1 $GPNPort3 $telnet2]
	 lappend cfgFlag [GPN_CfgVlanArpAddr $matchType2 $fileId $Gpn_type2 $vid20 $address21 $dev_sysmac3 $GPNPort4 $telnet2]
	lappend cfgFlag [GPN_CfgVlanArpAddr $matchType3 $fileId $Gpn_type3 $vid21 $address20 $dev_sysmac2 $GPNPort5 $telnet3]
	lappend cfgFlag [GPN_CfgVlanArpAddr $matchType3 $fileId $Gpn_type3 $vid30 $address31 $dev_sysmac4 $GPNPort6 $telnet3]
	 lappend cfgFlag [GPN_CfgVlanArpAddr $matchType4 $fileId $Gpn_type4 $vid40 $address41 $dev_sysmac1 $GPNPort7 $telnet4]
	 lappend cfgFlag [GPN_CfgVlanArpAddr $matchType4 $fileId $Gpn_type4 $vid31 $address30 $dev_sysmac3 $GPNPort8 $telnet4]
	lappend cfgFlag [PTN_UNI_AddInter $telnet1 $matchType1 $Gpn_type1 $fileId $Worklevel $interface1101 $GPNTestEth1]
	lappend cfgFlag [PTN_UNI_AddInter $telnet3 $matchType3 $Gpn_type3 $fileId $Worklevel $interface1101 $GPNTestEth2]
	puts $fileId "======================================================================================\n"
	lappend cfgFlag [gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_work $interface10 $address11 $in_label_1 $out_label_1 "normal" $ident_lsp_1]
	lappend cfgFlag [gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_work $destAddr1]
	lappend cfgFlag [gwd::GWpublic_addLspStat $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_work "enable"]
	lappend cfgFlag [gwd::GWpublic_CfgUndoShutLsp $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_work] 
	lappend cfgFlag [gwd::GWpublic_showTunnelInfo $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_work]
	lappend cfgFlag [gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_protect $interface40 $address40 $in_label_2 $out_label_2 "normal" $ident_lsp_2]
	lappend cfgFlag [gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_protect $destAddr1]
	lappend cfgFlag [gwd::GWpublic_addLspStat $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_protect "enable"]
	lappend cfgFlag [gwd::GWpublic_CfgUndoShutLsp $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_protect]
	lappend cfgFlag [gwd::GWpublic_showTunnelInfo $telnet1 $matchType1 $Gpn_type1 $fileId $tunnel_protect]
	gwd::GWpublic_CfgPw $telnet1 $matchType1 $Gpn_type1 $fileId $pw_name "l2transport" $in_label_1 "" $destAddr1 $remote_label $local_label $ident_lsp_1 "nochange" "" 1 0 "0x8100" "0x8100" ""
	gwd::GWpublic_addPwStatEn $telnet1 $matchType1 $Gpn_type1 $fileId $pw_name "enable"
	gwd::GWPw_AddPwVcType $telnet1 $matchType1 $Gpn_type1 $fileId $pw_name "tagged"
	gwd::GWpublic_CfgAc $telnet1 $matchType1 $Gpn_type1 $fileId $ac_name "" $GPNTestEth1 $interface1101 0 "modify" $interface1101 0 0 "0x8100"
	gwd::GWpublic_CfgAcBind $telnet1 $matchType1 $Gpn_type1 $fileId $ac_name $pw_name ""
	puts $fileId "======================================================================================\n"
	lappend cfgFlag [gwd::GWpublic_CfgLspTunnel $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_work $interface21 $address20 $in_label_2 $out_label_2 "normal" $ident_lsp_2]
	lappend cfgFlag [gwd::GWpublic_CfgLspAddress $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_work $destAddr2]
	lappend cfgFlag [gwd::GWpublic_addLspStat $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_work "enable"]
	lappend cfgFlag [gwd::GWpublic_CfgUndoShutLsp $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_work]
	lappend cfgFlag [gwd::GWpublic_CfgLspTunnel $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_protect $interface30 $address31 $in_label_1 $out_label_1 "normal" $ident_lsp_1]
	lappend cfgFlag [gwd::GWpublic_CfgLspAddress $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_protect $destAddr2]
	lappend cfgFlag [gwd::GWpublic_addLspStat $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_protect "enable"]
	lappend cfgFlag [gwd::GWpublic_CfgUndoShutLsp $telnet3 $matchType3 $Gpn_type3 $fileId $tunnel_protect]
	gwd::GWpublic_CfgPw $telnet3 $matchType3 $Gpn_type3 $fileId $pw_name "l2transport" $in_label_2 "" $destAddr2 $local_label $remote_label $ident_lsp_2 "nochange" "" 1 0 "0x8100" "0x8100" ""
	gwd::GWpublic_addPwStatEn $telnet3 $matchType3 $Gpn_type3 $fileId $pw_name "enable"
	gwd::GWPw_AddPwVcType $telnet3 $matchType3 $Gpn_type3 $fileId $pw_name "tagged"
	gwd::GWpublic_CfgAc $telnet3 $matchType3 $Gpn_type3 $fileId $ac_name "" $GPNTestEth2 $interface1101 0 "modify" $interface1101 0 0 "0x8100"
	gwd::GWpublic_CfgAcBind $telnet3 $matchType3 $Gpn_type3 $fileId $ac_name $pw_name ""
	 puts $fileId "======================================================================================\n"
	 gwd::GWpublic_createLspSw $telnet2 $matchType2 $Gpn_type2 $fileId $Worklevel $interface10 $address10 $out_label_2 $in_label_1 "0" $out_label_2 "normal"
	 gwd::GWpublic_createLspSw $telnet2 $matchType2 $Gpn_type2 $fileId $Worklevel $interface21 $address21 $out_label_1 $in_label_2 "0" $out_label_1 "normal"
	 puts $fileId "======================================================================================\n"
	 gwd::GWpublic_createLspSw $telnet4 $matchType4 $Gpn_type4 $fileId $Worklevel $interface41 $address41 $out_label_1 $in_label_2 "0" $out_label_1 "normal"
	 gwd::GWpublic_createLspSw $telnet4 $matchType4 $Gpn_type4 $fileId $Worklevel $interface30 $address30 $out_label_2 $in_label_1 "0" $out_label_2 "normal"
	 puts $fileId "======================================================================================\n"
	gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId $meg_work "lsp" $tunnel_work $local_mepid $remote_mepid
	gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId $meg_work "3ms"
	gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId $meg_work "enable"
	gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId $meg_protect "lsp" $tunnel_protect $remote_mepid $local_mepid
	gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId $meg_protect "3ms"
	gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId $meg_protect "enable"
	puts $fileId "======================================================================================\n"
	gwd::GWpublic_addMplsOam $telnet3 $matchType3 $Gpn_type3 $fileId $meg_work "lsp" $tunnel_work $remote_mepid $local_mepid
	gwd::GWpublic_addMplsCcInt $telnet3 $matchType3 $Gpn_type3 $fileId $meg_work "3ms"
	gwd::GWpublic_addMplsCc $telnet3 $matchType3 $Gpn_type3 $fileId $meg_work "enable"
	gwd::GWpublic_addMplsOam $telnet3 $matchType3 $Gpn_type3 $fileId $meg_protect "lsp" $tunnel_protect $local_mepid $remote_mepid
	gwd::GWpublic_addMplsCcInt $telnet3 $matchType3 $Gpn_type3 $fileId $meg_protect "3ms"
	gwd::GWpublic_addMplsCc $telnet3 $matchType3 $Gpn_type3 $fileId $meg_protect "enable"
	puts $fileId "======================================================================================\n"
	lappend cfgFlag [gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 $ac_name $tunnel_work $tunnel_protect "1" "enable"]
	puts $fileId "======================================================================================\n"
	lappend cfgFlag [gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type3 $telnet3 $ac_name $tunnel_work $tunnel_protect "1" "enable"]

}


	puts $fileId ""
	puts $fileId "===MPLS业务验证 LSP交换基础配置结束，开始测试..."
	puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
	gwd::GWpublic_sendSameStrToFiles  "$fd_debug $fd_log $fileId" "Test Case 1 确认配置正确后，查看NE1和NE3的线性保护组状态 测试开始\n"
	set flag1_Case1 0
	set flag2_Case1 0
	set flag3_Case1 0
	puts $fileId ""
	gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====查看NE1和NE3线性保护组使能状态，测试开始=====\n"
	lappend flag1_Case1 [gwd::GWpublic_ShowMlpsRun $fileId $matchType1 $Gpn_type1 "ac1" $telnet1 ""]
	lappend flag1_Case1 [gwd::GWpublic_ShowMlpsRun $fileId $matchType3 $Gpn_type3 "ac1" $telnet3 ""]
	puts $fileId ""
	if {"1" in $flag1_Case1} {
		set flagCase1 1
		gwd::GWpublic_print "NOK" "FA1（结论）NE1($gpnIp1)和NE3($gpnIp3)线性保护组使能状态" $fileId 
	} else { 
		gwd::GWpublic_print "OK" "FA1（结论）NE1($gpnIp1)和NE3($gpnIp3)线性保护组使能状态" $fileId
	}
	gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====查看NE1和NE3线性保护组使能状态，测试结束=====\n"
	puts $fileId ""
	puts $fileId "======================================================================================\n"
	puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====查看线性保护组工作状态，测试开始=====\n"
    lappend flag2_Case1 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "work"]
    lappend flag2_Case1 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "NR"] 
    lappend flag2_Case1 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $gpnIp3 $telnet3 "1" "work"]
    lappend flag2_Case1 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    puts $fileId ""
	if {"1" in $flag2_Case1} {
		set flagCase1 1
		gwd::GWpublic_print "NOK" "FA1（结论）NE1($gpnIp1)和NE3($gpnIp3)线性保护组倒换状态和工作路径异常" $fileId 
	} else { 
		gwd::GWpublic_print "OK" "FA1（结论）NE1($gpnIp1)和NE3($gpnIp3)线性保护组倒换状态和工作路径正常" $fileId
	}
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====查看线性保护组工作状态，测试结束=====\n"
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase1] == 1)? "NOK":"OK"}] "Test Case 1 测试结论" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 1 确认配置正确后，查看NE1和NE3的线性保护组状态 测试结束\n"
	puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 2 业务正常情况下，查看APS报文及丢包情况 测试开始\n"
    set flag1_Case2 0
    set flag2_Case2 0
    puts $fileId ""
    puts $fileId "创建测试工程...\n"
    stc::connect $stcIp
    stc::reserve "$stcIp/$GPNStcPort1 $stcIp/$GPNStcPort2"
    stc::config automationoptions -logLevel warn
    #创建测试工程
    set hProject [stc::create project]

    gwd::STC_createPort $stcIp $hProject $GPNStcPort1 $GPNEth1Media hport1
    set hgenerator1 [stc::get $hport1 -children-generator]
    set hGeneratorConfig1 [stc::get $hgenerator1 -children-GeneratorConfig]
    stc::config $hGeneratorConfig1 -SchedulingMode RATE_BASED
    set hanalyzer1 [stc::get $hport1 -children-analyzer]
    set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "251658240" "251658240" "4294967295"]
    stc::config $hanalyzer1 -FilterOnStreamId "FALSE"
    set hcapture1 [stc::get $hport1 -children-capture]
    set hCaptureFilter1 [stc::get $hcapture1 -children-CaptureFilter]
    set hCaptureAnalyzerFilter1 [LSP_CaptureAnalyzerFilter $hCaptureFilter1 "TRUE" "APS" "31" "39" "255"]
    #   创建测试端口2
    gwd::STC_createPort $stcIp $hProject $GPNStcPort2 $GPNEth2Media hport2
    set hgenerator2 [stc::get $hport2 -children-generator]
    set hGeneratorConfig2 [stc::get $hgenerator2 -children-GeneratorConfig]
    stc::config $hGeneratorConfig2 -SchedulingMode RATE_BASED
    set hanalyzer2 [stc::get $hport2 -children-analyzer]
    set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251658240" "251658240" "4294967295"]
    stc::config $hanalyzer2 -FilterOnStreamId "FALSE"
    set hcapture2 [stc::get $hport2 -children-capture]
    set hCaptureFilter2 [stc::get $hcapture2 -children-CaptureFilter]
    set hCaptureAnalyzerFilter2 [LSP_CaptureAnalyzerFilter $hCaptureFilter2 "TRUE" "APS" "31" "39" "255"]
    #   配置数据流量
    set dStreamData1 [stc::create "StreamBlock" \
		-under $hport1 \
		-EqualRxPortDistribution "FALSE" \
		-FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:01</dstMac><srcMac>00:10:94:00:00:02</srcMac><vlans name="anon_3785"><Vlan name="Vlan"><pri>000</pri><id>1101</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_3788"><tos name="anon_3789"></tos></tosDiffserv></pdu></pdus></config></frame>} ]
    set RangeModifier1 [stc::create "RangeModifier" \
        -under $dStreamData1 \
        -Mask {00:00:FF:FF:FF:FF} \
        -StepValue {00:00:00:00:00:01} \
        -RecycleCount "$lsp_num" \
        -Data {00:00:01:00:00:01} \
        -EnableStream "TRUE" \
        -Offset "2" \
        -OffsetReference {eth1.dstMac} \
        -Name {MAC Modifier} ] 
    set RangeModifier2 [stc::create "RangeModifier" \
        -under $dStreamData1 \
        -Mask {00:00:FF:FF:FF:FF} \
        -StepValue {00:00:00:00:00:01} \
        -RecycleCount "$lsp_num" \
        -Data {00:10:94:00:00:02} \
        -EnableStream "TRUE" \
        -Offset "2" \
        -OffsetReference {eth1.srcMac} \
        -Name {MAC Modifier} ]
    set RangeModifier3 [stc::create "RangeModifier" \
        -under $dStreamData1 \
        -Mask {4095} \
        -StepValue {1} \
        -RecycleCount "$lsp_num" \
        -Data {1101} \
        -EnableStream "TRUE" \
        -OffsetReference {eth1.vlans.Vlan.id} \
        -Name {Modifier} ]

    set dStreamData2 [stc::create "StreamBlock" \
        -under $hport2 \
        -EqualRxPortDistribution "FALSE" \
        -FrameConfig {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><dstMac>00:00:01:00:00:01</dstMac><srcMac>00:10:94:00:00:02</srcMac><vlans name="anon_3794"><Vlan name="Vlan"><pri>000</pri><id>1101</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"><totalLength>20</totalLength><checksum>14740</checksum><tosDiffserv name="anon_3797"><tos name="anon_3798"></tos></tosDiffserv></pdu></pdus></config></frame>} ]
    set RangeModifier4 [stc::create "RangeModifier" \
        -under $dStreamData2 \
        -Mask {00:00:FF:FF:FF:FF} \
        -StepValue {00:00:00:00:00:01} \
        -RecycleCount "$lsp_num" \
        -Data {00:00:01:00:00:01} \
        -EnableStream "TRUE" \
        -Offset "2" \
        -OffsetReference {eth1.dstMac} \
        -Name {MAC Modifier} ]

	set RangeModifier5 [stc::create "RangeModifier" \
        -under $dStreamData2 \
        -Mask {00:00:FF:FF:FF:FF} \
        -StepValue {00:00:00:00:00:01} \
        -RecycleCount "$lsp_num" \
        -Data {00:10:94:00:00:02} \
        -EnableStream "TRUE" \
        -Offset "2" \
        -OffsetReference {eth1.srcMac} \
        -Name {MAC Modifier} ] 
    set RangeModifier6 [stc::create "RangeModifier" \
        -under $dStreamData2 \
        -Mask {4095} \
        -StepValue {1} \
        -RecycleCount "$lsp_num" \
        -Data {1101} \
        -EnableStream "TRUE" \
        -OffsetReference {eth1.vlans.Vlan.id} \
        -Name {Modifier} ]

    stc::config [stc::get $dStreamData1 -AffiliationStreamBlockLoadProfile] -LoadUnit "FRAMES_PER_SECOND" -Load "10000" 
    stc::config [stc::get $dStreamData2 -AffiliationStreamBlockLoadProfile] -LoadUnit "FRAMES_PER_SECOND" -Load "10000" 

    foreach hStream "$dStreamData1 $dStreamData2" {
        stc::perform streamBlockActivate -streamBlockList $hStream -activate "TRUE"
    }
    stc::apply

    set rateL 9500000;#收发数据流取值最小值范围
    set rateR 10500000;#收发数据流取值最大值范围   
    #   定制结果
    set ResultDataSet1 [TxAndRx_Info $hProject $hport1 infoObj1]
    set ResultDataSet2 [TxAndRx_Info $hProject $hport2 infoObj2]
    set totalPage1 [stc::get $infoObj1 -TotalPageCount]
    set totalPage2 [stc::get $infoObj2 -TotalPageCount]

    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case2_$tcId.xml" [pwd]/Untitled
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====业务无倒换情况下，镜像NE1和NE3承载保护LSP的NNI口，抓包分析APS报文，开始====="
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fileId $GPNTestEth1 aMirror
    array set aMirror "dir1 egress port1 $GPNPort6 dir2 \"\" port2 \"\""
    gwd::GWpublic_CfgPortMirror $telnet3 $matchType3 $Gpn_type3 $fileId $GPNTestEth2 aMirror
    lappend flag1_Case2 [LSP_ApsMessageConfirm "10000" "1" 0 "0f 00 00 00 " "0f 00 00 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fileId $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fileId $GPNTestEth2
	if {"1" in $flag1_Case2} {
		set flagCase2 1
		gwd::GWpublic_print "NOK" "FB1（结论）NE1($gpnIp1)和NE3($gpnIp3)业务正常情况下APS报文状态非0f00 0000，异常" $fileId 
	} else { 
		gwd::GWpublic_print "OK" "FB1（结论）NE1($gpnIp1)和NE3($gpnIp3)业务正常情况下APS报文状态为0f00 0000，正常" $fileId
	}
	gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====业务无倒换情况下，镜像NE1和NE3承载保护LSP的NNI口，抓包分析APS报文，结束====="
	puts $fileId ""
	puts $fileId "======================================================================================\n"
	puts $fileId ""
	gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====NE1和NE3对发流量，发包速率10000fps，检查业务是否正常，开始====="
	## 重新定制分析器
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set filter1 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><vlans name="anon_4271"><Vlan name="Vlan"><id filterMinValue="1101" filterMaxValue="1230">4095</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>}
	set filter2 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><vlans name="anon_4253"><Vlan name="Vlan"><id filterMinValue="1101" filterMaxValue="1230">4095</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>} 
	set startRange "1101"
	set endRange "[expr 1100+$lsp_num]"
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
    set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
	gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case2_$tcId.xml" [pwd]/Untitled
	lappend flag2_Case2 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    lappend flag2_Case2 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "1"]
    lappend flag2_Case2 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "2"]
    puts $fileId ""
    if {"1" in $flag2_Case2} {
    	set flagCase2 1
    	gwd::GWpublic_print "NOK" "FB2（结论）NE1($gpnIp1)和NE3($gpnIp3)对发流量，业务异常" $fileId
    } else {
    	gwd::GWpublic_print "OK" "FB2（结论）NE1($gpnIp1)和NE3($gpnIp3)对发流量，业务正常无丢包,CC无告警" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====NE1和NE3对发流量，发包速率10000fps，检查业务是否正常，结束====="
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase2] == 1)? "NOK":"OK"}] "Test Case 2 测试结论" $fileId
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_002" lFailFileTmp]
    if {$lFailFileTmp != ""} {
    	set lFailFile [concat $lFailFile $lFailFileTmp]
        }  
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 2 业务正常情况下，查看APS报文及丢包情况 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 3 倒换及倒换恢复时间 测试开始\n"
    set flag1_Case3 0
    set flag2_Case3 0
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====信号失效(SF)倒换与恢复，开始====="
    puts $fileId "	*****shutdown掉NE1工作LSP的NNI口*****"
    gwd::GWpublic_CfgPortState $telnet1 $matchType1 $Gpn_type1 $fileId $GPNPort1 "shutdown"
    set lport1 "$hport1 $hport2"
    #此处有倒换发生
    puts $fileId ""
    lappend flag1_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    #清除仪表上的信息
    after 20000
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    stc::perform ResultsClearAll -PortList $lport1
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    
    lappend flag1_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    
    stc::perform ResultsClearAll -PortList $lport1
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "SFW"] 
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "SFW"] 
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "protect"]
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $gpnIp3 $telnet3 "1" "protect"]
    stc::delete $Analyzer16BitFilter1
    stc::delete $Analyzer16BitFilter2
    set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "3204514048" "3204514048" "4294967295"]
    stc::apply
    set tcId 0
	incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case3_$tcId.xml" [pwd]/Untitled
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    array set aMirror "dir1 egress port1 $GPNPort6 dir2 \"\" port2 \"\""
    gwd::GWpublic_CfgPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2 aMirror
    lappend flag1_Case3 [LSP_ApsMessageConfirm1 "20000" "2" "0" "bf 01 01 00 "]
    puts $fileId ""
    puts $fileId "	*****恢复NE1工作LSP的NNI口*****"
    gwd::GWpublic_CfgPortState $telnet1 $matchType1 $Gpn_type1 $fileId $GPNPort1 "undo shutdown"
    stc::config $hfilter132BitFilAna0 -StartOfRange "1593901312" -EndOfRange "1593901312" -Mask "4294967295"
    set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
	incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case3_$tcId.xml" [pwd]/Untitled
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "WTR"]
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "protect"]
    lappend flag1_Case3 [LSP_ApsMessageConfirm "10000" "3" 0 "5f 01 01 00 " "0f 01 01 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2
    after $WaiteTime
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "NR"]
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag1_Case3 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "work"]
    stc::delete $hfilter132BitFilAna0
 	stc::delete $hfilter232BitFilAna0
 	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
	stc::apply
	gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	lappend flag1_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    lappend flag1_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
 	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "251658240" "251658240" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251658240" "251658240" "4294967295"]
	stc::apply
	array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    array set aMirror "dir1 egress port1 $GPNPort6 dir2 \"\" port2 \"\""
    gwd::GWpublic_CfgPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2 aMirror
	lappend flag1_Case3 [LSP_ApsMessageConfirm "10000" "4" 0 "0f 00 00 00 " "0f 00 00 00 "]
	gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2
    puts $fileId ""
    if {"1" in $flag1_Case3} {
		set flagCase3 1
		gwd::GWpublic_print "NOK" "FC1（结论）信号失效(SF)倒换与恢复，业务异常" $fileId 
	} else { 
		gwd::GWpublic_print "OK" "FC1（结论）信号失效(SF)倒换与恢复，业务正常" $fileId
	}
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====信号失效(SF)倒换与恢复测试，结束====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====中间节点重启触发倒换测试，开始====="
    ## 设置APS报文的过滤量和新的捕获报文
 	stc::delete $hfilter132BitFilAna0
 	stc::delete $hfilter232BitFilAna0
 	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    stc::perform ResultsClearAll -PortList $lport1
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    
    gwd::GWpublic_SaveCfg $telnet2 $matchType2 $Gpn_type2 $fileId
    gwd::GWpublic_Reboot $telnet2 $matchType2 $Gpn_type2 $fileId

    lappend flag2_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" vlauemin valuemax]
    #清除仪表上的信息
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息****"
    stc::perform ResultsClearAll -PortList $lport1
    after 2000
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag2_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    after [expr 2*$rebootTime]
    after $WaiteTime
    set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
    lappend flag2_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    if {"1" in $flag2_Case3} {
    	set flagCase3 1
    	gwd::GWpublic_print "NOK" "FC2（结论）中间节点NE2($gpnIp2)掉电触发倒换测试，业务异常" $fileId
    } else {
    	gwd::GWpublic_print "OK" "FC2（结论）中间节点NE2($gpnIp2)掉电触发倒换测试，业务正常无丢包抓取报文正确" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====中间节点重启触发倒换测试，结束====="
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase3] == 1)? "NOK":"OK"}] "Test Case 3 测试结论" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 3 业务正常情况下，查看APS报文及丢包情况 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 4 外部倒换命令 测试开始\n"
    set flag1_Case4 0
    set flag2_Case4 0
    set flag3_Case4 0
    set flag4_Case4 0
    set flag5_Case4 0
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====人工倒换到保护测试，开始====="
    stc::perform ResultsClearAll -PortList $lport1
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag1_Case4 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    lappend flag1_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msp" err] 
    lappend flag1_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "MSP"]
    lappend flag1_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag1_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "protect"]
    lappend flag1_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $Gpn_type3 $telnet3 "1" "protect"]
    lappend flag1_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    stc::perform ResultsClearAll -PortList $lport1
    after 2000
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag1_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
 	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "2130772224" "2130772224" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    set tcId
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case4_$tcId.xml" [pwd]/Untitled
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    array set aMirror "dir1 egress port1 $GPNPort6 dir2 \"\" port2 \"\""
    gwd::GWpublic_CfgPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2 aMirror
    lappend flag1_Case4 [LSP_ApsMessageConfirm "10000" "5" 0 "7f 01 01 00 " "0f 01 01 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2
    stc::delete $hfilter132BitFilAna0
 	stc::delete $hfilter232BitFilAna0
 	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag1_Case4 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    stc::perform ResultsClearAll -PortList $lport1
    after 2000
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag1_Case4 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
   
    lappend flag1_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msw" err]
	lappend flag1_Case4 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
    puts $fileId ""
    if {"1" in $flag1_Case4} {
    	set flagCase2 1
    	gwd::GWpublic_print "NOK" "FD1（结论）人工倒换到保护测试，业务异常" $fileId
    } else {
    	gwd::GWpublic_print "OK" "FD1（结论）人工倒换到保护测试，业务正常无丢包、抓取报文正确" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====人工倒换到保护测试，结束====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====强制倒换到工作测试，开始====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag2_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsw" err] 
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "FS"]
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "work"]
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $gpnIp3 $telnet3 "1" "work"]
    lappend flag2_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    stc::perform ResultsClearAll -PortList $lport1
    after 2000
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag2_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "3741319168" "3741319168" "4294967295"]
    stc::apply
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case4_$tcId.xml" [pwd]/Untitled
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    lappend flag2_Case4 [LSP_ApsMessageConfirm1 "10000" "6" "0" "df 00 00 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    lappend flag2_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msw" err]
    lappend flag2_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msp" err]
	stc::delete $hfilter132BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	lappend flag2_Case4 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
    puts $fileId ""
    if {"1" in $flag2_Case4} {
    	set flagCase2 1
    	gwd::GWpublic_print "NOK" "FD2（结论）强制倒换到工作测试，业务异常" $fileId
    } else {
    	gwd::GWpublic_print "OK" "FD2（结论）强制倒换到工作测试，业务正常无丢包、抓取报文正确" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====强制倒换到工作测试，结束====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====强制倒换到保护测试，开始====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag3_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsp" err]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "FS-P"]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $Gpn_type1 $telnet1 "1" "protect"]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $Gpn_type3 $telnet3 "1" "protect"]

    lappend flag3_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    stc::perform ResultsClearAll -PortList $lport1
    after 2000
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag3_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "3741384960" "3741384960" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case4_$tcId.xml" [pwd]/Untitled
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    array set aMirror "dir1 egress port1 $GPNPort6 dir2 \"\" port2 \"\""
    gwd::GWpublic_CfgPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2 aMirror
    lappend flag3_Case4 [LSP_ApsMessageConfirm "10000" "7" 0 "df 01 01 00 " "0f 01 01 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fd_log $GPNTestEth2
    lappend flag3_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msw" err]
	lappend flag3_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msp" err]
    lappend flag3_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsw" err]
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	lappend flag3_Case4 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
    puts $fileId ""
    if {"1" in $flag3_Case4} {
    	set flagCase2 1
    	gwd::GWpublic_print "NOK" "FD3（结论）强制倒换到保护测试，业务异常" $fileId
    } else {
    	gwd::GWpublic_print "OK" "FD3（结论）强制倒换到保护测试，业务正常无丢包、抓取报文正确" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====强制倒换到保护测试，结束====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====保护锁定测试，开始====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "lp" err]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "LO"]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $Gpn_type1 $telnet1 "1" "work"]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $Gpn_type3 $telnet3 "1" "work"]

    lappend flag4_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    stc::perform ResultsClearAll -PortList $lport1
    after 2000
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "4278190080" "4278190080" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case4_$tcId.xml" [pwd]/Untitled
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    lappend flag4_Case4 [LSP_ApsMessageConfirm1 "20000" "8" "0" "ff 00 00 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    lappend flag4_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msw" err]
	lappend flag4_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msp" err]
	lappend flag4_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsw" err]
	lappend flag4_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsp" err]
	lappend flag4_Case4 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "exer" err]
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	lappend flag4_Case4 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
    puts $fileId ""
    if {"1" in $flag4_Case4} {
    	set flagCase4 1
    	gwd::GWpublic_print "NOK" "FD4（结论）保护锁定测试，业务异常" $fileId
    } else {
    	gwd::GWpublic_print "OK" "FD4（结论）保护锁定测试，业务正常无丢包、抓取报文正确" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====保护锁定测试，结束====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====清除测试，开始====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag5_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $gpnIp1 $telnet1 "ac101" "clear" err]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "NR"]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $Gpn_type1 $telnet1 "1" "work"]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $Gpn_type3 $telnet3 "1" "work"]

    lappend flag5_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "	*****清除仪表上的信息*****"
    stc::perform ResultsClearAll -PortList $lport1
    after 2000
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag5_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "251658240" "251658240" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case4_$tcId.xml" [pwd]/Untitled
    
    lappend flag5_Case4 [LSP_ApsMessageConfirm1 "20000" "9" "0" "0f 00 00 00 "]
	gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    if {"1" in $flag5_Case4} {
    	set flagCase4 1
    	gwd::GWpublic_print "NOK" "FD5（结论）清除测试，业务异常" $fileId
    } else {
    	gwd::GWpublic_print "OK" "FD5（结论）清除测试，业务正常无丢包、抓取报文正确" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====清除，结束====="
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase4] == 1)? "NOK":"OK"}] "Test Case 4 测试结论" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 4 外部倒换命令 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 5 倒换优先级补充 测试开始\n"
    set flag1_Case5 0
    set flag2_Case5 0
    set flag3_Case5 0
    set flag4_Case5 0
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	lappend flag1_Case5 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
	stc::perform ResultsClearAll -PortList $lport1
	gwd::GWpublic_CfgPortState $telnet1 $matchType $Gpn_type1 $fileId $GPNPort1 "shutdown"
	lappend flag1_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "SFW"] 
    lappend flag1_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "SFW"]
    lappend flag1_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
	gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	lappend flag1_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    stc::perform ResultsClearAll -PortList $lport1
    lappend flag1_Case5 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msp" err]
    lappend flag1_Case5 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msw" err]
    gwd::GWpublic_CfgPortState $telnet1 $matchType $Gpn_type1 $fileId $GPNPort1 "undo shutdown"
    after $WaiteTime
    
    #此处有倒换发生
    lappend flag2_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "WTR"] 
    lappend flag2_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag2_Case5 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "protect"]
    if {"1" in $flag1_Case5} {
    	set flagCase5 1
    } 
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "1593901312" "1593901312" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    set tcId 0
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case5_$tcId.xml" [pwd]/Untitled
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    lappend flag2_Case5 [LSP_ApsMessageConfirm1 "20000" "10" "0" "5f 01 01 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
    ###人工倒换到工作
    if {"1" in $flag2_Case5} {
    	set flagCase5 1
    }
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag3_Case5 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msw" err]
    lappend flag3_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "MSW"] 
    lappend flag3_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag3_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
	gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	lappend flag3_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
	gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
	stc::perform ResultsClearAll -PortList $lport1
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "1862270976" "1862270976" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case5_$tcId.xml" [pwd]/Untitled
    lappend flag3_Case5 [LSP_ApsMessageConfirm1 "20000" "11" "0" "6f 00 00 00 "]
    if {"1" in $flag3_Case5} {
    	set flagCase5 1
    }
    ###强制倒换到保护
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case5 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsp" err]
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "FS-P"] 
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $gpnIp3 $telnet3 "1" "protect"]
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    stc::perform ResultsClearAll -PortList $lport1
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    stc::perform ResultsClearAll -PortList $lport1
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "3741384960" "3741384960" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case5_$tcId.xml" [pwd]/Untitled
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
	gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1 aMirror
    lappend flag4_Case5 [LSP_ApsMessageConfirm1 "20000" "12" "0" "df 01 01 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fd_log $GPNTestEth1
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case5 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsw" err]
    lappend flag4_Case5 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msp" err]
    lappend flag4_Case5 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "msw" err]
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::GWpublic_CfgPortState $telnet1 $matchType $Gpn_type1 $fileId $GPNPort1 "shutdown"
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "FS-P"] 
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    gwd::GWpublic_CfgPortState $telnet1 $matchType $Gpn_type1 $fileId $GPNPort1 "undo shutdown"
    gwd::GWpublic_CfgPortState $telnet1 $matchType $Gpn_type1 $fileId $GPNPort2 "shutdown"
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "SFP"] 
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "SFP"]
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "work"]
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    stc::perform ResultsClearAll -PortList $lport1
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    stc::perform ResultsClearAll -PortList $lport1
 #    set filter1 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><srcMac filterMinValue="00:00:00:00:00:00" filterMaxValue="FF:FF:FF:FF:FF:FF">FF:FF:FF:FF:FF:FF</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>} 
	# set filter2 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><srcMac filterMinValue="00:00:00:00:00:00" filterMaxValue="FF:FF:FF:FF:FF:FF">FF:FF:FF:FF:FF:FF</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>} 
	# stc::config $hAnalyzerFrCofFilter1 -FrameConfig $filter1
 #    stc::config $hAnalyzerFrCofFilter2 -FrameConfig $filter2
	# stc::config $hfilter132BitFilAna0 -StartOfRange "4009754624" -EndOfRange "4009754624" -Mask "4294967295"
	stc::delete $Analyzer16BitFilter1
 	stc::delete $Analyzer16BitFilter2
 	set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "4009754624" "4009754624" "4294967295"]
 	set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251724032" "251724032" "4294967295"]
    stc::apply
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case5_$tcId.xml" [pwd]/Untitled
    lappend flag4_Case5 [LSP_ApsMessageConfirm2 "20000" "13" "0" "ef 00 00 00 "]
    
 #    set filter1 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><srcMac filterMinValue="00:00:00:00:00:02" filterMaxValue="00:00:00:00:00:02">FF:FF:FF:FF:FF:FF</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>} 
	# set filter2 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><srcMac filterMinValue="00:00:00:00:00:01" filterMaxValue="00:00:00:00:00:01">FF:FF:FF:FF:FF:FF</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>} 
	# stc::config $hAnalyzerFrCofFilter1 -FrameConfig $filter1
 #    stc::config $hAnalyzerFrCofFilter2 -FrameConfig $filter2
	# stc::config $hfilter132BitFilAna0 -StartOfRange "0" -EndOfRange "4294967295" -Mask "4294967295"
	stc::delete $hfilter132BitFilAna0
	stc::delete $hfilter232BitFilAna0
	set AnalyzerFrameConfigFilter1 [Create_AnalyzerFrameConfigFilter $hanalyzer1 $filter1 $startRange $endRange]
    set AnalyzerFrameConfigFilter2 [Create_AnalyzerFrameConfigFilter $hanalyzer2 $filter2 $startRange $endRange]
 	set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 $startRange $endRange]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 $startRange $endRange]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case5 [gwd::LSP_StatusHignToLow $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsp" err]
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    stc::perform ResultsClearAll -PortList $lport1
    lappend flag4_Case5 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "lp" err]
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "LO"] 
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    stc::perform ResultsClearAll -PortList $lport1
    gwd::GWpublic_CfgPortState $telnet1 $matchType $Gpn_type1 $fileId $GPNPort2 "undo shutdown"
    lappend flag4_Case5 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "clear" err]
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "NR"] 
    lappend flag4_Case5 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag4_Case5 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
	stc::perform ResultsClearAll -PortList $lport1
	if {"1" in $flag4_Case5} {
    	set flagCase5 1
    }
    incr cfgId
	lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_001" lFailFileTmp]
	if {$lFailFileTmp != ""} {
		set lFailFile [concat $lFailFile $lFailFileTmp]
	}
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase5] == 1)? "NOK":"OK"}] "Test Case 5 测试结论" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 5 倒换优先级补充 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 6 配置保存恢复 测试开始\n"
    set flag1_Case6 0
    lappend flag1_Case6 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun1 "60000"]
    set compareFilerun1 [open "log\\LSPBH_002_第一次在$matchType1\上Showrun.txt" w]
	puts $compareFilerun1 $contentrun1
	close $compareFilerun1
    gwd::GWpublic_SaveCfg $telnet1 $matchType1 $Gpn_type1 $fileId
    gwd::GWpublic_SaveCfg $telnet3 $matchType3 $Gpn_type3 $fileId
	gwd::GWpublic_Reboot $telnet1 $matchType1 $Gpn_type1 $fileId
	after $rebootTime
	set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
	set lSpawn_id [lreplace $lSpawn_id 0 0 $telnet1]
	####此处需要修改！！！
	lappend flag1_Case6 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun2 "60000"]
	set compareFilerun2 [open "log\\LSPBH_002_重启后在$matchType1\上Showrun.txt" w]
	puts $compareFilerun2 $contentrun2
	close $compareFilerun2
	if {[md5::md5 -hex -filename "log\\LSPBH_002_第一次在$matchType1\上Showrun.txt"]==[md5::md5 -hex -filename "log\\LSPBH_002_重启后在$matchType1\上Showrun.txt"]} {
				gwd::GWpublic_print "OK" "在$matchType1\上进行重启前后的配置信息比对，结果相同。" $fileId
			} else {
				lappend flag1_Case6 1 
				gwd::GWpublic_print "NOK" "在$matchType1\上进行重启前后的配置信息比对，结果不相同，请查看\n               \
				LLSPBH_002_第一次在$matchType1\上Showrun.txt和LSPBH_002_重启后在$matchType1\上Showrun.txt文件。" $fileId
			}
	lappend flag1_Case6 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    lappend flag1_Case6 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "1"]
    lappend flag1_Case6 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "2"]
    lappend flag1_Case6 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "work"]
    if {"1" in $flag1_Case6} {
    	set flagCase6 1
    }
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase6] == 1)? "NOK":"OK"}] "Test Case 6 测试结论" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 6 配置保存恢复 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 7 主控/SW倒换对功能影响 测试开始\n"
    set flag1_Case7 0
    for {set j 1} {$j<$cntdh} {incr j} {
		if {![gwd::GWCard_AddSwitch $telnet1 $matchType1 $Gpn_type1 $fileId]} {
			after [expr 2*$rebootTime]
			set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
			set lSpawn_id [lreplace $lSpawn_id 1 1 $telnet1]
			lappend flag1_Case7 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
			    stc::perform ResultsClearAll -PortList $lport1
		} else {
			puts $fileId "$matchType1\不支持NMS主备倒换或者只有一块NMS，测试跳过"
		}
	}
    
    gwd::GWCard_AddSwitchSw $telnet1 $matchType1 $Gpn_type1 $fileId
    lappend flag1_Case7 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    stc::perform ResultsClearAll -PortList $lport1
    lappend flag1_Case7 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "WTR"]
    after $WaiteTime
    lappend flag1_Case7 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    lappend flag1_Case7 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "NR"]
    lappend flag1_Case7 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet1 "3" "NR"]
    gwd::GWCard_AddSwitchSw $telnet1 $matchType1 $Gpn_type1 $fileId
    lappend flag1_Case7 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "clear" err]
    lappend flag1_Case7 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "NR"] 
    lappend flag1_Case7 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag1_Case7 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
 #    set lsp101 "null";set lsp2101 "null";set pw101 "null";set ac101 "null";set meg1 "null";set meg2 "null";set pro-grp101 "null";

	# set lsp101_tmp "";set lsp2101_tmp "";set pw101_tmp "";set ac101_tmp "";set meg1_tmp "";set meg2_tmp "";set pro-grp101_tmp "";
	# set showMpls 3;set showCfm 3;set showMlps 3;
	# while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "mpls" result_mpls]} {
	# 	incr showMpls -1
	# }
	# while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "cfm" result_cfm]} {
	# 	incr showCfm -1
	# }
	# while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "mlps" result_mlps]} {
	# 	incr showMlps -1
	# }
	# regexp {interface lsp tunnel Tunnel_101.*?exit} $result_mpls lsp101
	# regexp {interface lsp tunnel Tunnel_2101.*?exit} $result_mpls lsp2101
	# regexp {interface pw pw101.*?exit} $result_mpls pw101
	# regexp {interface ac ac101.*?exit} $result_mpls ac101
	# regexp {mpls-tp-meg meg1.*?exit} $result_cfm meg1
	# regexp {mpls-tp-meg meg2.*?exit} $result_cfm meg2
	# regexp {create pro-grp ac101.*?exit} $result_mlps pro-grp101
	lappend flag1_Case7 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun3 "60000"]
    set compareFilerun3 [open "log\\LSPBH_002_主备倒换后在$matchType1\上Showrun.txt" w]
	puts $compareFilerun3 $contentrun3
	close $compareFilerun3

    gwd::GWpublic_SaveCfg $telnet1 $matchType1 $Gpn_type1 $fileId
    gwd::GWpublic_SaveCfg $telnet3 $matchType3 $Gpn_type3 $fileId
	gwd::GWpublic_Reboot $telnet1 $matchType1 $Gpn_type1 $fileId
	after $rebootTime

	set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
	set lSpawn_id [lreplace $lSpawn_id 0 0 $telnet1]
	lappend flag1_Case7 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun2 "60000"]
	set compareFilerun2 [open "log\\LSPBH_002_重启后在$matchType1\上Showrun.txt" w]
	puts $compareFilerun2 $contentrun2
	close $compareFilerun2
	# set showMpls 3
	# set showCfm 3
	# set showMlps 3
	# while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId result_mpls1]} {
	# 	incr showMpls -1
	# }
	# while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "cfm" result_cfm1]} {
	# 	incr showCfm -1
	# }
	# while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "mlps" result_mlps1]} {
	# 	incr showMlps -1
	# }
	# regexp {interface lsp tunnel Tunnel_101.*?exit} $result_mpls1 lsp101_tmp
	# regexp {interface lsp tunnel Tunnel_2101.*?exit} $result_mpls1 lsp2101_tmp
	# regexp {interface pw pw101.*?exit} $result_mpls1 pw101_tmp
	# regexp {interface ac ac101.*?exit} $result_mpls1 ac101_tmp
	# regexp {mpls-tp-meg meg1.*?exit} $result_cfm1 meg1_tmp
	# regexp {mpls-tp-meg meg2.*?exit} $result_cfm1 meg2_tmp
	# regexp {create pro-grp ac101.*?exit} $result_mlps1 pro-grp101_tmp
	# if {[string match $lsp101 $lsp101_tmp]} {
	# 	gwd::GWpublic_print "OK" "保存重启前后Tunnel_101的内容没有发生变化" $fileId
	# } else {
	# 	set flag1_Case6 1
	# 	gwd::GWpublic_print "NOK" "保存重启前后Tunnel_101的内容发生变化" $fileId
	# }
	# if {[string match $lsp2101 $lsp2101_tmp]} {
	# 	gwd::GWpublic_print "OK" "保存重启前后Tunnel_2101的内容没有发生变化" $fileId
	# } else {
	# 	set flag1_Case6 1
	# 	gwd::GWpublic_print "NOK" "保存重启前后Tunnel_2101的内容发生变化" $fileId
	# }
	# if {[string match $pw101 $pw101_tmp]} {
	# 	gwd::GWpublic_print "OK" "保存重启前后pw101的内容没有发生变化" $fileId
	# } else {
	# 	set flag1_Case6 1
	# 	gwd::GWpublic_print "NOK" "保存重启前后pw101的内容发生变化" $fileId
	# }
	# if {[string match $ac101 $ac101_tmp]} {
	# 	gwd::GWpublic_print "OK" "保存重启前后ac01的内容没有发生变化" $fileId
	# } else {
	# 	set flag1_Case6 1
	# 	gwd::GWpublic_print "NOK" "保存重启前后ac101的内容发生变化" $fileId
	# }
	# if {[string match $meg1 $meg1_tmp]} {
	# 	gwd::GWpublic_print "OK" "保存重启前后meg1的内容没有发生变化" $fileId
	# } else {
	# 	set flag1_Case6 1
	# 	gwd::GWpublic_print "NOK" "保存重启前后meg1的内容发生变化" $fileId
	# }
	# if {[string match $meg2 $meg2_tmp]} {
	# 	gwd::GWpublic_print "OK" "保存重启前后meg2的内容没有发生变化" $fileId
	# } else {
	# 	set flag1_Case6 1
	# 	gwd::GWpublic_print "NOK" "保存重启前后meg2的内容发生变化" $fileId
	# }






    if {"1" in $flag1_Case7} {
    	set flagCase7 1
    }
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase7] == 1)? "NOK":"OK"}] "Test Case 7 测试结论" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 7 主控/SW倒换对功能影响 测试结束\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"

    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fileId $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fileId $GPNTestEth2
} err]} {
	gwd::GWpublic_printAbnormal $fileId $fd_log 1 "FLAGE" $startSeconds "运行异常：错误为$err" "" "GPN_PTN_LSP_002"
}
close $fileId
log_file -noappend
close $fd_log

if {$flagResult == 1} {
	file rename "report\\GPN_PTN_002_2_REPORT.txt" "report\\NOK_GPN_PTN_LSP_002_REPORT.txt"
	file rename "log\\GPN_PTN_002_LOG.txt" "log\\NOK_GPN_PTN_LSP_002_LOG.txt"
} else {
	file rename "report\\GPN_PTN_002_2_REPORT.txt" "report\\OK_GPN_PTN_LSP_002_REPORT.txt"
	file rename "log\\GPN_PTN_002_LOG.txt" "log\\OK_GPN_PTN_LSP_002_LOG.txt"
}
if {[regexp {[^0\s]} $flagDel]} {
	exit 1
}