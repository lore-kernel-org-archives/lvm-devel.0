From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Oct 2009 13:07:50 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c
Message-ID: <20091030130750.365.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-30 13:07:49

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c 

Log message:
	Insert some missing stack macros into activation code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1308&r2=1.1309
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.157&r2=1.158

--- LVM2/WHATS_NEW	2009/10/27 17:00:44	1.1308
+++ LVM2/WHATS_NEW	2009/10/30 13:07:49	1.1309
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Insert some missing stack macros into activation code.
   Recognise DRBD device part and handle it similar to MD devices.
 
 Version 2.02.54 - 26th October 2009
--- LVM2/lib/activate/activate.c	2009/10/16 17:41:50	1.157
+++ LVM2/lib/activate/activate.c	2009/10/30 13:07:49	1.158
@@ -936,7 +936,7 @@
 		return 1;
 
 	if (!(lv = lv_from_lvid(cmd, lvid_s, 0)))
-		goto out;
+		goto_out;
 
 	if (test_mode()) {
 		_skip("Resuming '%s'.", lv->name);
@@ -949,11 +949,11 @@
 
 	if (!info.exists || !info.suspended) {
 		r = error_if_not_active ? 0 : 1;
-		goto out;
+		goto_out;
 	}
 
 	if (!_lv_activate_lv(lv))
-		goto out;
+		goto_out;
 
 	memlock_dec();
 	fs_unlock();
@@ -1138,7 +1138,8 @@
 		lv->status |= ACTIVATE_EXCL;
 
 	memlock_inc();
-	r = _lv_activate_lv(lv);
+	if (!(r = _lv_activate_lv(lv)))
+		stack;
 	memlock_dec();
 	fs_unlock();
 
@@ -1155,13 +1156,19 @@
 /* Activate LV */
 int lv_activate(struct cmd_context *cmd, const char *lvid_s, int exclusive)
 {
-	return _lv_activate(cmd, lvid_s, exclusive, 0);
+	if (!_lv_activate(cmd, lvid_s, exclusive, 0))
+		return_0;
+
+	return 1;
 }
 
 /* Activate LV only if it passes filter */
 int lv_activate_with_filter(struct cmd_context *cmd, const char *lvid_s, int exclusive)
 {
-	return _lv_activate(cmd, lvid_s, exclusive, 1);
+	if (!_lv_activate(cmd, lvid_s, exclusive, 1))
+		return_0;
+
+	return 1;
 }
 
 int lv_mknodes(struct cmd_context *cmd, const struct logical_volume *lv)


