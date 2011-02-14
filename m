From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Feb 2011 14:26:37 -0000
Subject: LVM2/daemons/dmeventd/plugins/snapshot dmevent ...
Message-ID: <20110214142637.23726.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-02-14 14:26:37

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Avoid flooding syslog with redundant messages when a snapshot is invalidated
	(reported by Corey).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/11/23 21:19:45	1.13
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/02/14 14:26:36	1.14
@@ -200,7 +200,6 @@
 	_parse_snapshot_params(params, &status);
 
 	if (status.invalid) {
-		syslog(LOG_ERR, "Trying to umount invalid snapshot %s...\n", device);
 		struct dm_info info;
 		if (dm_task_get_info(dmt, &info)) {
 			dmeventd_lvm2_unlock();


