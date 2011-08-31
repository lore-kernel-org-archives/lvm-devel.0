From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Aug 2011 08:23:05 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20110831082305.11987.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-31 08:23:05

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Fix resource leak when strdup fails
	
	Static analyzer noticed, strdup failing path leaks dmt structure.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/daemons/dmeventd/dmeventd.c	2011/07/28 13:06:50	1.82
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/08/31 08:23:05	1.83
@@ -751,8 +751,10 @@
 	if (!dmt)
 		return NULL;
 
-	if (!dm_task_set_uuid(dmt, ts->device.uuid))
-                return NULL;
+	if (!dm_task_set_uuid(dmt, ts->device.uuid)) {
+		dm_task_destroy(dmt);
+		return NULL;
+	}
 
 	if (!dm_task_run(dmt)) {
 		dm_task_destroy(dmt);


