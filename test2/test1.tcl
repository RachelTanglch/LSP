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

set lsp_num 128
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
match_max -d 20000000

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

chan configure $stdout -blocking 0 -buffering none;#������ģʽ ����flush
chan configure $fileId -blocking 0 -buffering none;#������ģʽ ����flush
set fd_debug [open debug\\GPN_PTN_LSP_002_DEBUG.txt a]
exp_internal -f debug\\GPN_PTN_LSP_002_DEBUG.txt 0
chan configure $fd_debug -blocking 0 -buffering none;#������ģʽ ����flush
    source test2\\LSPBH_Mode_Function.tcl
    #source LSPBH_Mode_Function.tcl
set startSeconds [clock seconds]
set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
#set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
set telnet3 [gwd::GWpublic_loginGpn $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 $fileId]
#set telnet4 [gwd::GWpublic_loginGpn $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $fileId]
#gwd::GWpublic_ShowMlpsRun $fileId $matchType1 $Gpn_type1 "ac1" $telnet1 ""

    puts $fileId "�������Թ���...\n"
    stc::connect $stcIp
    puts $fileId "�������̿�ʼ[clock format [clock seconds]]" 
    stc::reserve "$stcIp/$GPNStcPort1 $stcIp/$GPNStcPort2"
    stc::config automationoptions -logLevel warn
    #�������Թ���
    set hProject [stc::create project]

    gwd::STC_createPort $stcIp $hProject $GPNStcPort1 $GPNEth1Media hport1
    puts $fileId "�������̽���[clock format [clock seconds]]"
    set hgenerator1 [stc::get $hport1 -children-generator]
    set hGeneratorConfig1 [stc::get $hgenerator1 -children-GeneratorConfig]
    stc::config $hGeneratorConfig1 -SchedulingMode RATE_BASED
    set hanalyzer1 [stc::get $hport1 -children-analyzer]
    set hfilter132BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer1 "APS" "34" "START_OF_FRAME" "251658240" "251658240" "4294967295"]
    # set filter1 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><srcMac filterMinValue="00:00:00:00:00:00" filterMaxValue="FF:FF:FF:FF:FF:FF">FF:FF:FF:FF:FF:FF</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>} 
    # set hAnalyzerFrCofFilter1 [stc::create AnalyzerFrameConfigFilter -under $hanalyzer1 -FrameConfig $filter1]
    stc::config $hanalyzer1 -FilterOnStreamId "FALSE"
    set hcapture1 [stc::get $hport1 -children-capture]
    set hCaptureFilter1 [stc::get $hcapture1 -children-CaptureFilter]
    set hCaptureAnalyzerFilter1 [LSP_CaptureAnalyzerFilter $hCaptureFilter1 "TRUE" "APS" "31" "39" "255"]
    #   �������Զ˿�2
    gwd::STC_createPort $stcIp $hProject $GPNStcPort2 $GPNEth2Media hport2
    set hgenerator2 [stc::get $hport2 -children-generator]
    set hGeneratorConfig2 [stc::get $hgenerator2 -children-GeneratorConfig]
    stc::config $hGeneratorConfig2 -SchedulingMode RATE_BASED
    set hanalyzer2 [stc::get $hport2 -children-analyzer]
    set hfilter232BitFilAna0 [LSP_Analyzer32BitFilter $hanalyzer2 "APS" "34" "START_OF_FRAME" "251658240" "251658240" "4294967295"]
    # set filter2 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><srcMac filterMinValue="00:00:00:00:00:00" filterMaxValue="FF:FF:FF:FF:FF:FF">FF:FF:FF:FF:FF:FF</srcMac></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>}
    # set hAnalyzerFrCofFilter2 [stc::create AnalyzerFrameConfigFilter -under $hanalyzer2 -FrameConfig $filter2]
    stc::config $hanalyzer2 -FilterOnStreamId "FALSE"
    set hcapture2 [stc::get $hport2 -children-capture]
    set hCaptureFilter2 [stc::get $hcapture2 -children-CaptureFilter]
    set hCaptureAnalyzerFilter2 [LSP_CaptureAnalyzerFilter $hCaptureFilter2 "TRUE" "APS" "31" "39" "255"]
    puts $fileId "����APS[clock format [clock seconds]]" 
    #   ������������
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

    # set hStream1 [gwd::STC_createStream $dStreamData1 $hport1 $fileId]
    # set hStream2 [gwd::STC_createStream $dStreamData2 $hport2 $fileId]
    puts $fileId "������[clock format [clock seconds]]" 
    stc::config [stc::get $dStreamData1 -AffiliationStreamBlockLoadProfile] -LoadUnit "FRAMES_PER_SECOND" -Load "10000" 
    stc::config [stc::get $dStreamData2 -AffiliationStreamBlockLoadProfile] -LoadUnit "FRAMES_PER_SECOND" -Load "10000" 
    
    foreach hStream "$dStreamData1 $dStreamData2" {
        stc::perform streamBlockActivate -streamBlockList $hStream -activate "TRUE"
    }
    stc::apply

    set rateL 9500000;#�շ�������ȡֵ��Сֵ��Χ
    set rateR 10500000;#�շ�������ȡֵ���ֵ��Χ   
    #   ���ƽ��
    puts $fileId "�����趨[clock format [clock seconds]]"
    set ResultDataSet1 [TxAndRx_Info $hProject $hport1 infoObj1]
    set ResultDataSet2 [TxAndRx_Info $hProject $hport2 infoObj2]
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case2_$tcId.xml" [pwd]/Untitled
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====ҵ���޵�������£�����NE1��NE3���ر���LSP��NNI�ڣ�ץ������APS���ģ���ʼ====="
    array set aMirror "dir1 egress port1 $GPNPort2 dir2 \"\" port2 \"\""
    gwd::GWpublic_CfgPortMirror $telnet1 $matchType1 $Gpn_type1 $fileId $GPNTestEth1 aMirror
    array set aMirror "dir1 egress port1 $GPNPort6 dir2 \"\" port2 \"\""
    gwd::GWpublic_CfgPortMirror $telnet3 $matchType3 $Gpn_type3 $fileId $GPNTestEth2 aMirror
    #lappend flag1_Case2 [LSP_ApsMessageConfirm "10000" "1" 0 "0f 00 00 00 " "0f 00 00 00 "]

    # if {"1" in $flag1_Case2} {
    #     set flagCase2 1
    #     gwd::GWpublic_print "NOK" "FB1�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)ҵ�����������APS����״̬��0f00 0000���쳣" $fileId 
    # } else { 
    #     gwd::GWpublic_print "OK" "FB1�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)ҵ�����������APS����״̬Ϊ0f00 0000������" $fileId
    # }
    # gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====ҵ���޵�������£�����NE1��NE3���ر���LSP��NNI�ڣ�ץ������APS���ģ�����====="
    # puts $fileId ""
    # puts $fileId "======================================================================================\n"
    # puts $fileId ""
    # gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====NE1��NE3�Է���������������10000fps�����ҵ���Ƿ���������ʼ====="
    ## ���¶��Ʒ�����
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fileId $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fileId $GPNTestEth2

    stc::delete $hfilter132BitFilAna0
    stc::delete $hfilter232BitFilAna0
    set filter1 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><vlans name="anon_4271"><Vlan name="Vlan"><id filterMinValue="1101" filterMaxValue="1230">4095</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>}
    set filter2 {<frame><config><pdus><pdu name="eth1" pdu="ethernet:EthernetII"><vlans name="anon_4253"><Vlan name="Vlan"><id filterMinValue="1101" filterMaxValue="1230">4095</id></Vlan></vlans></pdu><pdu name="ip_1" pdu="ipv4:IPv4"></pdu></pdus></config></frame>} 
    set AnalyzerFrameConfigFilter1 [stc::create "AnalyzerFrameConfigFilter" \
        -under $hanalyzer1 \
        -Summary {Vlan:ID = FFF Min Value = 1101 Max Value = [expr 1100+$lsp_num]} \
        -FrameConfig $filter1]
    set AnalyzerFrameConfigFilter2 [stc::create "AnalyzerFrameConfigFilter" \
        -under $hanalyzer2 \
        -Summary {Vlan:ID = FFF Min Value = 1101 Max Value = [expr 1100+$lsp_num]} \
        -FrameConfig $filter2]
    set Analyzer16BitFilter1 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter1 "1101" "[expr 1100+$lsp_num]"]
    set Analyzer16BitFilter2 [Create_Analyzer16Bit $AnalyzerFrameConfigFilter2 "1101" "[expr 1100+$lsp_num]"]
    stc::apply
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    incr tcId 
    gwd::GWpublic_saveTCCfg 1 $fd_log "GPN_LSP_002_Case2_$tcId.xml" [pwd]/Untitled
    lappend flag2_Case2 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 "1101" "[expr 1100+$lsp_num]" "" valuemin valuemax]
    lappend flag2_Case2 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "1"]
    lappend flag2_Case2 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "2"]
    puts $fileId ""
    if {"1" in $flag2_Case2} {
        set flagCase2 1
        gwd::GWpublic_print "NOK" "FB2�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)�Է�������ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FB2�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)�Է�������ҵ�������޶���,CC�޸澯" $fileId
    }