From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Mar 2010 11:36:49 -0000
Subject: LVM2/daemons/dmeventd libdevmapper-event.c
Message-ID: <20100324113649.29723.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-24 11:36:49

Modified files:
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Move declaration of struct dm_info info to declaration block.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31

--- LVM2/daemons/dmeventd/libdevmapper-event.c	2010/01/14 10:11:26	1.30
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2010/03/24 11:36:48	1.31
@@ -688,6 +688,7 @@
 	enum dm_event_mask reply_mask = 0;
 	struct dm_task *dmt = NULL;
 	struct dm_event_daemon_message msg = { 0, 0, NULL };
+	struct dm_info info;
 
 	if (!(dmt = _get_device_info(dmevh))) {
 		stack;
@@ -746,7 +747,6 @@
 		goto fail;
 	}
 
-	struct dm_info info;
 	if (!dm_task_get_info(dmt, &info)) {
 		ret = -1;
 		goto fail;


