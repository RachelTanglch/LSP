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
set GPNStcPort1 "7/2"; #������TC1(TC�Ķ˿ں�)
set GPNTestEth1 2/3;                  #��������TC1���ӵ��豸�˿ں�
set GPNEth1Media EthernetCopper;              #������TC1ʹ�õĽ�ֹCooper(���)    1gf(ǧ�׹��)   10gf(���׹��) 
set GPNTestEthMgt 1/2;                #��NE1�豸��Ϊ������Ԫ

set GPNStcPort2 "7/1"; #������TC1(TC�Ķ˿ں�)
set GPNTestEth2 4/4;                  #��������TC1���ӵ��豸�˿ں�
set GPNEth2Media EthernetCopper;              #������TC1ʹ�õĽ�ֹCooper(���)    1gf(ǧ�׹��)   10gf(���׹��) 
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

    regsub {/} $GPNTestEth1 {_} GPNTestEth1_cap
    regsub {/} $GPNTestEth2 {_} GPNTestEth2_cap

array set acapture {capMode "REGULAR_MODE" capSource "Tx_Rx_MODE"}

    set flagCase1 0                         ; #Test Case 1��־λ
    set flagCase2 0                         ; #Test Case 2��־λ
    set flagCase3 0                         ; #Test Case 3��־λ
    set flagCase4 0                         ; #Test Case 4��־λ
    set flagCase5 0                         ; #Test Case 5��־λ
    set flagResult 0
    set FLAGE 0
    set cfgId 0

    set tcId 0                              ; #���ɵ�xml�ļ���־λ
    set capId 0                             ; #���ɵ�pcap�ļ���־λ
    set FLAGF 0
    set ip1 192.168.1.10
    set ip2 192.168.1.11
    set ip3 192.168.1.12
    set ip4 192.168.1.13

    set destAddr1 4.4.4.4
    set destAddr2 1.1.1.1
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
set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
#set telnet2 [gwd::GWpublic_loginGpn $gpnIp2 $userName2 $password2 $matchType2 $Gpn_type2 $fileId]
set telnet3 [gwd::GWpublic_loginGpn $gpnIp3 $userName3 $password3 $matchType3 $Gpn_type3 $fileId]
#set telnet4 [gwd::GWpublic_loginGpn $gpnIp4 $userName4 $password4 $matchType4 $Gpn_type4 $fileId]
set lsp_num 128
puts $fileId "�������Թ���...\n"
    stc::connect $stcIp
    stc::reserve "$stcIp/$GPNStcPort1 $stcIp/$GPNStcPort2"
    stc::config automationoptions -logLevel warn
    #�������Թ���
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
    #   �������Զ˿�2
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

    stc::config [stc::get $dStreamData1 -AffiliationStreamBlockLoadProfile] -LoadUnit "FRAMES_PER_SECOND" -Load "10000" 
    stc::config [stc::get $dStreamData2 -AffiliationStreamBlockLoadProfile] -LoadUnit "FRAMES_PER_SECOND" -Load "10000" 

    foreach hStream "$dStreamData1 $dStreamData2" {
        stc::perform streamBlockActivate -streamBlockList $hStream -activate "TRUE"
    }
    stc::apply

    set rateL 9500000;#�շ�������ȡֵ��Сֵ��Χ
    set rateR 10500000;#�շ�������ȡֵ���ֵ��Χ   
    #   ���ƽ��
    set ResultDataSet1 [TxAndRx_Info $hProject $hport1 infoObj1]
    set ResultDataSet2 [TxAndRx_Info $hProject $hport2 infoObj2]
    set totalPage1 [stc::get $infoObj1 -TotalPageCount]
    set totalPage2 [stc::get $infoObj2 -TotalPageCount]

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
    lappend flag1_Case2 [LSP_ApsMessageConfirm "10000" "1" 0 "0f 00 00 00 " "0f 00 00 00 "]
    gwd::GWpublic_DelPortMirror $telnet1 $matchType1 $Gpn_type1 $fileId $GPNTestEth1
    gwd::GWpublic_DelPortMirror $telnet3 $matchType3 $Gpn_type3 $fileId $GPNTestEth2
    if {"1" in $flag1_Case2} {
        set flagCase2 1
        gwd::GWpublic_print "NOK" "FB1�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)ҵ�����������APS����״̬��0f00 0000���쳣" $fileId 
    } else { 
        gwd::GWpublic_print "OK" "FB1�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)ҵ�����������APS����״̬Ϊ0f00 0000������" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====ҵ���޵�������£�����NE1��NE3���ر���LSP��NNI�ڣ�ץ������APS���ģ�����====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====NE1��NE3�Է���������������10000fps�����ҵ���Ƿ���������ʼ====="
    ## ���¶��Ʒ�����
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
        gwd::GWpublic_print "NOK" "FB2�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)�Է�������ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FB2�����ۣ�NE1($gpnIp1)��NE3($gpnIp3)�Է�������ҵ�������޶���,CC�޸澯" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====NE1��NE3�Է���������������10000fps�����ҵ���Ƿ�����������====="
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase2] == 1)? "NOK":"OK"}] "Test Case 2 ���Խ���" $fileId
    incr cfgId
    lappend FLAGF [gwd::GWpublic_uploadDevCfg 1 $lSpawn_id $lMatchType $lDutType $fileId $fd_log $startSeconds $lIp $ftp $cfgId "GPN_PTN_LSP_002" lFailFileTmp]
    if {$lFailFileTmp != ""} {
        set lFailFile [concat $lFailFile $lFailFileTmp]
        }  
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 2 ҵ����������£��鿴APS���ļ�������� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 3 �����������ָ�ʱ�� ���Կ�ʼ\n"
    set flag1_Case3 0
    set flag2_Case3 0
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�ź�ʧЧ(SF)������ָ�����ʼ====="
    puts $fileId "  *****shutdown��NE1����LSP��NNI��*****"
    gwd::GWpublic_CfgPortState $telnet1 $matchType1 $Gpn_type1 $fileId $GPNPort1 "shutdown"
    set lport1 "$hport1 $hport2"
    #�˴��е�������
    puts $fileId ""
    lappend flag1_Case3 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    #����Ǳ��ϵ���Ϣ
    after 20000
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    stc::perform ResultsClearAll -PortList $lport1
    puts $fileId ""
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
    puts $fileId "  *****�ָ�NE1����LSP��NNI��*****"
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
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
        gwd::GWpublic_print "NOK" "FC1�����ۣ��ź�ʧЧ(SF)������ָ���ҵ���쳣" $fileId 
    } else { 
        gwd::GWpublic_print "OK" "FC1�����ۣ��ź�ʧЧ(SF)������ָ���ҵ������" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�ź�ʧЧ(SF)������ָ����ԣ�����====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�м�ڵ����������������ԣ���ʼ====="
    ## ����APS���ĵĹ��������µĲ�����
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
    #����Ǳ��ϵ���Ϣ
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "  *****����Ǳ��ϵ���Ϣ****"
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
        gwd::GWpublic_print "NOK" "FC2�����ۣ��м�ڵ�NE2($gpnIp2)���紥���������ԣ�ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FC2�����ۣ��м�ڵ�NE2($gpnIp2)���紥���������ԣ�ҵ�������޶���ץȡ������ȷ" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�м�ڵ����������������ԣ�����====="
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase3] == 1)? "NOK":"OK"}] "Test Case 3 ���Խ���" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 3 ҵ����������£��鿴APS���ļ�������� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 4 �ⲿ�������� ���Կ�ʼ\n"
    set flag1_Case4 0
    set flag2_Case4 0
    set flag3_Case4 0
    set flag4_Case4 0
    set flag5_Case4 0
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�˹��������������ԣ���ʼ====="
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
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
        gwd::GWpublic_print "NOK" "FD1�����ۣ��˹��������������ԣ�ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FD1�����ۣ��˹��������������ԣ�ҵ�������޶�����ץȡ������ȷ" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�˹��������������ԣ�����====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====ǿ�Ƶ������������ԣ���ʼ====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag2_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsw" err] 
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "FS"]
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "work"]
    lappend flag2_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $gpnIp3 $telnet3 "1" "work"]
    lappend flag2_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
        gwd::GWpublic_print "NOK" "FD2�����ۣ�ǿ�Ƶ������������ԣ�ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FD2�����ۣ�ǿ�Ƶ������������ԣ�ҵ�������޶�����ץȡ������ȷ" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====ǿ�Ƶ������������ԣ�����====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====ǿ�Ƶ������������ԣ���ʼ====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag3_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "fsp" err]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "FS-P"]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $Gpn_type1 $telnet1 "1" "protect"]
    lappend flag3_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $Gpn_type3 $telnet3 "1" "protect"]

    lappend flag3_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
        gwd::GWpublic_print "NOK" "FD3�����ۣ�ǿ�Ƶ������������ԣ�ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FD3�����ۣ�ǿ�Ƶ������������ԣ�ҵ�������޶�����ץȡ������ȷ" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====ǿ�Ƶ������������ԣ�����====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�����������ԣ���ʼ====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag4_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $Gpn_type1 $telnet1 "ac101" "lp" err]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "LO"]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $Gpn_type1 $telnet1 "1" "work"]
    lappend flag4_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $Gpn_type3 $telnet3 "1" "work"]

    lappend flag4_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
        gwd::GWpublic_print "NOK" "FD4�����ۣ������������ԣ�ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FD4�����ۣ������������ԣ�ҵ�������޶�����ץȡ������ȷ" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====�����������ԣ�����====="
    puts $fileId ""
    puts $fileId "======================================================================================\n"
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====������ԣ���ʼ====="
    gwd::Start_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    lappend flag5_Case4 [gwd::LSP_StatusSwitch $fileId $matchType1 $gpnIp1 $telnet1 "ac101" "clear" err]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType1 $gpnIp1 $telnet1 "1" "NR"]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_Status $fileId $matchType3 $gpnIp3 $telnet3 "1" "NR"]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $Gpn_type1 $telnet1 "1" "work"]
    lappend flag5_Case4 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType3 $Gpn_type3 $telnet3 "1" "work"]

    lappend flag5_Case4 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "50" valuemin valuemax]
    gwd::Stop_SendFlow "$hgenerator1 $hgenerator2" "$hanalyzer1 $hanalyzer2"
    puts $fileId ""
    puts $fileId "  *****����Ǳ��ϵ���Ϣ*****"
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
        gwd::GWpublic_print "NOK" "FD5�����ۣ�������ԣ�ҵ���쳣" $fileId
    } else {
        gwd::GWpublic_print "OK" "FD5�����ۣ�������ԣ�ҵ�������޶�����ץȡ������ȷ" $fileId
    }
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "=====���������====="
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase4] == 1)? "NOK":"OK"}] "Test Case 4 ���Խ���" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 4 �ⲿ�������� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 5 �������ȼ����� ���Կ�ʼ\n"
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
    
    #�˴��е�������
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
    ###�˹�����������
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
    ###ǿ�Ƶ���������
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
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase5] == 1)? "NOK":"OK"}] "Test Case 5 ���Խ���" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 5 �������ȼ����� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 6 ���ñ���ָ� ���Կ�ʼ\n"
    set flag1_Case6 0
    lappend flag1_Case6 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun1 "60000"]
    set compareFilerun1 [open "log\\LSPBH_002_��һ����$matchType1\��Showrun.txt" w]
    puts $compareFilerun1 $contentrun1
    close $compareFilerun1
    gwd::GWpublic_SaveCfg $telnet1 $matchType1 $Gpn_type1 $fileId
    gwd::GWpublic_SaveCfg $telnet3 $matchType3 $Gpn_type3 $fileId
    gwd::GWpublic_Reboot $telnet1 $matchType1 $Gpn_type1 $fileId
    after $rebootTime
    set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
    set lSpawn_id [lreplace $lSpawn_id 0 0 $telnet1]
    ####�˴���Ҫ�޸ģ�����
    lappend flag1_Case6 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun2 "60000"]
    set compareFilerun2 [open "log\\LSPBH_002_��������$matchType1\��Showrun.txt" w]
    puts $compareFilerun2 $contentrun2
    close $compareFilerun2
    if {[md5::md5 -hex -filename "log\\LSPBH_002_��һ����$matchType1\��Showrun.txt"]==[md5::md5 -hex -filename "log\\LSPBH_002_��������$matchType1\��Showrun.txt"]} {
                gwd::GWpublic_print "OK" "��$matchType1\�Ͻ�������ǰ���������Ϣ�ȶԣ������ͬ��" $fileId
            } else {
                lappend flag1_Case6 1 
                gwd::GWpublic_print "NOK" "��$matchType1\�Ͻ�������ǰ���������Ϣ�ȶԣ��������ͬ����鿴\n               \
                LLSPBH_002_��һ����$matchType1\��Showrun.txt��LSPBH_002_��������$matchType1\��Showrun.txt�ļ���" $fileId
            }
    lappend flag1_Case6 [LSP_ClassDropStatisticsAna "1" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
    lappend flag1_Case6 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "1"]
    lappend flag1_Case6 [gwd::GWpublic_ShowMplsOAM $telnet1 $matchType1 $Gpn_type1 $fileId "lsp" "2"]
    lappend flag1_Case6 [gwd::GWpublic_ShowMlpsAPS_CurPath $fileId $matchType1 $gpnIp1 $telnet1 "1" "work"]
    if {"1" in $flag1_Case6} {
        set flagCase6 1
    }
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase6] == 1)? "NOK":"OK"}] "Test Case 6 ���Խ���" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 6 ���ñ���ָ� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 7 ����/SW�����Թ���Ӱ�� ���Կ�ʼ\n"
    set flag1_Case7 0
    for {set j 1} {$j<$cntdh} {incr j} {
        if {![gwd::GWCard_AddSwitch $telnet1 $matchType1 $Gpn_type1 $fileId]} {
            after [expr 2*$rebootTime]
            set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
            set lSpawn_id [lreplace $lSpawn_id 1 1 $telnet1]
            lappend flag1_Case7 [LSP_ClassDropStatisticsAna "2" $infoObj1 $infoObj2 $startRange $endRange "" valuemin valuemax]
                stc::perform ResultsClearAll -PortList $lport1
        } else {
            puts $fileId "$matchType1\��֧��NMS������������ֻ��һ��NMS����������"
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
    #   incr showMpls -1
    # }
    # while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "cfm" result_cfm]} {
    #   incr showCfm -1
    # }
    # while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "mlps" result_mlps]} {
    #   incr showMlps -1
    # }
    # regexp {interface lsp tunnel Tunnel_101.*?exit} $result_mpls lsp101
    # regexp {interface lsp tunnel Tunnel_2101.*?exit} $result_mpls lsp2101
    # regexp {interface pw pw101.*?exit} $result_mpls pw101
    # regexp {interface ac ac101.*?exit} $result_mpls ac101
    # regexp {mpls-tp-meg meg1.*?exit} $result_cfm meg1
    # regexp {mpls-tp-meg meg2.*?exit} $result_cfm meg2
    # regexp {create pro-grp ac101.*?exit} $result_mlps pro-grp101
    lappend flag1_Case7 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun3 "60000"]
    set compareFilerun3 [open "log\\LSPBH_002_������������$matchType1\��Showrun.txt" w]
    puts $compareFilerun3 $contentrun3
    close $compareFilerun3

    gwd::GWpublic_SaveCfg $telnet1 $matchType1 $Gpn_type1 $fileId
    gwd::GWpublic_SaveCfg $telnet3 $matchType3 $Gpn_type3 $fileId
    gwd::GWpublic_Reboot $telnet1 $matchType1 $Gpn_type1 $fileId
    after $rebootTime

    set telnet1 [gwd::GWpublic_loginGpn $gpnIp1 $userName1 $password1 $matchType1 $Gpn_type1 $fileId]
    set lSpawn_id [lreplace $lSpawn_id 0 0 $telnet1]
    lappend flag1_Case7 [gwd::GW_GetRunConfig $telnet1 $matchType1 $dutType1 $fileId contentrun2 "60000"]
    set compareFilerun2 [open "log\\LSPBH_002_��������$matchType1\��Showrun.txt" w]
    puts $compareFilerun2 $contentrun2
    close $compareFilerun2
    # set showMpls 3
    # set showCfm 3
    # set showMlps 3
    # while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId result_mpls1]} {
    #   incr showMpls -1
    # }
    # while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "cfm" result_cfm1]} {
    #   incr showCfm -1
    # }
    # while {[gwd::GWpublic_showRunCfgInfo $telnet1 $matchType1 $Gpn_type1 $fileId "mlps" result_mlps1]} {
    #   incr showMlps -1
    # }
    # regexp {interface lsp tunnel Tunnel_101.*?exit} $result_mpls1 lsp101_tmp
    # regexp {interface lsp tunnel Tunnel_2101.*?exit} $result_mpls1 lsp2101_tmp
    # regexp {interface pw pw101.*?exit} $result_mpls1 pw101_tmp
    # regexp {interface ac ac101.*?exit} $result_mpls1 ac101_tmp
    # regexp {mpls-tp-meg meg1.*?exit} $result_cfm1 meg1_tmp
    # regexp {mpls-tp-meg meg2.*?exit} $result_cfm1 meg2_tmp
    # regexp {create pro-grp ac101.*?exit} $result_mlps1 pro-grp101_tmp
    # if {[string match $lsp101 $lsp101_tmp]} {
    #   gwd::GWpublic_print "OK" "��������ǰ��Tunnel_101������û�з����仯" $fileId
    # } else {
    #   set flag1_Case6 1
    #   gwd::GWpublic_print "NOK" "��������ǰ��Tunnel_101�����ݷ����仯" $fileId
    # }
    # if {[string match $lsp2101 $lsp2101_tmp]} {
    #   gwd::GWpublic_print "OK" "��������ǰ��Tunnel_2101������û�з����仯" $fileId
    # } else {
    #   set flag1_Case6 1
    #   gwd::GWpublic_print "NOK" "��������ǰ��Tunnel_2101�����ݷ����仯" $fileId
    # }
    # if {[string match $pw101 $pw101_tmp]} {
    #   gwd::GWpublic_print "OK" "��������ǰ��pw101������û�з����仯" $fileId
    # } else {
    #   set flag1_Case6 1
    #   gwd::GWpublic_print "NOK" "��������ǰ��pw101�����ݷ����仯" $fileId
    # }
    # if {[string match $ac101 $ac101_tmp]} {
    #   gwd::GWpublic_print "OK" "��������ǰ��ac01������û�з����仯" $fileId
    # } else {
    #   set flag1_Case6 1
    #   gwd::GWpublic_print "NOK" "��������ǰ��ac101�����ݷ����仯" $fileId
    # }
    # if {[string match $meg1 $meg1_tmp]} {
    #   gwd::GWpublic_print "OK" "��������ǰ��meg1������û�з����仯" $fileId
    # } else {
    #   set flag1_Case6 1
    #   gwd::GWpublic_print "NOK" "��������ǰ��meg1�����ݷ����仯" $fileId
    # }
    # if {[string match $meg2 $meg2_tmp]} {
    #   gwd::GWpublic_print "OK" "��������ǰ��meg2������û�з����仯" $fileId
    # } else {
    #   set flag1_Case6 1
    #   gwd::GWpublic_print "NOK" "��������ǰ��meg2�����ݷ����仯" $fileId
    # }






    if {"1" in $flag1_Case7} {
        set flagCase7 1
    }
    puts $fileId ""
    gwd::GWpublic_print \n[expr {([regexp {[^0\s]} $flagCase7] == 1)? "NOK":"OK"}] "Test Case 7 ���Խ���" $fileId
    puts $fileId ""
    gwd::GWpublic_sendSameStrToFiles "$fd_debug $fd_log $fileId" "Test Case 7 ����/SW�����Թ���Ӱ�� ���Խ���\n"
    puts $fileId "**************************************************************************************\n"
    puts $fileId "**************************************************************************************\n"
