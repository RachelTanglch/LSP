#!/bin/sh
# T1_GPN_PTN_LSP_001.tcl \
exec tclsh "$0" ${1+"$@"}
#�������ƣ�ptn_lsp_001
#-----------------------------------------------------------------------------------------------------------------------------------
#����Ŀ�ģ�MPLS����
#1-LSPҵ�񴴽���
#2-LSP OAM������
#3-���Ա����鴴����
#4-���Ա�����Э��ʹ�����ã�
#5-���Ա�����ʹ������
#6-ɾ������
#-----------------------------------------------------------------------------------------------------------------------------------
#�����������Ͷ���������7600/SΪ����                                                                                                                             
#                                                                              
#                                    ___________                               
#                                   |   4GE/ge  |
#  _______                          |   8fx     |    
# |       |                         |           |
# |  PC   |_______Internet���� _____|           |
# |_______|                         |           |       
#    /__\                           |GPN(7600/S)|                  
#                                   |           |            
#                                   |___________|           
#                                          
#                                                                         
#                                                                                                                  
#---------------------------------------------------------------------------------------------------------------------------------
#�ű�����������
#1�����ղ������˴���Ի���:��GPN�Ĺ���˿ڣ�U/D����PC��������Internet������GPN��2��������
#   ��STC�˿ڣ� 9/9����9/10��
#2����GPN��������� ���ã���������vlan vid=4000���ڸ�vlan�����ù���IP����untagged��ʽ��ӹ���˿ڣ�U/D��
#-----------------------------------------------------------------------------------------------------------------------------------
#���Թ��̣�
#1���Test Case 1���Ի���
#   <1>����PW���ڵĶ˿�ΪNNI��
#   <2>����vlan������˿ں�Ip��������ͬ��VLANIF�ӿ�
#   <3>��������LSP������Ŀ�ĵ�ַ
#   <4>��������LSP��Ŀ�ĵ�ַ�͹���LSP�ĵ�ַһ�£�ȷ�����óɹ���
#   <5>���ù���LSP�ͱ���LSP������ͳ��ʹ�ܣ�����PW����ͳ��ʹ�ܣ�������̫������˿�����ͳ��ʹ�ܣ�ȷ�����óɹ�
#   <6>undo shutdown
#2���Test Case 2���Ի���
#   <1>ɾ�����Ա�����
#   <2>ɾ������LSP��MEP����
#   <3>ɾ������LSP��MEP����
#3���Test Case 3���Ի���
#   <1>��MEP����������Ա���ʹ��ʧ��
#   <2>��MEP����������Ա���ʹ�ܳɹ�
#4���Test Case 4���Ի���
#   <1>ɾ�����Ա����顢OAM���������ñ���LSP��Ŀ�ĵ�ַ�͹���LSP��ͬ
#   <2>�����������Ա����顢OAM
#   <3>���Ա�����ʹ�ܲ��ɹ�
#2���Test Case 5���Ի���   
#   <1>ɾ�����Ա�����
#   <2>ɾ������LSP
#   <3>ɾ������LSP
#   <4>�ָ���ʼ������
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
    chan configure $fd_log -blocking 0 -buffering none;#������ģʽ ����flush
    log_file log\\GPN_PTN_001_LOG.txt
    
    file mkdir "report"
    set fileId [open "report\\GPN_PTN_001_REPORT.txt" a+]
    chan configure $fileId -blocking 0 -buffering none;#������ģʽ ����flush
    
    file mkdir "debug"
    set fd_debug [open debug\\GPN_PTN_001_DEBUG.txt a]
    exp_internal -f debug\\GPN_PTN_001_DEBUG.txt 0
    chan configure $fd_debug -blocking 0 -buffering none;#������ģʽ ����flush

    source test\\LSP_VarSet.tcl
    source test\\LSP_Mode_Function.tcl

    set flagResult 0
    set flagCase1 0   ;#Test case 1��־λ 
    set flagCase2 0   ;#Test case 2��־λ
    set flagCase3 0   ;#Test case 3��־λ
    set flagCase4 0   ;#Test case 4��־λ
    set flagCase5 0   ;#Test case 5��־λ
    set cfgId 0
    set lFailFile ""
    set FLAGF 0
    #Ϊ���Խ���Ԥ������
    for {set i 0} {$i < 80} {incr i} {
	puts $fileId "                                                                                                                                                                                                                "     
    }

    puts $fileId "Log in to the device under test...\n"
    puts $fileId "\n=====��¼�����豸1====\n"
    set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "===MLPS���ÿ�ʼ...\n"
    set cfgFlag 0
    lassign $lDev1TestPort testPort1 testPort2 testPort3 testPort4 testPort5 testPort6
    foreach port $lDev1TestPort {
	if {[string match -nocase "L3" $Worklevel] && [string match -nocase "PTN" $SoftVer]} {
	lappend cfgFlag [gwd::GWL2_AddPort $telnet1 $matchType1 $Gpn_type1 $fileId $port "disable" "enable"]
	    }
	}
	###�˿�Ϊ������ӿ����ò���
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
    #���ڵ��������豸�õ��ı���------
    set lSpawn_id "$telnet1"
    set lMatchType "$matchType1"
    set lDutType "$Gpn_type1"
    set lIp "$gpnIp1"
    regexp -nocase {(\d+)} $interface1 match vid1
    regexp -nocase {(\d+)} $interface2 match vid2
    regexp -nocase {(\d+)} $interface3 match vid3
    #------���ڵ��������豸�õ��ı���
    gwd::GWpublic_printAbnormal $fileId $fd_log $cfgFlag "FLAGA" $startSeconds "MLPS����ʧ�ܣ����Խ���" \
    "MLPS���óɹ�����������Ĳ���" "GPN_PTN_LSP_001"
    puts $fileId ""
    puts $fileId "===MLPS���ý���..."
    incr cfgId
    ##  �ϴ��ļ�����
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
    set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    puts $fileId ""
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles  "$fd_debug $fd_log $fileId" "Test Case 1 OAM������LSP���Ա����鴴����Elineҵ�񴴽� ���Կ�ʼ\n"
    #   <1>����PW���ڵĶ˿�ΪNNI��
    #   <2>����vlan������˿ں�Ip��������ͬ��VLANIF�ӿ�
    #   <3>��������LSP������Ŀ�ĵ�ַ
    #   <4>��������LSP��Ŀ�ĵ�ַ�͹���LSP�ĵ�ַһ�£�ȷ�����óɹ���
    #   <5>���ù���LSP�ͱ���LSP������ͳ��ʹ�ܣ�����PW����ͳ��ʹ�ܣ�������̫������˿�����ͳ��ʹ�ܣ�ȷ�����óɹ�
    #   <6>����LSP��OAM�������ͱ���LSP�������ö�����MEP��MEP��RMEPID�໥����������3.3ms��ȷ�����óɹ�
    #   <7>�������Ա����飬�ȴ�ʱ��Ϊ1�����ù���·���ͱ���·����ȷ�����óɹ�
    
    set flag1_case1 0
    set flag2_case1 0
    set ip1 1.0.0.1 ;#vlanif10 ip
    set ip2 2.0.0.1;#vlanif20 ip

    set address 4.4.4.4 ; #Ŀ����Ԫ��ַ
    set address2 5.5.5.5; #��ͬ��Ŀ����Ԫ��ַ
    ###  ����pw���ڵĶ˿�Ϊnni��
    if {[string match "L2" $Worklevel]} {
	gwd::GWpublic_CfgVlanStack $telnet1 $matchType1 $Gpn_type1 $fileId $testPort1 "enable"  
	gwd::GWpublic_CfgVlanStack $telnet1 $matchType1 $Gpn_type1 $fileId $testPort2 "enable"  

    }
    ###  ΪNNI�˿����ò�ͬ��VLANIF�ӿ�-----
    PTN_NNI_AddInterIp $fileId $Worklevel $interface1 $ip1 $testPort1 $matchType1 $Gpn_type1 $telnet1
    puts $fileId "======================================================================================\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====��������LSP�ͱ���LSP��Ŀ�ĵ�ַ��ͬ������ͳ��ʹ�ܣ����ÿ�ʼ=====\n"
    ###  ��������LSP
    if {[gwd::GWStaLsp_AddLspName $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_101 1"] == 1} {
	gwd::GWpublic_print "OK" "��������LSP����Tunnel_101�����Ϊ1�������ɹ�" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "��������lspʱ����lsp����Tunnel_101�����Ϊ1������ʧ��" $fileId
    }
    ###  ����LSP��Ŀ�ĵ�ַ
    gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_101" $address
    ###  ������ȷ�Ľӿ�Vlan����һ��ip�����ǩ������ǩ��lspid�ܷ�ɹ�����lsp
    if {[gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_101" $interface1 $ip2 "101" "401" "normal" 101] == 0} {
	gwd::GWpublic_print "OK" "���ù���lsp��vlanif�ӿڣ����óɹ�" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "���ù���lsp��vlanif�ӿڣ�����ʧ��" $fileId
    }
    ###  ������ͬ��vlanif�ӿ�
    PTN_NNI_AddInterIp $fileId $Worklevel $interface2 $ip2 $testPort2 $matchType1 $Gpn_type1 $telnet1
    ###  ��������LSP
    if {[gwd::GWStaLsp_AddLspName $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_2101 2"] == 1} {
	gwd::GWpublic_print "OK" "��������LSP����Tunnel_2101�����Ϊ2�������ɹ�" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "��������LSP����Tunnel_2101�����Ϊ2������ʧ��" $fileId
    }

    ###  ���ú͹���LSPһ����Ŀ�ĵ�ַ
    gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" $address
    ###  ������ȷ�Ľӿ�Vlan����һ��ip�����ǩ������ǩ��lspid�ܷ�ɹ�����lsp
    if {[gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_2101" $interface2 $ip1 "2101" "2401" "normal" 2101] == 0} {
	gwd::GWpublic_print "OK" "���ñ���lsp��vlanif�ӿڣ����óɹ�" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "���ñ���lsp��vlanif�ӿڣ�����ʧ��" $fileId
    }
    gwd::GWpublic_addLspStat $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_101" "enable"
    if {[gwd::GWStaLsp_AddLspEn $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_101" "undo shutdown"] == 0} {
	gwd::GWpublic_print "OK" "����LSPʹ������ͳ�ƺ󼤻�LSP�����óɹ�" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "����LSPʹ������ͳ�ƺ󼤻�LSP������ʧ��" $fileId
	
    }
    gwd::GWpublic_addLspStat $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" "enable"
    if {[gwd::GWStaLsp_AddLspEn $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" "undo shutdown"] == 0} {
	gwd::GWpublic_print "OK" "����LSPʹ������ͳ�ƺ󼤻�LSP�����óɹ�" $fileId
    } else {
	set flag1_case1 1
	gwd::GWpublic_print "NOK" "����LSPʹ������ͳ�ƺ󼤻�LSP������ʧ��" $fileId
    }
    puts $fileId ""
    if {$flag1_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA1�����ۣ���������LSP�ͱ���LSP��Ŀ�ĵ�ַ��ͬ������ͳ��ʹ�ܣ�����ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA1�����ۣ���������LSP�ͱ���LSP��Ŀ�ĵ�ַ��ͬ������ͳ��ʹ�ܣ������ɹ�" $fileId
    }
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====��������LSP�ͱ���LSP��Ŀ�ĵ�ַ��ͬ������ͳ��ʹ�ܣ����ý���=====\n"
    
    puts $fileId "======================================================================================\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====����PW����ͳ��ʹ�ܣ�������̫������˿�����ͳ��ʹ�ܣ�ȷ�����óɹ�  ���Կ�ʼ=====\n"
    
    ###  PTNҵ��UNI�����vlan
    PTN_UNI_AddInter $telnet1 $matchType1 $Gpn_type1 $fileId $Worklevel $vid3 $testPort2
    gwd::GWStaPw_AddPwName $telnet1 $matchType1 $Gpn_type1 $fd_log "pw101"
    if {[gwd::GWpublic_CfgPw $telnet1 $matchType1 $Gpn_type1 $fileId "pw101" "l2transport" "1" "" $address "1401" "1101" "101" "nochange" "" "1" "0" "0x8100" "0x8100" ""]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "������ȷ�ľ�̬�����������pw������ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "������ȷ�ľ�̬�����������pw�����óɹ�" $fileId
    }
    if {[gwd::GWpublic_addPwStatEn $telnet1 $matchType1 $Gpn_type1 $fileId "pw101" "enable"]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "ʹ��PW����ͳ�ƣ�����ʧ��" $fileId   
    } else {
	gwd::GWpublic_print "OK" "ʹ��PW����ͳ�ƣ����óɹ�" $fileId    
    }
    gwd::GWAc_AddName $telnet1 $matchType1 $Gpn_type1 $fd_log "ac101 1"
    if {[gwd::GWAc_AddInfo $telnet1 $matchType1 $Gpn_type1 $fd_log "ac101" "" $testPort2  101 0 "nochange" 101 0 0 "0x8100"] == 0} {
	gwd::GWpublic_print "OK" "����ac�󶨶˿ڣ����óɹ�" $fileId  
    } else {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "����ac�󶨶˿ڣ�����ʧ��" $fileId
    }
    if {[gwd::GWpublic_CfgAcBind $telnet1 $matchType1 $Gpn_type1 $fileId "ac101" "pw101" "eline"]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "ac��pw�Ĳ�������ȷ����ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "ac��pw�Ĳ�������ȷ���󶨳ɹ�" $fileId    
    }
    if {[gwd::GWpublic_addAcStatEn $telnet1 $matchType1 $Gpn_type1 $fileId "ac101" "enable"]} {
	set flag2_case1 1
	gwd::GWpublic_print "NOK" "ʹ��ac����ͳ�ƣ�����ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "ʹ��ac����ͳ�ƣ����óɹ�" $fileId    
    }
    puts $fileId ""
    if {$flag2_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA2�����ۣ�����PW����ͳ��ʹ�ܣ�������̫������˿�����ͳ��ʹ�ܣ�ȷ������ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA2�����ۣ�����PW����ͳ��ʹ�ܣ�������̫������˿�����ͳ��ʹ�ܣ�ȷ�����óɹ�" $fileId
    }
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====����PW����ͳ��ʹ�ܣ�������̫������˿�����ͳ��ʹ�ܣ�ȷ�����óɹ�  ���Խ���=====\n"
    
    set flag3_case1 0 ;
    puts $fileId "======================================================================================\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====����LSP��OAM�����ÿ�ʼ=====\n"
    gwd::GWpublic_createMplsMeg $telnet1 $matchType1 $Gpn_type1 $fileId "meg101"
	if {[gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "lsp" "Tunnel_2101" "401" "101"] == 0} {
	    gwd::GWpublic_print "OK" "����LSP���ö�����MEP��MEP��LMEPID�໥���������óɹ�" $fileId
	} else {
	    set flag3_case1 1
	    gwd::GWpublic_print "NOK" "����LSP���ö�����MEP��MEP��LMEPID�໥����������ʧ��" $fileId
	}
    gwd::GWpublic_createMplsMeg $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101"
    if {[gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "lsp" "Tunnel_101" "2401" "2101"] == 0} {
	gwd::GWpublic_print "OK" "����LSP���ö�����MEP��MEP��LMEPID�໥���������óɹ�" $fileId
    } else {
	set flag3_case1 1
	gwd::GWpublic_print "NOK" "����LSP���ö�����MEP��MEP��LMEPID�໥����������ʧ��" $fileId
    }
    if {[gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "3ms"]} {
	set flag3_case1 1
	gwd::GWpublic_print "NOK" "���ñ���LSP��CC���3ms������ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "���ñ���LSP��CC���3ms�����óɹ�" $fileId    
    }
    if {[gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "3ms"]} {
	set flag3_case1 1
	gwd::GWpublic_print "NOK" "���ù���LSP��CC���3ms������ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "���ù���LSP��CC���3ms�����óɹ�" $fileId    
    }
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "enable"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "enable"
    puts $fileId ""
    if {$flag3_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA3�����ۣ�����LSP��OAM��ȷ������ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA3�����ۣ�����LSP��OAM��ȷ�����óɹ�" $fileId
    }
    puts $fileId ""
    set flag4_case1 0
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====����LSP��OAM�����Խ���=====\n"
 
    puts $fileId "======================================================================================\n"

    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====����LSP���Ա����飬���ÿ�ʼ=====\n"
    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 1} {
	set flag4_case1 1
    }
    puts $fileId ""
    if {$flag4_case1 == 1} {
	set flagCase1 1
	gwd::GWpublic_print "NOK" "FA4�����ۣ�����LSP���Ա����飬ȷ������ʧ��" $fileId
    } else {
	gwd::GWpublic_print "OK" "FA4�����ۣ�����LSP���Ա����飬ȷ�����óɹ�" $fileId
    }
    puts $fileId ""
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_001" lFailFileTmp]
    if {$lFailFileTmp != ""} {
	set lFailFile [concat $lFailFile $lFailFileTmp]
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====����LSP���Ա����飬���Խ���=====\n"
    if {$flagCase1 == 1} {
	gwd::GWpublic_print "NOK" "Test Case 1���Խ���" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 1���Խ���" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 1 OAM������LSP���Ա����鴴����Elineҵ�񴴽� ���Խ���\n"
    puts $fileId ""
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 2 ɾ�����Ա����顢ɾ�������ͱ���LSP��MEP���� ���Կ�ʼ\n"
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
	gwd::GWpublic_print "NOK" "TestCase 2���Խ���" $fileId
	} else {
	gwd::GWpublic_print "OK" "TestCase 2���Խ���" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 2 ɾ�����Ա����顢ɾ�������ͱ���LSP��MEP���� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 3 ����MEP�����Ա�����ʹ�� ���Կ�ʼ\n"
    set flag1_case3 0 ;#Test Case 3 ��־λ
    set flag2_case3 0 ;
    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 0} {
	set flag1_case3 1
	gwd::GWpublic_print "NOK" "�����ͱ���LSP��MEP�����Ա�����ʹ�����óɹ�" $fileId
    } else {
	
	gwd::GWpublic_print "OK" "�����ͱ���LSP��MEP�����Ա�����ʹ������ʧ��" $fileId
    }
    ### �������ù����ͱ���LSP��MEP
    gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "lsp" "Tunnel_2101" "401" "101"
    gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "lsp" "Tunnel_101" "2401" "2101"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "enable"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg2101" "enable"
    gwd::GWpublic_DelMlpsPro $fileId $Gpn_type1 $telnet1 "ac101" "disable"
    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 1} {
	set flag2_case3 1
	gwd::GWpublic_print "NOK" "�����ͱ���LSP��MEP�����Ա�����ʹ������ʧ��" $fileId

    } else {
	gwd::GWpublic_print "OK" "�����ͱ���LSP��MEP�����Ա�����ʹ�����óɹ�" $fileId
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
	gwd::GWpublic_print "NOK" "Test Case 3���Խ���" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 3���Խ���" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 3 ����MEP�����Ա�����ʹ��  ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 4 ����LSP�͹���LSPĿ�ĵ�ַ��ͬ�����Ա�����ʹ�� ���Կ�ʼ\n"
    set flag1_case4 0 ;#Test Case 4 ��־λ
    ### ɾ�����������ñ���LSP��MEP������LSP��Ŀ�ĵ�ַ�͹���LSP�Ĳ�ͬ
    gwd::GWpublic_DelMlpsPro $fileId $Gpn_type1 $telnet1 "ac101" "disable" 
    gwd::GPN_DelMplsMeg "GPN_PTN_LSP_001" $fileId "meg101" $telnet1 $Gpn_type1
    gwd::GWStaLsp_DelLspName $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101"
    gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" $address2
    gwd::GWpublic_CfgLspTunnel $telnet1 $matchType1 $Gpn_type1 $fd_log "Tunnel_2101" $interface2 $ip1 "2101" "2401" "normal" 2101
    gwd::GWpublic_addMplsOam $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "lsp" "Tunnel_2101" "401" "101"

    gwd::GWpublic_addMplsCcInt $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "3ms"
    gwd::GWpublic_addMplsCc $telnet1 $matchType1 $Gpn_type1 $fileId "meg101" "enable"

    if {[gwd::GWpublic_CfgMlpsProW $fileId $Gpn_type1 $telnet1 "ac101" "Tunnel_101" "Tunnel_2101" "1" "enable"] == 1} {
	gwd::GWpublic_print "OK" "�����ͱ���LSPĿ�ĵ�ַ��ͬ�����Ա�����ʹ������ʧ��" $fileId
    } else {
	set flag1_case4 1
	gwd::GWpublic_print "NOK" "�����ͱ���LSPĿ�ĵ�ַ��ͬ�����Ա�����ʹ�����óɹ�" $fileId
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
	gwd::GWpublic_print "NOK" "Test Case 4���Խ���" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 4���Խ���" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 4 ����LSP�͹���LSPĿ�ĵ�ַ��ͬ�����Ա�����ʹ��  ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 5 ɾ�����Ա������ɾ������LSP������LSP�����ɹ� ���Կ�ʼ\n"
    set flag1_case5 0
    set flag2_case5 0
    ### ɾ��elineҵ��
    lappend flagDel [gwd::GWAc_DelActPw $telnet1 $matchType1 $Gpn_type1 $fileId "ac101"]
    lappend flagDel [gwd::GWAc_DelName $telnet1 $matchType1 $Gpn_type1 $fileId "ac101"]
    #lappend flagDel [gwd::GWpublic_delPwStaticPara $telnet1 $matchType1 $Gpn_type1 $fileId "pw101"]
    lappend flagDel [gwd::GWpublic_delPw "GPN_PTN_LSP_001" $fileId "pw101" $telnet1 $matchType1]
    ### ������LSPĿ�ĵ�ַ��Ϊ�͹���LSPĿ�ĵ�ַ��ͬ
    lappend flagDel [gwd::GWpublic_CfgLspAddress $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101" $address]
    lappend flagDel [gwd::GWpublic_CfgUndoShutLsp $telnet1 $matchType1 $Gpn_type1 $fileId "Tunnel_2101"]
    if {[gwd::GWpublic_DelMlpsPro $fileId $Gpn_type1 $telnet1 "ac101" "disable"] == 1} {
	    set flag1_case5 1
	    gwd::GWpublic_print "NOK" "ɾ�����Ա�����ʧ��" $fileId
	} else {
	    gwd::GWpublic_print "OK" "ɾ�����Ա�����ɹ�" $fileId
	}
    if {[gwd::GPN_DelLsp "GPN_PTN_LSP_001" $fileId "Tunnel_2101" $telnet1 $Gpn_type1] == 1} {
	    set flag2_case5 1
	    gwd::GWpublic_print "NOK" "ɾ������LSPʧ��" $fileId
	} else {
	    gwd::GWpublic_print "OK" "ɾ������LSP�ɹ�" $fileId
	}
    if {[gwd::GPN_DelLsp "GPN_PTN_LSP_001" $fileId "Tunnel_101" $telnet1 $Gpn_type1] == 1} {
	    set flag2_case5 1
	    gwd::GWpublic_print "NOK" "ɾ������LSPʧ��" $fileId
	} else {
	    gwd::GWpublic_print "OK" "ɾ������LSP�ɹ�" $fileId
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
	gwd::GWpublic_print "NOK" "Test Case 5���Խ���" $fileId
	} else {
	gwd::GWpublic_print "OK" "Test Case 5���Խ���" $fileId
	}
    puts $fileId ""
    puts $fileId "Test Case 5 ɾ�����Ա������ɾ������LSP������LSP�����ɹ� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "===�ָ���ʼ������...\n"
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
    #�޸ı�ǩ��Χ�豣���������޸Ĳ���Ч
    gwd::GWpublic_SaveCfg $telnet1 $matchType1 $Gpn_type1 $fileId
    gwd::GWpublic_Reboot $telnet1 $matchType1 $Gpn_type1 $fileId
    after $rebootTime
    set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
    set lSpawn_id [lreplace $lSpawn_id 0 0 $telnet1]
    gwd::GWpublic_printAbnormal $fileId $fd_log $flagDel "FLAGD" $startSeconds "���Խ��������ûָ�" "���Խ��������ûָ�" "GPN_PTN_LSP_001"
    gwd::GWpublic_printAbnormal $fileId $fd_log $FLAGF "FLAGF" $startSeconds $lFailFile "���Թ��������������ļ����ϴ��ɹ�" "GPN_PTN_LSP_001"
    
    chan seek $fileId 0
    puts $fileId "\n**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "GPN_PTN_LSP_001����Ŀ�ģ�MLPS����\n"
    gwd::GWpublic_printCompletedRunTime $fileId $startSeconds

    if {$flagCase1 == 1 ||$flagCase2 == 1 || $flagCase3 == 1 || $flagCase4 == 1 || $flagCase5 == 1 || [regexp {[^0\s]} $flagDel]} {
    set flagResult 1
    }
    gwd::GWpublic_print [expr {($flagResult == 1) ? "NOK" : "OK"}] "GPN_PTN_LSP_001���Խ��" $fileId
    puts $fileId ""
    gwd::GWpublic_print [expr {($flagCase1 == 0) ? "OK" : "NOK"}] "Test Case 1 ���Խ��" $fileId
    gwd::GWpublic_print [expr {($flagCase2 == 0) ? "OK" : "NOK"}] "Test Case 2���Խ��" $fileId
    gwd::GWpublic_print [expr {($flagCase3 == 0) ? "OK" : "NOK"}] "Test Case 3���Խ��" $fileId
    gwd::GWpublic_print [expr {($flagCase4 == 0) ? "OK" : "NOK"}] "Test Case 4���Խ��" $fileId
    gwd::GWpublic_print [expr {($flagCase5 == 0) ? "OK" : "NOK"}] "Test Case 5���Խ��" $fileId
    puts $fileId ""
    gwd::GWpublic_print "== FA1 == [expr {($flag1_case1 == 1) ? "NOK" : "OK"}]" "�����ۣ���������LSP�ͱ���LSP[expr {($flag1_case1 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FA2 == [expr {($flag2_case1 == 1) ? "NOK" : "OK"}]" "�����ۣ�����PW����ͳ��ʹ�ܣ�������̫������˿�����ͳ��ʹ�ܣ�ȷ������[expr {($flag2_case1 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FA3 == [expr {($flag3_case1 == 1) ? "NOK" : "OK"}]" "�����ۣ�����LSP��OAM[expr {($flag3_case1 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FA4 == [expr {($flag4_case1 == 1) ? "NOK" : "OK"}]" "�����ۣ�����LSP���Ա�����[expr {($flag4_case1 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FC1 == [expr {($flag1_case3 == 1) ? "NOK" : "OK"}]" "�����ۣ������ͱ���LSP��MEP�����Ա�����ʹ������ʧЧ[expr {($flag1_case3 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FC2 == [expr {($flag2_case3 == 1) ? "NOK" : "OK"}]" "�����ۣ������ͱ���LSP��MEP�����Ա�����ʹ��������Ч[expr {($flag2_case3 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FD1 == [expr {($flag1_case4 == 1) ? "NOK" : "OK"}]" "�����ۣ������ͱ���LSPĿ�ĵ�ַ��ͬ�����Ա�����ʹ������ʧ��[expr {($flag1_case4 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FE1 == [expr {($flag1_case5 == 1) ? "NOK" : "OK"}]" "�����ۣ�ɾ�����Ա�����[expr {($flag1_case5 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
    gwd::GWpublic_print "== FE2 == [expr {($flag2_case5 == 1) ? "NOK" : "OK"}]" "�����ۣ�ɾ��LSP[expr {($flag2_case5 == 1) ? "ʧ��" : "�ɹ�"}]" $fileId
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
