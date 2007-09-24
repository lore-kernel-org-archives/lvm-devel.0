From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Sep 2007 21:30:01 -0000
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
Message-ID: <20070924213001.16215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-09-24 21:30:00

Modified files:
	lib/metadata   : lv_manip.c metadata-exported.h pv_manip.c 
	tools          : lvcreate.c lvresize.c 

Log message:
	Some const fixups for previous checkins

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.148&r2=1.149
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.83&r2=1.84

--- LVM2/lib/metadata/lv_manip.c	2007/08/28 16:14:48	1.128
+++ LVM2/lib/metadata/lv_manip.c	2007/09/24 21:30:00	1.129
@@ -1803,7 +1803,7 @@
 }
 
 int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
-		     force_t force)
+		     const force_t force)
 {
 	struct volume_group *vg;
 	struct lvinfo info;
--- LVM2/lib/metadata/metadata-exported.h	2007/09/20 21:39:07	1.15
+++ LVM2/lib/metadata/metadata-exported.h	2007/09/24 21:30:00	1.16
@@ -330,7 +330,7 @@
 	       uint64_t label_sector);
 
 /* FIXME: move internal to library */
-uint32_t pv_list_extents_free(struct list *pvh);
+uint32_t pv_list_extents_free(const struct list *pvh);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
 			       uint32_t extent_size, uint32_t max_pv,
--- LVM2/lib/metadata/pv_manip.c	2007/09/20 21:39:07	1.13
+++ LVM2/lib/metadata/pv_manip.c	2007/09/24 21:30:00	1.14
@@ -218,8 +218,8 @@
  * Calculate the overlap, in extents, between a struct pv_segment and
  * a struct pe_range.
  */
-static uint32_t _overlap_pe(struct pv_segment *pvseg,
-			    struct pe_range *per)
+static uint32_t _overlap_pe(const struct pv_segment *pvseg,
+			    const struct pe_range *per)
 {
 	uint32_t start;
 	uint32_t end;
@@ -235,7 +235,7 @@
 /*
  * Returns: number of free PEs in a struct pv_list
  */
-uint32_t pv_list_extents_free(struct list *pvh)
+uint32_t pv_list_extents_free(const struct list *pvh)
 {
 	struct pv_list *pvl;
 	struct pe_range *per;
@@ -443,7 +443,7 @@
 int pv_resize_single(struct cmd_context *cmd,
 		     struct volume_group *vg,
 		     struct physical_volume *pv,
-		     uint64_t new_size)
+		     const uint64_t new_size)
 {
 	struct pv_list *pvl;
 	int consistent = 1;
--- LVM2/tools/lvcreate.c	2007/09/24 13:29:49	1.148
+++ LVM2/tools/lvcreate.c	2007/09/24 21:30:00	1.149
@@ -244,8 +244,8 @@
  * Generic mirror parameter checks.
  * FIXME: Should eventually be moved into lvm library.
  */
-static int _validate_mirror_params(struct cmd_context *cmd,
-				   struct lvcreate_params *lp)
+static int _validate_mirror_params(const struct cmd_context *cmd,
+				   const struct lvcreate_params *lp)
 {
 	int pagesize = lvm_getpagesize();
 
--- LVM2/tools/lvresize.c	2007/09/20 21:39:08	1.83
+++ LVM2/tools/lvresize.c	2007/09/24 21:30:00	1.84
@@ -47,7 +47,7 @@
 };
 
 static int validate_stripesize(struct cmd_context *cmd,
-			       struct volume_group *vg,
+			       const struct volume_group *vg,
 			       struct lvresize_params *lp)
 {
 	if (arg_sign_value(cmd, stripesize_ARG, 0) == SIGN_MINUS) {
@@ -87,9 +87,9 @@
 }
 
 static int confirm_resizefs_reduce(struct cmd_context *cmd,
-				   struct volume_group *vg,
-				   struct logical_volume *lv,
-				   struct lvresize_params *lp)
+				   const struct volume_group *vg,
+				   const struct logical_volume *lv,
+				   const struct lvresize_params *lp)
 {
 	struct lvinfo info;
 
@@ -131,8 +131,9 @@
 	return 1;
 }
 
-static int do_resizefs_reduce(struct cmd_context *cmd, struct volume_group *vg,
-			      struct lvresize_params *lp)
+static int do_resizefs_reduce(const struct cmd_context *cmd, 
+			      const struct volume_group *vg,
+			      const struct lvresize_params *lp)
 {
 	char lv_path[PATH_MAX];
 	char size_buf[SIZE_BUF];


