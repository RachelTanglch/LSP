#!/bin/sh
# LSP_Mode_Function.tcl \
exec tclsh "$0" ${1+"$@"}

########################################################################################################
	#�������ܣ����Ա����д�ӡ���쳣���
	#���������saveflag��=1��Ҫ�������ò���ӡ������Ϣ  =0����Ҫ����ֻ��Ҫ��ӡ������Ϣ 
	#	  lSpawn_id���豸spawn_id���б�
	#         lMatchType��ƥ�������нڵ����ַ����б�
	#         lDutType���豸�����б�
	#         fileId�������ļ�������
	#	  fd_log������log���ļ�������
	#	  startSeconds���ű���ʼ���е�ʱ�䣬��λs
	#         lIp���豸ip�б�
	#         cfgKey���ϴ��������ļ������������������ֹÿ���ϴ��ļ�����ǰ���ϴ����ļ���
	#         testFile�����Ա�������֣�������_report  _log�ֶΣ�
	#�������  ��lFailFile���ϴ�ʧ�ܵ��ļ������б�
	#����ֵ��  flagErr���ϴ��Ƿ�ɹ��ı�־   [regexp {[^0\s]} $flagErr]==1 ʧ��    =0�ɹ�
	#���ߣ��˾�
########################################################################################################
	proc GWpublic_uploadDevCfg {saveflag lSpawn_id lMatchType lDutType fileId fd_log startSeconds lIp ftp cfgKey testFile lFailFile} {
		upvar $lFailFile lFileTmp
		set lFileTmp ""
		set flagErr 0
		puts $fileId ""
		puts $fileId "===�豸���õ�����ʼ...\n"
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
#        			gwd::GWpublic_printAbnormal $fileId $fd_log $uploadFlag "FLAGF" $startSeconds "��$matchType\�ϵ��������ļ�$testFile\_$cfgKey\_$ip.txt��ftp���������Ŀ¼ʧ��" \
#        				"��$matchType\�ϵ��������ļ���ftp���������Ŀ¼�ɹ�" $testFile
			}
		} else {
			set flagErr [lrepeat [expr [llength $lSpawn_id]+1] 0]
		}
		foreach ip $lIp flag [lrange $flagErr 1 end] {
			if {$saveflag == 1} {
				if {$flag == 0} {
					gwd::GWpublic_print "OK" "ip=$ip\�������ļ��ϴ��ɹ����ļ�����Ϊ$testFile\_$cfgKey\_$ip.txt" $fileId
				} else {
					gwd::GWpublic_print "NOK" "ip=$ip\�������ļ��ϴ�ʧ�ܣ��ļ�����Ϊ$testFile\_$cfgKey\_$ip.txt" $fileId
				}
				
			} else {
				puts $fileId "�ļ�����Ϊ$testFile\_$cfgKey\_$ip.txt"
			}
		}
		puts $fileId ""
		puts $fileId "===�豸���õ�������...\n"
		return [regexp {[^0\s]} $flagErr]
	}
########################################################################################################
	#�������ܣ����Ա����д�ӡ���쳣���
	#��������� fileId�����Ա�����ļ�������
	#	  fd_log������log���ļ�������
	#         flagErr�����Խ��
	#         flagType����Ӧ�Ĵ�������
	#	  startSeconds���ű���ʼ���е�ʱ�䣬��λs
	#         printWord1�����Խ�������ӡ���ַ���(���flagType=FLAGF �˱���Ϊ�ϴ�ʧ�ܵ������ļ������б�)
	#         printWord2�����Խ����ȷ��ӡ���ַ���
	#         fileName�����Ա�������֣�������_report  _log�ֶΣ�
	#�������  ����
	#����ֵ��  ��
	#���ߣ��˾�
	########################################################################################################
