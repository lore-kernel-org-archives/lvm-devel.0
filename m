From: ccaulfield@sourceware.org <ccaulfield@sourceware.org>
Date: 29 Jan 2009 15:23:16 -0000
Subject: LVM2 WHATS_NEW configure.in
Message-ID: <20090129152316.9958.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	ccaulfield at sourceware.org	2009-01-29 15:23:16

Modified files:
	.              : WHATS_NEW configure.in 

Log message:
	Mention --with-clvmd=corosync in ./configure

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1030&r2=1.1031
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW	2009/01/26 22:42:59	1.1030
+++ LVM2/WHATS_NEW	2009/01/29 15:23:15	1.1031
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Mention --with-clvmd=corosync in ./configure
   Replace internal vg_check_status() implementation.
   Rename vg_read() to vg_read_internal().
 
--- LVM2/configure.in	2009/01/20 17:07:53	1.93
+++ LVM2/configure.in	2009/01/29 15:23:15	1.94
@@ -324,7 +324,7 @@
 dnl -- Build cluster LVM daemon
 AC_MSG_CHECKING(whether to build cluster LVM daemon)
 AC_ARG_WITH(clvmd,
-  [  --with-clvmd=TYPE       Build cluster LVM Daemon: cman/gulm/none/all
+  [  --with-clvmd=TYPE       Build cluster LVM Daemon: cman/gulm/corosync/none/all
                           [TYPE=none] ],
   [ CLVMD="$withval" ],
   [ CLVMD="none" ])


