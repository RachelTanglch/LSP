

###���Խű������޸Ŀ�ʼ------
set gpnIp1 10.10.104.31   ;#������NE1��IP��ַ
set userName1 admin       ;#������NE1���û���
set password1 greenway    ;#������NE1������
set matchType1 "GPN7600"  ;#������NE1��host name�������豸��Device1(config)#����matchType1ΪDevice1
set Gpn_type1 "7600"      ;#������NE1���豸����
### Case2��������
set gpnIp2 10.10.104.34
set userName2 admin       ;#������NE2���û���
set password2 greenway    ;#������NE2������
set matchType2 "GPN7600"  ;#������NE2��host name�������豸��Device2(config)#����matchType2ΪDevice2
set Gpn_type2 "7600"      ;#������NE2���豸����

set gpnIp3 10.10.104.41
set userName3 admin       ;#������NE1���û���
set password3 greenway    ;#������NE1������
set matchType3 "GPN7600"  ;#������NE1��host name�������豸��Device1(config)#����matchType1ΪDevice1
set Gpn_type3 "7600"      ;#������NE1���豸����

set gpnIp4 10.10.104.42
set userName4 admin       ;#������NE1���û���
set password4 greenway    ;#������NE1������
set matchType4 "GPN7600"  ;#������NE1��host name�������豸��Device1(config)#����matchType1ΪDevice1
set Gpn_type4 "7600"      ;#������NE1���豸����

set managePort1 "17/1";#NE1�豸�Ĺ����
set managePort2 "17/1";#NE2�豸�Ĺ����
set managePort3 "17/1";#NE3�豸�Ĺ����
set managePort4 "17/1";#NE4�豸�Ĺ����

dict set ftp ip "10.10.32.23"  ;#ftp��������ip��ַ
dict set ftp userName "racheltang"  ;#ftp���������û���
dict set ftp passWord "123456" ;#ftp������������

set stcIp 10.16.50.195 ;#STC��ip��ַ

set GPNStcPort1 "//10.16.50.195/7/4"; #������TC1(TC�Ķ˿ں�)
set GPNTestEth1 2/3;				  #��������TC1���ӵ��豸�˿ں�
set GPNEth1Media ethernetFiber;              #������TC1ʹ�õĽ�ֹCopper(���)	1gf(ǧ�׹��)	10gf(���׹��) 
set GPNTestEthMgt 1/2;                #��NE1�豸��Ϊ������Ԫ

set GPNStcPort2 "//10.16.50.195/7/3"; #������TC1(TC�Ķ˿ں�)
set GPNTestEth2 4/4;				  #��������TC1���ӵ��豸�˿ں�
set GPNEth2Media ethernetFiber;              #������TC1ʹ�õĽ�ֹCooper(���)	1gf(ǧ�׹��)	10gf(���׹��) 

###���������ͼ�޸�����Ķ˿ڵ�ֵ����ӦP1-P24�������ڱ���������û���õĶ˿ڿ��Ժ��Բ����޸�------
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
###------���������ͼ�޸�����Ķ˿ڵ�ֵ����ӦP5-P24�������ڱ���������û���õĶ˿ڿ��Ժ��Բ����޸�

###------��ѡ����Ҫ�������в��Ե�LSP����
set lsp_num 128
###------����LSP1:1��������
set Worklevel "L2"   ;#�豸�����Ĳ���  = L3/l2
set SoftVer "PTN"  ;#����汾  = IPRAN /PTN
set trunkLevel "L2"  ;#trunk�ڹ����Ĳ���                   
set lDev1TestPort "1/1 1/2 1/3 1/4 10/1 10/2" ;#NE1����˿��б����������6��ʵ�ʴ��ڵĶ˿�
set topology "T1"  ;# ������ ="T1" ˵��ʹ������һ   ="T2" ˵��ʹ�����˶� 
###------���Խű������޸Ľ���



###���������������޸�----------
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
			puts "����3���ϴ�$matchType1\��config�ļ���ʧ�ܣ�����ftp����������ͨ��"
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
				puts "����3���ϴ�$matchType2\��config�ļ���ʧ�ܣ�����ftp����������ͨ��"
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
		puts "����3���ϴ�$matchType3\��config�ļ���ʧ�ܣ�����ftp����������ͨ��"
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
			puts "����3���ϴ�$matchType4\��config�ļ���ʧ�ܣ�����ftp����������ͨ��"
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

## ��ȡ�ļ��б�
set fileList ""
set pattern "$topology*tcl"
set fileList [glob -nocomplain $path/$pattern]
if {$fileList == ""} {
	puts "û����Ҫ���еĽű����������topology��ֵ�Ƿ���д��ȷ"
} else {
	puts "��Ҫ���еĽű���"
	foreach i $fileList {
		puts $i
	} 
}

### ִ�и�Ŀ¼������tcl�ű�
foreach i $fileList {
    puts "[clock format [clock seconds]]  $i\��ʼִ��"
    if {[catch {
	exec tclsh $i $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $managePort1 $GPNPortList $ftp $Worklevel $SoftVer $trunkLevel $lDev1TestPort \
		      $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 \
		      $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $stcIp $GPNStcPort1 $GPNTestEth1 $GPNEth1Media \
		      $GPNStcPort2 $GPNTestEth2 $GPNEth2Media $managePort2 $managePort3 $managePort4 $GPNTestEthMgt $lsp_num

    } err]} {
    	puts $err
		puts "�ű������쳣"    
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
    puts "[clock format [clock seconds]]  $i\ִ�н���"
  
}
after 5000
puts [clock format [clock seconds]]
puts "end end end"
###----------���������������޸�


