From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 Feb 2012 11:24:10 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/libdevmap ...
Message-ID: <20120213112410.28416.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-13 11:24:09

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Check for missing reply_uuid

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.554&r2=1.555
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/WHATS_NEW_DM	2012/02/13 11:18:46	1.554
+++ LVM2/WHATS_NEW_DM	2012/02/13 11:24:09	1.555
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Check for missing reply_uuid in dm_event_get_registered_device().
   Check for allocation failure in dmeventd restart().
   Add few missing allocation failures tests in dmsetup.
   Fix potential risk of writing in front of buffer in _sysfs_get_dm_name().
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/10 15:17:52	1.43
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/02/13 11:24:09	1.44
@@ -743,6 +743,10 @@
 	msg.data = NULL;
 
 	_dm_event_handler_clear_dev_info(dmevh);
+	if (!reply_uuid) {
+		ret = -ENXIO; /* dmeventd probably gave us bogus uuid back */
+		goto fail;
+	}
 	dmevh->uuid = dm_strdup(reply_uuid);
 	if (!dmevh->uuid) {
 		ret = -ENOMEM;


