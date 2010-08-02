From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Aug 2010 13:17:06 -0000
Subject: LVM2 ./WHATS_NEW include/Makefile.in
Message-ID: <20100802131706.5986.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-02 13:17:04

Modified files:
	.              : WHATS_NEW 
	include        : Makefile.in 

Log message:
	Do not use VPATH in include/Makefile

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1684&r2=1.1685
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/WHATS_NEW	2010/08/02 12:57:04	1.1684
+++ LVM2/WHATS_NEW	2010/08/02 13:17:03	1.1685
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Do not use VPATH in include/Makefile.
   Fix exported_symbols generation to use standard compiler arguments.
   Use #include <> not "" in lvm2app.h which gets installed on the system.
   Make liblvm.device-mapper wait for include file generation.
--- LVM2/include/Makefile.in	2010/03/29 14:11:18	1.13
+++ LVM2/include/Makefile.in	2010/08/02 13:17:04	1.14
@@ -17,7 +17,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 LN_S = @LN_S@
 


