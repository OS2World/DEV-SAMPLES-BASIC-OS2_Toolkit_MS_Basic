@ECHO OFF
CD C:\PMBASIC\INCLUDE
BC /O C:\PMBASIC\CODE\%1,C:\PMBASIC\CODE\%1;
CD C:\PMBASIC\CODE
LINK %1,%1,%1,OS2.LIB REGBAS.LIB,%1
%1
