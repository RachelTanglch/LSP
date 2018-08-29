#!/bin/sh
# test2.tcl \
exec tclsh "$0" ${1+"$@"}
package require gwd 2.0
package require stcPack
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

set stcIp 10.16.50.195 ;#STC��ip��ַ
set GPNStcPort1 "7/4"; #������TC1(TC�Ķ˿ں�)
set GPNTestEth1 2/3;				  #��������TC1���ӵ��豸�˿ں�
set GPNEth1Media EthernetCopper;              #������TC1ʹ�õĽ�ֹCooper(���)	1gf(ǧ�׹��)	10gf(���׹��) 
set GPNTestEthMgt 1/2;                #��NE1�豸��Ϊ������Ԫ

set GPNStcPort2 "7/3"; #������TC1(TC�Ķ˿ں�)
set GPNTestEth2 4/4;				  #��������TC1���ӵ��豸�˿ں�
set GPNEth2Media EthernetCopper;              #������TC1ʹ�õĽ�ֹCooper(���)	1gf(ǧ�׹��)	10gf(���׹��) 
dict set ftp ip "10.10.32.23"  ;#ftp��������ip��ַ
dict set ftp userName "racheltang"  ;#ftp���������û���
dict set ftp passWord "123456" ;#ftp������������


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
set cap_enable 1
set managePort1 "17/1";#NE1�豸�Ĺ����
set Worklevel "L2"
set WaiteTime 60000 ;#�ȴ�ʱ��
set WaiteTime1 25000 ;#�ȴ�ʱ��
#set WaiteTime8 300000 ;#�ȴ�ʱ��
set rebootTime 300000;#�����豸��ʱ��
array set acapture {capMode "REGULAR_MODE" capSource "Tx_Rx_MODE"}
set fileId [open "report\\GPN_PTN_001_REPORT.txt" a+]
set fd_log [open "log\\GPN_PTN_LSP_002_LOG.txt" a]
set stdout $fd_log
log_file log\\GPN_PTN_LSP_002_LOG.txt
chan configure $stdout -blocking 0 -buffering none;#������ģʽ ����flush
chan configure $fileId -blocking 0 -buffering none;#������ģʽ ����flush
set fd_debug [open debug\\GPN_PTN_LSP_002_DEBUG.txt a]
exp_internal -f debug\\GPN_PTN_LSP_002_DEBUG.txt 0
chan configure $fd_debug -blocking 0 -buffering none;#������ģʽ ����flush
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

chan configure $stdout -blocking 0 -buffering none;#������ģʽ ����flush
chan configure $fileId -blocking 0 -buffering none;#������ģʽ ����flush
set fd_debug [open debug\\GPN_PTN_LSP_002_DEBUG.txt a]
exp_internal -f debug\\GPN_PTN_LSP_002_DEBUG.txt 0
chan configure $fd_debug -blocking 0 -buffering none;#������ģʽ ����flush
    source test2\\LSPBH_Mode_Function.tcl
    #source LSPBH_Mode_Function.tcl
set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
#set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
#set telnet3 [gwd::GWpublic_loginGpn $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 $fileId]
#set telnet4 [gwd::GWpublic_loginGpn $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $fileId]
gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "1"