proc GWpublic_printAbnormal {fileId fd_log flagErr flagType startSeconds printWord1 printWord2 fileName} {
		if {[regexp {[^0\s]} $flagErr]} {
			if {[string match "FLAGF" $flagType]} {
				gwd::GWpublic_print "== FLAGF == NOK" "�����ۣ����Թ����������ļ��ϴ�" $fileId
				puts $fileId "�ϴ�ʧ�ܵ������ļ��У�" 
				foreach f $printWord1 {
					puts $fileId "		$f"
				}
			} else {
				gwd::GWpublic_print "NOK" "== $flagType ==�����ۣ�$printWord1" $fileId
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
					puts $fileId "�ű���ʼ����ʱ��Ϊ$startTime"
					puts $fileId "�ű����н���ʱ��Ϊ$endTime"
					puts $fileId "����ʱ��Ϊ��[expr [expr $endSeconds-$startSeconds]/60] ����"
					puts $fileId ""
					if {[string match "FLAGE" $flagType]} {
						puts $fileId "== FLAGE ==�����쳣������Ϊ$printWord1"
					} else {
						gwd::GWpublic_print "NOK" "== $flagType ==�����ۣ�$printWord1" $fileId
					}
					puts $fileId ""	
					puts $fileId "===����δ���......"
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
			gwd::GWpublic_print "OK" "== $flagType ==�����ۣ�$printWord2" $fileId
			return 0
		}
	}

########################################################################################################
#�������ܣ���ѯvpls����
#�������: fileId:���Ա�����ļ�id
#         type:ac/pw
#     typename:ac/pw����
#     vplsname:vpls����
#     GPN_type:�豸����
#       GPN_Id:spawn id
#�����������
#����ֵ�� tableList��vpls�����б�
#���ߣ������
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
  puts -nonewline $fileId [format "%-59s" "��GPN�ϲ�ѯvpls����"]
  if {$flagErr} {
    puts $fileId "NOK"   
  } else {
    puts $fileId "OK" 
  }
  return $tableList
}

########################################################################################################
#�������ܣ�GPN�ϱ��Ĺ��˲���
#�������: RunFlag ���������־λ
#���������flag:����ת������жϱ�־λ
#����ֵ�� ��
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
puts $::fileId "NE4����δ֪�������㲥���鲥��ȡ���鲥/�㲥���Ʒ�����֤ҵ��ת���쳣"
} elseif {$RunFlag==2} {
puts $::fileId "NE4����δ֪�������㲥���鲥��ʹ���鲥/�㲥���Ʒ�����֤ҵ��ת������"
} elseif {$RunFlag==3} {
set aTempFlag 1
puts $::fileId "NE4����δ֪�������㲥���鲥��ȡ���鲥/�㲥���Ʒ�����֤ҵ��ָ��쳣"
} 
puts $::fileId "NE1�豸�յ�NE4��δ֪�������㲥���鲥�ֱ�Ϊ��$GPNPort1Cnt1(cnt44) bps $GPNPort1Cnt1(cnt10) bps $GPNPort1Cnt1(cnt11) bps"
puts $::fileId "NE2�豸�յ�NE4��δ֪�������㲥���鲥�ֱ�Ϊ��$GPNPort2Cnt1(cnt44) bps $GPNPort2Cnt1(cnt10) bps $GPNPort2Cnt1(cnt11) bps"
puts $::fileId "NE3�豸�յ�NE4��δ֪�������㲥���鲥�ֱ�Ϊ��$GPNPort3Cnt1(cnt44) bps $GPNPort3Cnt1(cnt10) bps $GPNPort3Cnt1(cnt11) bps"
 }
}
########################################################################################################
#�������ܣ�GPN�ϱ��Ĺ��˲���
#�������: RunFlag ���������־λ
#���������flag:����ת������жϱ�־λ
#����ֵ�� ��
#���ߣ������
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
puts $::fileId "NE1����δ֪�������㲥���鲥��ȡ���鲥/�㲥���Ʒ�����֤ҵ��ת���쳣"
} elseif {$RunFlag==2} {
puts $::fileId "NE1����δ֪�������㲥���鲥��ʹ���鲥/�㲥���Ʒ�����֤ҵ��ת���쳣"
} elseif {$RunFlag==3} {
puts $::fileId "NE1����δ֪�������㲥���鲥��ȡ���鲥/�㲥���Ʒ�����֤ҵ��ָ��쳣"
} 
puts $::fileId "���Ʋ���Ч��NE4�豸�յ�NE1��δ֪�������㲥���鲥�ֱ�Ϊ��$GPNPort4Cnt1(cnt13) bps $GPNPort4Cnt1(cnt10) bps $GPNPort4Cnt1(cnt11) bps"
puts $::fileId "���Ʋ���Ч��NE2�豸�յ�NE1��δ֪�������㲥���鲥�ֱ�Ϊ��$GPNPort2Cnt1(cnt13) bps $GPNPort2Cnt1(cnt10) bps $GPNPort2Cnt1(cnt11) bps"
puts $::fileId "���Ʋ���Ч��NE3�豸�յ�NE1��δ֪�������㲥���鲥�ֱ�Ϊ��$GPNPort3Cnt1(cnt13) bps $GPNPort3Cnt1(cnt10) bps $GPNPort3Cnt1(cnt11) bps"
 }
}

