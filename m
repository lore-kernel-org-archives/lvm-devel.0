From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 Aug 2011 13:30:36 -0000
Subject: LVM2/lib/raid raid.c
Message-ID: <20110811133036.24806.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-08-11 13:30:36

Modified files:
	lib/raid       : raid.c 

Log message:
	Fix build of raid without dmeventd.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/raid/raid.c	2011/08/11 05:00:22	1.2
+++ LVM2/lib/raid/raid.c	2011/08/11 13:30:36	1.3
@@ -302,13 +302,17 @@
 	.text_export = _raid_text_export,
 	.add_target_line = _raid_add_target_line,
 	.target_status_compatible = _raid_target_status_compatible,
+#ifdef DEVMAPPER_SUPPORT
 	.target_percent = _raid_target_percent,
 	.target_present = _raid_target_present,
-	.modules_needed = _raid_modules_needed,
-	.destroy = _raid_destroy,
+#  ifdef DMEVENTD
 	.target_monitored = _raid_target_monitored,
 	.target_monitor_events = _raid_target_monitor_events,
 	.target_unmonitor_events = _raid_target_unmonitor_events,
+#  endif        /* DMEVENTD */
+#endif
+	.modules_needed = _raid_modules_needed,
+	.destroy = _raid_destroy,
 };
 
 static struct segment_type *init_raid_segtype(struct cmd_context *cmd,


