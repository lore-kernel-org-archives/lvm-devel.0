From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 12:33:56 -0000
Subject: LVM2 ./WHATS_NEW lib/report/properties.c
Message-ID: <20110105123356.3167.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 12:33:53

Modified files:
	.              : WHATS_NEW 
	lib/report     : properties.c 

Log message:
	Return PERCENT_INVALID for error case
	
	If the percent value could not be determined return PERCENT_INVALID.
	Indent function with tabs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1857&r2=1.1858
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW	2011/01/04 21:33:06	1.1857
+++ LVM2/WHATS_NEW	2011/01/05 12:33:51	1.1858
@@ -1,5 +1,6 @@
 Version 2.02.80 - 
 ====================================
+  Return defined value for errors in _copy_percent() and _snap_percent().
   Correct return code of cmirrord when issuing 'start' when already running.
   Fix wrongly paired unlocking of global lock in pvchange. (2.02.66)
   Add backtraces for backup and backup_remove fail paths.
--- LVM2/lib/report/properties.c	2010/12/14 23:20:58	1.27
+++ LVM2/lib/report/properties.c	2011/01/05 12:33:52	1.28
@@ -87,15 +87,18 @@
 }
 
 static percent_t _copy_percent(const struct logical_volume *lv) {
-    percent_t perc;
-    lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv, 0, &perc, NULL);
-    return perc;
+	percent_t perc;
+	if (!lv_mirror_percent(lv->vg->cmd, (struct logical_volume *) lv,
+			   0, &perc, NULL))
+		perc = PERCENT_INVALID;
+	return perc;
 }
 
 static percent_t _snap_percent(const struct logical_volume *lv) {
-    percent_t perc;
-    lv_snapshot_percent(lv, &perc);
-    return perc;
+	percent_t perc;
+	if (!lv_snapshot_percent(lv, &perc))
+		perc = PERCENT_INVALID;
+	return perc;
 }
 
 /* PV */


