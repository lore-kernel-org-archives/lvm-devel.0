From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 17 Mar 2010 14:45:29 -0000
Subject: LVM2 ./WHATS_NEW liblvm/lvm_base.c
Message-ID: <20100317144529.23645.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-17 14:45:28

Modified files:
	.              : WHATS_NEW 
	liblvm         : lvm_base.c 

Log message:
	Disable long living process flag in lvm2app.
	
	This option should be configurable, but for now
	do not set it at all.
	
	(lvm2app is used in udisks probers and there
	cac cause several nasty races when trying to update
	lvmcache during rescan.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1466&r2=1.1467
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/WHATS_NEW	2010/03/17 14:44:18	1.1466
+++ LVM2/WHATS_NEW	2010/03/17 14:45:28	1.1467
@@ -1,5 +1,6 @@
 Version 2.02.63 - 
 ================================
+  Disable long living process flag in lvm2app.
   Fix pvcreate device md filter check.
   Suppress repeated errors about the same missing PV uuids.
   Bypass full device scans when using internally-cached VG metadata.
--- LVM2/liblvm/lvm_base.c	2010/01/22 09:45:29	1.14
+++ LVM2/liblvm/lvm_base.c	2010/03/17 14:45:28	1.15
@@ -32,7 +32,8 @@
 
 	/* create context */
 	/* FIXME: split create_toolcontext */
-	cmd = create_toolcontext(1, system_dir);
+	/* FIXME: make all globals configurable */
+	cmd = create_toolcontext(0, system_dir);
 	if (!cmd)
 		return NULL;
 


