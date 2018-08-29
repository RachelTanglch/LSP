

##主进程传入的参数
set gpnIp1 [lindex $argv 0] ;		   #GpnIp：GPN1的IP地址
set userName1 [lindex $argv 1] ;	   #用户名
set password1 [lindex $argv 2] ;	   #密码
set matchType1 [lindex $argv 3] ;	   #hostname
set Gpn_type1 [lindex $argv 4] ;	   #类型
   
set managePort1 [lindex $argv 5] ;	   #管理端口
   
set GPNPortList [lindex $argv 6] ;	   #用到的端口集合
set ftp [lindex $argv 7] ;			   
set Worklevel [lindex $argv 8] ;	   
set SoftVer [lindex $argv 9] ;		   
set trunkLevel [lindex $argv 10] ;	   
set lDev1TestPort [lindex $argv 11] ;  

#Case 2 后用到的变量
set gpnIp2 [lindex $argv 12] ;  
set userName2 [lindex $argv 13] ;	
set password2 [lindex $argv 14] ;	
set matchType2 [lindex $argv 15] ;	
set Gpn_type2 [lindex $argv 16] ;	

set gpnIp3 [lindex $argv 17] ;      
set userName3 [lindex $argv 18] ;	
set password3 [lindex $argv 19] ;	
set matchType3 [lindex $argv 20] ;	
set Gpn_type3 [lindex $argv 21] ;	

set gpnIp4 [lindex $argv 22] ;      
set userName4 [lindex $argv 23] ;	
set password4 [lindex $argv 24] ;	
set matchType4 [lindex $argv 25] ;	
set Gpn_type4 [lindex $argv 26] ;	

set stcIp [lindex $argv 27] ;
set GPNStcPort1 [lindex $argv 28] ;
set GPNTestEth1 [lindex $argv 29] ;
set GPNEth1Media [lindex $argv 30] ;

set GPNStcPort2 [lindex $argv 31] ;
set GPNTestEth2 [lindex $argv 32] ;
set GPNEth2Media [lindex $argv 33] ; 

set managePort2 [lindex $argv 34] ;
set managePort3 [lindex $argv 35] ;
set managePort4 [lindex $argv 36] ;

set GPNTestEthMgt [lindex $argv 37] ;
set lsp_num [lindex $argv38] ; ###lsp组数标志位
set GPNPort1 [dict get $GPNPortList GPNPort1]
set GPNPort2 [dict get $GPNPortList GPNPort2]
set GPNPort3 [dict get $GPNPortList GPNPort3]
set GPNPort4 [dict get $GPNPortList GPNPort4]
set GPNPort5 [dict get $GPNPortList GPNPort5]
set GPNPort6 [dict get $GPNPortList GPNPort6]
set GPNPort7 [dict get $GPNPortList GPNPort7]
set GPNPort8 [dict get $GPNPortList GPNPort8]
set GPNPort9 [dict get $GPNPortList GPNPort9]
set GPNPort10 [dict get $GPNPortList GPNPort10]
set GPNPort11 [dict get $GPNPortList GPNPort11]
set GPNPort12 [dict get $GPNPortList GPNPort12]
set GPNPort13 [dict get $GPNPortList GPNPort13]
set GPNPort14 [dict get $GPNPortList GPNPort14]
set GPNPort15 [dict get $GPNPortList GPNPort15]
set GPNPort16 [dict get $GPNPortList GPNPort16]
set GPNPort17 [dict get $GPNPortList GPNPort17]
set GPNPort18 [dict get $GPNPortList GPNPort18]
set GPNPort19 [dict get $GPNPortList GPNPort19]
set GPNPort20 [dict get $GPNPortList GPNPort20]





set cap_enable 1;#抓包使能标识 =1：抓包， =0：不抓包
match_max -d 20000000
set porttype3 "GE";#ELINE业务ac端口3的属性:GE/8FX
set porttype4 "GE";#ELINE业务ac端口4的属性:GE/8FX
#regexp -nocase {([0-9]+)/([0-9]+)} $GPNTestEth3 match slot3 port3
#regexp -nocase {([0-9]+)/([0-9]+)} $GPNTestEth4 match slot4 port4


set cnt 1   ;#设备或者板卡重启的次数
set cntdh 2 ;#主备倒换的次数
set errRate 0.1;#允许误差的范围
set ptn004_case2_cnt 2 ;#反复添加删除E-LINE实例的次数
set ptn008_case2_cnt 2 ;#ELAN与trunk互操作中up、down端口的次数
set ptn009_case2_cnt 1 ;#ELAN稳定性测试中反复增删ELAN业务配置的次数
set ptn013_case2_cnt 2 ;#ELAN稳定性测试中反复增删ETREE业务配置的次数
set sendTime 60000;#性能统计时间

set WaiteTime 60000 ;#等待时间
set WaiteTime1 25000 ;#等待时间
#set WaiteTime8 300000 ;#等待时间
set rebootTime 300000;#重启设备的时间
set rebootBoardTime 45000;#重启板卡的时间


set VsiNum 1024;#配置vsi的个数
set AcNum 1024 ;#配置ac的个数
set pwNum 1024 ;#配置pw的个数
set RoleList "none leaf leaf leaf" ;#E-TREE业务ac的角色列表
set RoleList1 "leaf none leaf leaf";#E-TREE业务ac的角色列表


set Matchlist "$matchType1"

set macount 32000;#vsi中配置mac地址学习的最大容量

set cap_enable 1








