#!/bin/sh
# test2.tcl \
exec tclsh "$0" ${1+"$@"}
package require gwd 2.0
package require stcPack
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

set stcIp 10.16.50.195 ;#STC的ip地址
set GPNStcPort1 "7/4"; #拓扑中TC1(TC的端口号)
set GPNTestEth1 2/3;				  #拓扑中与TC1连接的设备端口号
set GPNEth1Media EthernetCopper;              #拓扑中TC1使用的截止Cooper(电口)	1gf(千兆光口)	10gf(万兆光口) 
set GPNTestEthMgt 1/2;                #将NE1设备设为网关网元

set GPNStcPort2 "7/3"; #拓扑中TC1(TC的端口号)
set GPNTestEth2 4/4;				  #拓扑中与TC1连接的设备端口号
set GPNEth2Media EthernetCopper;              #拓扑中TC1使用的截止Cooper(电口)	1gf(千兆光口)	10gf(万兆光口) 
dict set ftp ip "10.10.32.23"  ;#ftp服务器的ip地址
dict set ftp userName "racheltang"  ;#ftp服务器的用户名
dict set ftp passWord "123456" ;#ftp服务器的密码


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
set cap_enable 1
set managePort1 "17/1";#NE1设备的管理口
set Worklevel "L2"
set WaiteTime 60000 ;#等待时间
set WaiteTime1 25000 ;#等待时间
#set WaiteTime8 300000 ;#等待时间
set rebootTime 300000;#重启设备的时间
array set acapture {capMode "REGULAR_MODE" capSource "Tx_Rx_MODE"}
set fileId [open "report\\GPN_PTN_001_REPORT.txt" a+]
set fd_log [open "log\\GPN_PTN_LSP_002_LOG.txt" a]
set stdout $fd_log
log_file log\\GPN_PTN_LSP_002_LOG.txt
chan configure $stdout -blocking 0 -buffering none;#非阻塞模式 按行flush
chan configure $fileId -blocking 0 -buffering none;#非阻塞模式 按行flush
set fd_debug [open debug\\GPN_PTN_LSP_002_DEBUG.txt a]
exp_internal -f debug\\GPN_PTN_LSP_002_DEBUG.txt 0
chan configure $fd_debug -blocking 0 -buffering none;#非阻塞模式 按行flush
    source test2\\LSPBH_Mode_Function.tcl

array set acapture {capMode "REGULAR_MODE" capSource "Tx_Rx_MODE"}
set fileId [open "report\\GPN_PTN_001_REPORT.txt" a+]
set fd_log [open "log\\GPN_PTN_LSP_002_LOG.txt" a]
set stdout $fd_log
log_file log\\GPN_PTN_LSP_002_LOG.txt


array set acapture {capMode "REGULAR_MODE" capSource "Tx_Rx_MODE"}
set fileId [open "report\\GPN_PTN_001_REPORT.txt" a+]
set fd_log [open "log\\GPN_PTN_LSP_002_LOG.txt" a]
set stdout $fd_log
log_file log\\GPN_PTN_LSP_002_LOG.txt

chan configure $stdout -blocking 0 -buffering none;#非阻塞模式 按行flush
chan configure $fileId -blocking 0 -buffering none;#非阻塞模式 按行flush
set fd_debug [open debug\\GPN_PTN_LSP_002_DEBUG.txt a]
exp_internal -f debug\\GPN_PTN_LSP_002_DEBUG.txt 0
chan configure $fd_debug -blocking 0 -buffering none;#非阻塞模式 按行flush
    source test2\\LSPBH_Mode_Function.tcl
    #source LSPBH_Mode_Function.tcl
set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
#set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
#set telnet3 [gwd::GWpublic_loginGpn $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 $fileId]
#set telnet4 [gwd::GWpublic_loginGpn $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $fileId]
gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "1"