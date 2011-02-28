From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2011 19:47:23 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/dmeventd.c
Message-ID: <20110228194723.2144.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-28 19:47:23

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd: dmeventd.c 

Log message:
	Test result of dm_task_set_uuid

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1930&r2=1.1931
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/WHATS_NEW	2011/02/28 19:35:09	1.1930
+++ LVM2/WHATS_NEW	2011/02/28 19:47:22	1.1931
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Add test for failed allocation from dm_task_set_uuid() in dmeventd.
   Improve pvremove error message when PV belongs to a VG.
   Extend normal policy to allow mirror logs on same PVs as images if necessary.
   Improve cling policy to recognise PVs already used during the transaction.
--- LVM2/daemons/dmeventd/dmeventd.c	2011/01/17 23:14:05	1.74
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/02/28 19:47:22	1.75
@@ -387,7 +387,9 @@
 	if (!dmt)
 		return 0;
 
-	dm_task_set_uuid(dmt, ts->device.uuid);
+	if (!dm_task_set_uuid(dmt, ts->device.uuid))
+		goto fail;
+
 	if (!dm_task_run(dmt))
 		goto fail;
 
@@ -732,7 +734,8 @@
 	if (!dmt)
 		return NULL;
 
-	dm_task_set_uuid(dmt, ts->device.uuid);
+	if (!dm_task_set_uuid(dmt, ts->device.uuid))
+                return NULL;
 
 	if (!dm_task_run(dmt)) {
 		dm_task_destroy(dmt);


