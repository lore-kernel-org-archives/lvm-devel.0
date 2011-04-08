From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2011 14:18:41 -0000
Subject: LVM2/daemons/dmeventd/plugins/snapshot dmevent ...
Message-ID: <20110408141841.13859.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-08 14:18:40

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Use dm_snprintf
	
	and fix differently signed comparation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/02/14 14:26:36	1.14
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2011/04/08 14:18:40	1.15
@@ -125,8 +125,8 @@
 		syslog(LOG_ERR, "Unable to determine VG name from %s.", device);
 		return 0;
 	}
-	if (sizeof(cmd_str) <= snprintf(cmd_str, sizeof(cmd_str),
-					"lvextend --use-policies %s/%s", vg, lv)) {
+	if (dm_snprintf(cmd_str, sizeof(cmd_str),
+			"lvextend --use-policies %s/%s", vg, lv) < 0) {
 		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
 		return 0;
 	}


