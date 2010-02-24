From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Feb 2010 20:01:41 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/activate.c lib/a ...
Message-ID: <20100224200141.12703.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-02-24 20:01:41

Modified files:
	.              : WHATS_NEW 
	lib/activate   : activate.c activate.h 
	tools          : vgrename.c 

Log message:
	Remove lvs_in_vg_activated_by_uuid_only call.
	
	There is no difference from lvs_in_vg_activated now,
	convert all users to this call.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1438&r2=1.1439
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.64&r2=1.65
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70

--- LVM2/WHATS_NEW	2010/02/24 20:00:56	1.1438
+++ LVM2/WHATS_NEW	2010/02/24 20:01:40	1.1439
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Remove lvs_in_vg_activated_by_uuid_only call.
   Run device info query device by uuid only.
   Don't touch /dev in vgmknodes if activation is disabled.
   Update lvm2app.h Doxygen comments and add lvm2app Doxygen config file.
--- LVM2/lib/activate/activate.c	2010/02/24 20:00:56	1.165
+++ LVM2/lib/activate/activate.c	2010/02/24 20:01:41	1.166
@@ -171,10 +171,6 @@
 {
 	return 0;
 }
-int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg)
-{
-	return 0;
-}
 int lvs_in_vg_opened(struct volume_group *vg)
 {
 	return 0;
@@ -627,7 +623,7 @@
  * These two functions return the number of visible LVs in the state,
  * or -1 on error.
  */
-static int _lvs_in_vg_activated(struct volume_group *vg, unsigned by_uuid_only)
+int lvs_in_vg_activated(struct volume_group *vg)
 {
 	struct lv_list *lvl;
 	int count = 0;
@@ -643,16 +639,6 @@
 	return count;
 }
 
-int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg)
-{
-	return _lvs_in_vg_activated(vg, 1);
-}
-
-int lvs_in_vg_activated(struct volume_group *vg)
-{
-	return _lvs_in_vg_activated(vg, 0);
-}
-
 int lvs_in_vg_opened(const struct volume_group *vg)
 {
 	const struct lv_list *lvl;
--- LVM2/lib/activate/activate.h	2009/10/01 00:35:29	1.64
+++ LVM2/lib/activate/activate.h	2010/02/24 20:01:41	1.65
@@ -91,7 +91,6 @@
  * Return number of LVs in the VG that are active.
  */
 int lvs_in_vg_activated(struct volume_group *vg);
-int lvs_in_vg_activated_by_uuid_only(struct volume_group *vg);
 int lvs_in_vg_opened(const struct volume_group *vg);
 
 int lv_is_active(struct logical_volume *lv);
--- LVM2/tools/vgrename.c	2010/02/03 14:08:40	1.69
+++ LVM2/tools/vgrename.c	2010/02/24 20:01:41	1.70
@@ -29,7 +29,7 @@
 		return_NULL;
 	}
 
-	if (lvs_in_vg_activated_by_uuid_only(vg)) {
+	if (lvs_in_vg_activated(vg)) {
 		unlock_and_release_vg(cmd, vg, vg_name_old);
 		log_error("Volume group \"%s\" still has active LVs",
 			  vg_name_old);
@@ -161,7 +161,7 @@
 		if (test_mode())
 			log_verbose("Test mode: Skipping rename.");
 
-		else if (lvs_in_vg_activated_by_uuid_only(vg)) {
+		else if (lvs_in_vg_activated(vg)) {
 			if (!vg_refresh_visible(cmd, vg)) {
 				log_error("Renaming \"%s\" to \"%s\" failed", 
 					old_path, new_path);


