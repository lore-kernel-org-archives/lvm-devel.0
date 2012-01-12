From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2012 16:58:45 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c lib/display ...
Message-ID: <20120112165845.5475.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-12 16:58:45

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c 
	lib/display    : display.c 
	man            : lvs.8.in 

Log message:
	Show read-only activation in display tools.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2220&r2=1.2221
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/WHATS_NEW	2012/01/12 01:51:56	1.2220
+++ LVM2/WHATS_NEW	2012/01/12 16:58:43	1.2221
@@ -1,5 +1,7 @@
 Version 2.02.89 - 
 ==================================
+  Use R lv_attr to indicate read-only activation of non-read-only device in lvs.
+  Show read-only activation override in lvdisplay & add 4 to perms in -c.
   Add activation/read_only_volume_list to override LV permission in metadata.
   Give priority to emcpower devices with duplicate PVIDs.
   Add check for error in _adjust_policy_params() (lvextend --use-policies).
--- LVM2/lib/metadata/lv.c	2011/09/23 15:17:54	1.29
+++ LVM2/lib/metadata/lv.c	2012/01/12 16:58:44	1.30
@@ -431,6 +431,13 @@
 				repstr[4] = 'I'; /* Invalid snapshot */
 		}
 
+		/*
+		 * 'R' indicates read-only activation of a device that
+		 * does not have metadata flagging it as read-only.
+		 */
+		if (repstr[1] != 'r' && info.read_only)
+			repstr[1] = 'R';
+
 		repstr[5] = (info.open_count) ? 'o' : '-';
 	} else {
 		repstr[4] = '-';
--- LVM2/lib/display/display.c	2011/11/23 01:34:38	1.122
+++ LVM2/lib/display/display.c	2012/01/12 16:58:44	1.123
@@ -485,7 +485,8 @@
 		  lv->vg->name,
 		  lv->name,
 		  lv->vg->name,
-		  (lv->status & (LVM_READ | LVM_WRITE)) >> 8, inkernel ? 1 : 0,
+		  ((lv->status & (LVM_READ | LVM_WRITE)) >> 8) |
+		  ((inkernel & info.read_only) ? 4 : 0), inkernel ? 1 : 0,
 		  /* FIXME lv->lv_number,  */
 		  inkernel ? info.open_count : 0, lv->size, lv->le_count,
 		  /* FIXME Add num allocated to struct! lv->lv_allocated_le, */
@@ -500,6 +501,7 @@
 	struct lvinfo info;
 	int inkernel, snap_active = 0;
 	char uuid[64] __attribute__((aligned(8)));
+	const char *access_str;
 	struct lv_segment *snap_seg = NULL, *mirror_seg = NULL;
 	percent_t snap_percent;
 
@@ -508,6 +510,13 @@
 
 	inkernel = lv_info(cmd, lv, 0, &info, 1, 1) && info.exists;
 
+	if ((lv->status & LVM_WRITE) && inkernel && info.read_only)
+		access_str = "read/write (activated read only)";
+	else if (lv->status & LVM_WRITE)
+		access_str = "read/write";
+	else
+		access_str = "read only";
+
 	log_print("--- Logical volume ---");
 
 	log_print("LV Name                %s%s/%s", lv->vg->cmd->dev_dir,
@@ -516,8 +525,7 @@
 
 	log_print("LV UUID                %s", uuid);
 
-	log_print("LV Write Access        %s",
-		  (lv->status & LVM_WRITE) ? "read/write" : "read only");
+	log_print("LV Write Access        %s", access_str);
 
 	if (lv_is_origin(lv)) {
 		log_print("LV snapshot status     source of");
--- LVM2/man/lvs.8.in	2011/11/08 12:16:53	1.18
+++ LVM2/man/lvs.8.in	2012/01/12 16:58:44	1.19
@@ -94,7 +94,8 @@
 under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
 thin pool m(e)tadata
 .IP 2 3
-Permissions: (w)riteable, (r)ead-only
+Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
+volume
 .IP 3 3
 Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
 This is capitalised if the volume is currently locked against allocation


