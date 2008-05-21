From: agk@sourceware.org <agk@sourceware.org>
Date: 21 May 2008 14:10:12 -0000
Subject: LVM2 ./WHATS_NEW tools/lvchange.c
Message-ID: <20080521141012.15733.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-05-21 14:10:11

Modified files:
	.              : WHATS_NEW 
	tools          : lvchange.c 

Log message:
	Temporarily disable dmeventd mirror monitoring during lvchange --resync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.875&r2=1.876
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91

--- LVM2/WHATS_NEW	2008/05/19 19:49:56	1.875
+++ LVM2/WHATS_NEW	2008/05/21 14:10:11	1.876
@@ -6,6 +6,7 @@
 
 Version 2.02.37 - 
 =================================
+  Temporarily disable dmeventd mirror monitoring during lvchange --resync.
   Refactor some vginfo manipulation code.
   Add assertions to trap deprecated P_ and V_ lock usage.
   Add missing mutex around clvmd lvmcache_drop_metadata library call.
--- LVM2/tools/lvchange.c	2008/04/10 17:09:32	1.90
+++ LVM2/tools/lvchange.c	2008/05/21 14:10:11	1.91
@@ -178,6 +178,7 @@
 			      struct logical_volume *lv)
 {
 	int active = 0;
+	int monitored;
 	struct lvinfo info;
 	struct logical_volume *log_lv;
 
@@ -221,6 +222,10 @@
 		}
 	}
 
+	/* Activate exclusively to ensure no nodes still have LV active */
+	monitored = dmeventd_monitor_mode();
+	init_dmeventd_monitor(0);
+
 	if (vg_is_clustered(lv->vg) && !activate_lv_excl(cmd, lv)) {
 		log_error("Can't get exclusive access to clustered volume %s",
 			  lv->name);
@@ -232,6 +237,8 @@
 		return 0;
 	}
 
+	init_dmeventd_monitor(monitored);
+
 	log_lv = first_seg(lv)->log_lv;
 
 	log_very_verbose("Starting resync of %s%s%s mirror \"%s\"",


