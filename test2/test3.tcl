#!/bin/sh
# test3.tcl \
exec tclsh "$0" ${1+"$@"}
set lresult "
show mlps

Total pro-group num is 128

============================================Pro-grp Infomation==================
========================================================================
 grp-name                 grp-id   enable   status(L/R)  w-p
ath                 
  p-path                   cur-path WTR-Time Hold-Time ext-cmd
 ac1                      1        enabled  NR00 /NR00   Tunnel_1               
  Tunnel_2                 work     1        0         null   

============================================Pro-grp Infomation==================
========================================================================
 grp-name                 grp-id   enable   status(L/R)  w-path                 
  p-path                   cur-path WTR-Time Hold-Time ext-cmd
 ac2                      2        enabled  NR00 /NR00   Tunnel_3               
  Tunnel_4                 work     1        0         null   

============================================Pro-grp Infomation==================
========================================================================
 grp-name                 grp-id   enable   status(L/R)  w-path                 
  p-path                   cur-path WTR-Time Hold-Time ext-cmd
 ac3                      3        enabled  NR00 /NR00   Tunnel_5               
  Tunnel_6                 work     1        0         null   

============================================Pro-grp Infomation==================
========================================================================
 grp-name                 grp-id   enable   status(L/R)  w-path                 
  p-path                   cur-path WTR-Time Hold-Time ext-cmd
 ac4                      4        enabled  NR00 /NR00   Tunnel_7               
  Tunnel_8                 work     1        0         null   

============================================Pro-grp Infomation==================
========================================================================
 grp-name                 grp-id   enable   status(L/R)  w-path                 
  p-path                   cur-path WTR-Time Hold-Time ext-cmd
 ac5                      5        enabled
"
regexp -all -nocase {1 +enabled+\s+([a-z|\-]+)\d+.+} $lresult match tmpresult
puts $tmpresult