#########################################################################################################
#�������ܣ���¼�豸����
#���������comPort�����ں� eg:com1-COM1
#�����������
#����ֵ�� ��
#���ߣ������
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
#�������ܣ�����豸���ú󴮿ڵ�¼����
#���������case�����Խű����
#         Gpn_type���豸�ͺ�
#           telnet���豸telent id
#          comPort�����ں� eg:com1-COM1
#         portList���豸���õ��Ķ˿��б�
#            GpnIp���豸�ĵ�¼ip
#       managePort���豸�Ĺ����
#�����������
#����ֵ�� ��
#���ߣ������
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
#�������ܣ�ptnҵ��nni�����vlan��ip
#�������:      case:�����������
#       Worklevel:L2/L3��ģʽ
#       interface:L2/L3��ӿ�
#              ip:ip������
#         GPNPort:NNI�ӿ�
#       matchType:ƥ�������нڵ����ַ���
#        Gpn_type:�豸����
#          telnet:spwan_id��
#���������  ��
#����ֵ�� ��
#���ߣ������
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
#�������ܣ�ptnҵ��uni�����vlan
#�������:      case:�����������
#       Worklevel:L2/L3��ģʽ
#             vid:vlan id��
#      GPNTestEth:����ac�Ķ˿�
#       matchType:ƥ�������нڵ����ַ���
#        Gpn_type:�豸����
#          telnet:spwan_id��
#���������  ��
#����ֵ�� flagErr
#���ߣ������
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
#�������ܣ�ptnҵ���ӽӿ�vlan��Ӿ�̬arp
#�������:      case:�����������
#       Worklevel:L2/L3��ģʽ
#       interface:L2/L3��ӿ�
#              ip:arp������
#              ip:mac������
#         GPNPort:NNI�ӿ�
#       matchType:ƥ�������нڵ����ַ���
#        Gpn_type:�豸����
#          telnet:spwan_id��
#���������  ��
#����ֵ�� FlagErr
#���ߣ������
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
#�������ܣ�GPN������ĳ���ӽӿڵİ�arp��mac
#�������:  spawn_id:TELNET����
#       matchType:ƥ�������нڵ����ַ���
#	  dutType:�豸���͡�
#	   fileId:����������ļ���ʶ��
#           inter���ӽӿں�
#             arp����ARP��ַ
#             mac����MAC��ַ
#�����������
#����ֵ�� flagErr  =0����ӳɹ�       =1�����ʧ��            =2��ip��ַ��Ӵﵽ���ֵ���޷��������  =3�����ܰ󶨹㲥ip  =4���ܰ��鲥ip
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
  gwd::GWpublic_print [expr {($flagErr == 0) ? "OK" : "NOK"}] "���ӽӿ�$inter\�а�ip:$arp\�Ұ�mac:$mac" $fileId
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
				gwd::GWpublic_print NOK "$matchType\��vlan$vid����Ӷ˿ڣ�ʧ�ܡ������������" $fileId
				      send -i $spawn_id "\r"
			      }
			      -re {untagged in another non-default VLAN} {
				  set errorTmp 1
				gwd::GWpublic_print NOK "$matchType\��vlan$vid����Ӷ˿ڣ�ʧ�ܡ��˿���untag��ʽ�����˷�default vlan" $fileId
				  send -i $spawn_id "\r"
			      }
			      -re {Layer 2 forwarding has been disabled on this port} {
				  set errorTmp 1
				gwd::GWpublic_print NOK "$matchType\��vlan$vid����Ӷ˿ڣ�ʧ�ܡ��˿ڵĶ���ת������û��ʹ��" $fileId    
			      }
			      -re "$matchType\\(vlan.*\\)#" {
				  send -i $spawn_id "\r"
				gwd::GWpublic_print OK "$matchType\��vlan$vid����Ӷ˿ڣ��ɹ�" $fileId    
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
			    gwd::GWpublic_print NOK "$matchType\����vlan$vid\��ipΪ$ip��ʧ�ܡ������������" $fileId
			    send -i $spawn_id "exit\r"
			}
			-re {Connot set ip address} {
			    set errorTmp 1
			    gwd::GWpublic_print NOK "$matchType\����vlan$vid\��ipΪ$ip��ʧ�ܡ���֧��ip��ַ����" $fileId
			    send -i $spawn_id "exit\r"
			}
			-re "$matchType\\(vlan.*\\)#" {
			    gwd::GWpublic_print OK "$matchType\����vlan$vid\��ipΪ$ip���ɹ�" $fileId
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
#�������ܣ���ѯvpls����
#�������: fileId:���Ա�����ļ�id
#         tableList:ʵ�ʲ�ѯ����ת�����ֵ� ��ʽ��mac1 "name1" mac2 "name2"
#     expectTable:���������б� mac1 name1 mac2 name2 mac3 name3 mac4 name4
#     vplsname:vpls����
#     printWord:��ӡ�����˵���ַ���
#       spawn_id:spawn id
#�����������
#����ֵ�� tableList��vpls�����б�
########################################################################################################

proc TestVplsForwardEntry {fileId printWord dTable expectTable} {
	set flag 0
	foreach {mac name} $expectTable {
		if {[dict exists $dTable $mac]} {
			if {[string match -nocase $name [dict get $dTable $mac portname]]} {
				gwd::GWpublic_print "OK" "$printWord\mac��ַ$mac\ѧϰ����$name��" $fileId
			} else {
				set flag 1
				gwd::GWpublic_print "NOK" "$printWord\mac��ַ$mac\ѧϰ����[dict get $dTable $mac portname]��" $fileId
			}
		} else {
			set flag 1
			gwd::GWpublic_print "NOK" "$printWord\û��mac=$mac\��ת������" $fileId
		}
	}
	return $flag
}


########################################################################################################
#�������ܣ�ɾ��meg��me  ����ɾ��meg�Ĳ��ֽ����޸ĵõ�
#���������testCase�������������
#	    fileId�����Ա�����ļ�id
#	      name��meg��
#            GPN_Id��spwan ID��
#          GPN_type��GPN������
#�����������
#����ֵ��  ��
#���ߣ������(�������޸�)
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
  gwd::GWpublic_print [expr {($flagErr == 0) ? "OK" : "NOK"}] "$GPN_type\��ɾ��$name\��me" $fileId
  
}
########################################################################################################
#�������ܣ�����������(32λ)
#���������
#�����������
#����ֵ��  ��
#���ߣ�������(20180807)
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
#�������ܣ�����������(16λ)
#���������
#�����������
#����ֵ��  ��
#���ߣ�������(20180807)
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
#�������ܣ�����������
#���������
#�����������
#����ֵ��  ��
#���ߣ�������(20180807)
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
#�������ܣ����ݷ�����������ͳ�Ƹ��������շ�����������豸����APS���Ľ���ͳ�ƣ�
#���������            
#                   hAna���˿ڷ�����handle
#               apsvalue��APS�����ֶ�Ԥ�ڵ���Ϣ
#����ֵ����
#���������
#	         aRecCnt��ͳ�ƽ��
#�������ƶ�PWBH��PWBH_ClassStatisticsPortRxCnt3����
########################################################################################################
	proc LSP_ClassStatisticsPortRxCnt3 {hAna apsvalue RecCnt} {
		upvar $RecCnt TmpCnt
#		ͬ���������ͷ�����ͳ����ʱ2s  
		after 5000
		send_log "\n children:[stc::get $hAna -children-FilteredStreamResults]\n"
		set i 1
		foreach resultsObj [stc::get $hAna -children-FilteredStreamResults] {
			send_log "\n��$i�ν���FOREACH��\n"
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
#�������ܣ��ڽ��ն�ʹ��ץ����������ץȡ���յ����ݰ�
#���������       capArr:      ץ��ƥ�����������Ԫ��˵�����£�
#           capMode��             ץ��ģʽ
#         capSource��             ץ��Դ
#        captureObj��             capture����ָ��
#�����������
#����ֵ��    ��
########################################################################################################
	proc GWpublic_StartCapAllData1 {capArr captureObj} {
		upvar $capArr proCapArr
		set capCount  0  
		stc::config $captureObj -mode $proCapArr(capMode) -srcMode $proCapArr(capSource)
		stc::apply
		stc::perform CaptureStart -captureProxyId $captureObj
	 }
########################################################################################################
#�������ܣ�ֹͣץ��
#���������captureObj��capture����ָ��
#         saveFlag���Ƿ񱣴�ץ�����ݰ�=1�����棬  =0������
#         capFile�� ץ���İ���ŵ��ļ���
#�����������
#����ֵ��    capCount��ץ������
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
#�������ܣ���Ԥ���յ����Ľ�������ͳ�ƣ�����APS���ģ�
#���������            
#                 		waitetime��ץ���ȴ�ʱ��:�豸1Զ��BFD�Ự״̬
#                    	caseId���˿�ץ���ļ����
#               		apsvalue��APS�����ֶ�Ԥ�ڵ���Ϣ
#						pcapNum:��Ҫ���ɵ�pcap���
#����ֵ����
#���������
#	aGPNPort1Cnt1���˿�1�յ�APS����ͳ��ֵ
#	aGPNPort2Cnt1���˿�2�յ�APS����ͳ��ֵ
#���ߣ�����������PWBH�е�PWBH_ApsCaptureStatistics����
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
#�������ܣ���Ԥ���յ����Ľ���ȷ�ϣ�APS���ģ�
#���������            
#                 waitetime��ץ���ȴ�ʱ��:�豸1Զ��BFD�Ự״̬
#                    caseId���˿�ץ���ļ����
#             a16BitFilCfg0�������Զ���16λ��������������EndOfRange��FilterName����Ϣ��
#                    Value1��Ԥ���յ�APS���ĵ���СFrameRate
#                  apsvalue��APS�����ֶ�Ԥ�ڵ���Ϣ
#					pcapNum: pcap�ı��ֵ
#				 GPNPortNum: �豸���
#����ֵ��0�������յ�BFD���ķ���Ԥ��Ҫ��1�������յ�BFD���Ĳ�����Ԥ��Ҫ��
#�����������
#����������PWBH�е�PWBH_ApsMessageConfirm
########################################################################################################
	proc LSP_ApsMessageConfirm {waitetime caseId Value1 apsvalue1 apsvalue2} {
		set errorTmp 0
		LSP_ApsCaptureStatistics $waitetime $caseId $apsvalue1 $apsvalue2 ApsCnt1 ApsCnt2
		send_log "\Port1APSResult:$ApsCnt1\n"
		send_log "\Port2APSResult:$ApsCnt2\n"
		if {$ApsCnt1 > $Value1} {
			gwd::GWpublic_print OK "�豸$::matchType1\����APS�����ұ�����ϢΪ$apsvalue1\����ȷ��" $::fileId
		} else {
			set errorTmp 1
			gwd::GWpublic_print NOK "�豸$::matchType1\����APS���ģ�������Ϣ��Ϊ$apsvalue1\�������쳣����鿴����$caseId\_GPN_LSP_002_GPNPort1.pcap" $::fileId
		}
		if {$ApsCnt2 > $Value1} {
			gwd::GWpublic_print OK "�豸$::matchType1\����APS�����ұ�����ϢΪ$apsvalue2\����ȷ��" $::fileId
		} else {
			set errorTmp 1
			gwd::GWpublic_print NOK "�豸$::matchType1\����APS���ģ�������Ϣ��Ϊ$apsvalue2\�������쳣����鿴����$caseId\_GPN_LSP_002_GPNPort2.pcap��" $::fileId
		}
		 return $errorTmp
	} 
########################################################################################################
#�������ܣ���Ԥ���յ����Ľ���ȷ�ϣ�APS���ģ�
#���������            
#                 waitetime��ץ���ȴ�ʱ��:�豸1Զ��BFD�Ự״̬
#                    caseId���˿�ץ���ļ����
#             a16BitFilCfg0�������Զ���16λ��������������EndOfRange��FilterName����Ϣ��
#                    Value1��Ԥ���յ�APS���ĵ���СFrameRate
#                  apsvalue��APS�����ֶ�Ԥ�ڵ���Ϣ
#					pcapNum: pcap�ı��ֵ
#				 GPNPortNum: �豸���
#����ֵ��0�������յ�BFD���ķ���Ԥ��Ҫ��1�������յ�BFD���Ĳ�����Ԥ��Ҫ��
#�����������
#����������PWBH�е�PWBH_ApsMessageConfirm
########################################################################################################
	proc LSP_ApsMessageConfirm1 {waitetime caseId Value1 apsvalue} {
		set errorTmp 0
		LSP_ApsCaptureStatistics1 $waitetime $caseId $apsvalue ApsCnt1
		send_log "\Port1APSResult:$ApsCnt1\n"

		# send_log "\Port2APSResult:$ApsCnt2\n"
		if {$ApsCnt1 > $Value1} {
			gwd::GWpublic_print OK "�豸$::matchType1\����APS�����ұ�����ϢΪ$apsvlaue\����ȷ��" $::fileId
		} else {
			set errorTmp 1
			gwd::GWpublic_print NOK "�豸$::matchType1\����APS���ģ�������Ϣ��Ϊ$apsvlaue\�������쳣����鿴����$caseId\_GPN_LSP_002_GPNPort1.pcap" $::fileId
		}
		 return $errorTmp
	} 

########################################################################################################
#�������ܣ�ͳ��ҵ�����Ķ������
#���������            
#                   hAna���˿ڷ�����handle
#					vid��vlan��id
#					smac��Դmac��ַ
#					DropCnt��ͳ�ƽ��
#����ֵ����
#���������
#�������ƶ�PWBH��PWBH_ClassStatisticsPortDrop����
########################################################################################################
proc LSP_ClassStatisticsPortDrop {infoObj vidmin vidmax DropCntmin DropCntmax} {
		upvar $DropCntmin tmp_DropCntmin
		upvar $DropCntmax tmp_DropCntmax
		set tmp_DropCntmin -1
		set tmp_DropCntmax -1
#		ͬ���������ͷ�����ͳ����ʱ2s  
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
				send_log "�������ǶԵ���$d"
				break
			}
			incr i
			stc::perform ResultsClearView -ResultList $resultsObj
		}
	}
		send_log "DroppedFrameCount:$tmp_DropCntmin,$tmp_DropCntmax"	
	}
