From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Oct 2011 14:31:49 -0000
Subject: LVM2/daemons/dmeventd/plugins/snapshot dmevent ...
Message-ID: <20111019143149.7580.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-10-19 14:31:49

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Remove a redundant (and in some cases, misleading) message about snapshot
	extension, in the snapshot dmeventd plugin. The reporting is done as needed by
	the LVM command nowadays.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/04/08 14:18:40	1.15
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/10/19 14:31:49	1.16
@@ -119,7 +119,6 @@
 {
 	char *vg = NULL, *lv = NULL, *layer = NULL;
 	char cmd_str[1024];
-	int r = 0;
 
 	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
 		syslog(LOG_ERR, "Unable to determine VG name from %s.", device);
@@ -131,10 +130,7 @@
 		return 0;
 	}
 
-	r = dmeventd_lvm2_run(cmd_str);
-	syslog(LOG_INFO, "Extension of snapshot %s/%s %s.", vg, lv,
-	       (r == ECMD_PROCESSED) ? "finished successfully" : "failed");
-	return r == ECMD_PROCESSED;
+	return dmeventd_lvm2_run(cmd_str) == ECMD_PROCESSED;
 }
 
 static void _umount(const char *device, int major, int minor)


