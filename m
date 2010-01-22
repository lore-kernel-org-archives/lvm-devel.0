From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jan 2010 13:20:33 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20100122132033.7483.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-22 13:20:33

Modified files:
	.              : make.tmpl.in 

Log message:
	Switch memory debugging off for now if compiled with dmeventd,
	functions are not thread-safe in debug mode.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/make.tmpl.in	2010/01/19 01:10:46	1.74
+++ LVM2/make.tmpl.in	2010/01/22 13:20:32	1.75
@@ -78,7 +78,10 @@
 ifeq ("@DEBUG@", "yes")
   CFLAGS += -g -fno-omit-frame-pointer
   DEFS += -DDEBUG
-  DEFS += -DDEBUG_MEM
+  # memory debugging is not thread-safe yet
+  ifneq ("@DMEVENTD@", "yes")
+    DEFS += -DDEBUG_MEM
+  endif
 endif
 
 ifeq ("@INTL@", "yes")