########################################################################################################
#�������ܣ�GPN������ĳ��vlan�İ�arp��mac
#�������: GPNType��GPN������
#         vid��vlan id��
#         arp����ARP��ַ
#         mac����MAC��ַ
#        port���󶨶˿�
#�����������
#����ֵ�� flagErr  =0����ӳɹ�       =1�����ʧ��            =2��ip��ַ��Ӵﵽ���ֵ���޷��������  =3�����ܰ󶨹㲥ip  =4���ܰ��鲥ip
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
  
  gwd::GWpublic_print [expr {($flagErr == 0) ? "OK" : "NOK"}] "��vlan$vid\�а�ip:$arp\�Ұ�mac:$mac" $fileId
  return $flagErr  
}

########################################################################################################
#�������ܣ�ҵ�����޹��Ϻ͹���ʱ�Ķ����������
#���������            
#                   flag��=1 ������·��������£�=2 ������·���쳣������е����¼�����
#                   time���е����¼���������£�ҵ�񵹻��ɽ���ʱ�䣨��λΪ��ms��
#                  hAna1�����˶˿ڷ�����handle
#                  hAna2���Զ˶˿ڷ�����handle
#����ֵ����
#���������                     value1: flag=1ʱ ����ֵ����ҵ�񶪰������flag=2ʱ ����ֵ����ҵ�񵹻�ʱ�䣨��λΪ��ms��
#�������ƶ�PWBH��PWBH_ClassDropStatisticsAna����
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
				gwd::GWpublic_print NOK "��������·�������޵����¼���������¶Է�������������Ϊ10000fps��ҵ����ڶ���������С������Ϊ$valuemin����󶪰���Ϊ$valuemax" $::fileId
			} else {
				gwd::GWpublic_print OK "��������·�������޵����¼���������¶Է�������������Ϊ10000fps��ҵ�������޶�������" $::fileId
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
					gwd::GWpublic_print NOK "���е����¼����������Ԥ��ҵ�񲻶�����ҵ����ڶ�������С������Ϊ$valuemin����󶪰���Ϊ$valuemax��" $::fileId
				} else {
					gwd::GWpublic_print OK "���е����¼����������Ԥ��ҵ�񲻶���������Ҫ��ҵ���޶�����" $::fileId
				}
			} else {
				set value1 [expr $value1/10]
				set value2 [expr $value2/10]
				if {$value1 > $time || $value2 > $time} {
					set errorTmp 1
					gwd::GWpublic_print NOK "���е����¼���������¿ɽ���ʱ��Ϊ$time ms��ҵ�񵹻�ʱ������ԼΪ$valuemin ms\,���ԼΪ$vlauemax ms��" $::fileId
				} else {
					gwd::GWpublic_print OK "���е����¼���������¿ɽ���ʱ��Ϊ$time ms��ҵ�񵹻�ʱ������ԼΪ$valuemin ms\,���ԼΪ$vlauemax ms��" $::fileId
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
					gwd::GWpublic_print NOK "���е����¼����������Ԥ��ҵ�񲻶�����ҵ����ڶ�������С������Ϊ$valuemin����󶪰���Ϊ$valuemax��" $::fileId
				} else {
					gwd::GWpublic_print OK "���е����¼����������Ԥ��ҵ�񲻶���������Ҫ��ҵ���޶�����" $::fileId
				}
			} else {
				set valuemin [expr $valuemin/10]
				set valuemax [expr $valuemax/10]
				if {$valuemin > $time || $valuemax > $time} {
					set errorTmp 1
					gwd::GWpublic_print NOK "���е����¼���������¿ɽ���ʱ��Ϊ$time ms��ҵ�񵹻�ʱ������ԼΪ$valuemin ms\,���ԼΪ$vlauemax ms��" $::fileId
				} else {
					gwd::GWpublic_print OK "���е����¼���������¿ɽ���ʱ��Ϊ$time ms��ҵ�񵹻�ʱ������ԼΪ$valuemin ms\,���ԼΪ$vlauemax ms��" $::fileId
				}
		}
		return $errorTmp 
	}
  ########################################################################################################
  #�������ܣ����Ʒ��ͺͽ�����Ϣ
  #���������projectObj����Ϣ���Ƶ� ��ָ��
  #          resultParentObj�� ��Ϣ���Ƶ� �����ָ��
  #          paraArr��������Ϣ�����Բ���
  #��������� infoObj��       ��Ϣ����ָ��
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