From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Aug 2010 13:56:35 -0000
Subject: LVM2 Makefile.in WHATS_NEW
Message-ID: <20100802135635.29161.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-02 13:56:35

Modified files:
	.              : Makefile.in WHATS_NEW 

Log message:
	Fix lib.device-mapper to wait for include too

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1685&r2=1.1686

--- LVM2/Makefile.in	2010/08/02 12:10:36	1.60
+++ LVM2/Makefile.in	2010/08/02 13:56:34	1.61
@@ -49,6 +49,7 @@
 tools: lib device-mapper
 po: tools daemons
 
+lib.device-mapper: include.device-mapper
 libdm.device-mapper: include.device-mapper
 liblvm.device-mapper: include.device-mapper
 daemons.device-mapper: libdm.device-mapper
--- LVM2/WHATS_NEW	2010/08/02 13:17:03	1.1685
+++ LVM2/WHATS_NEW	2010/08/02 13:56:35	1.1686
@@ -3,7 +3,7 @@
   Do not use VPATH in include/Makefile.
   Fix exported_symbols generation to use standard compiler arguments.
   Use #include <> not "" in lvm2app.h which gets installed on the system.
-  Make liblvm.device-mapper wait for include file generation.
+  Make lib and liblvm.device-mapper wait for include file generation.
   Fix configure to supply DEFAULT_RUN_DIR to Makefiles.
   Fix wrong number of mirror log at allocate policy
 


