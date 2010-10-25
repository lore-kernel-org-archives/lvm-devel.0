From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Oct 2010 13:54:34 -0000
Subject: LVM2 ./VERSION ./VERSION_DM ./WHATS_NEW ./WHAT ...
Message-ID: <20101025135434.15249.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-25 13:54:30

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 
	lib/display    : display.c display.h 
	lib/metadata   : lv.c metadata.c metadata.h vg.c 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.256&r2=1.257
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1774&r2=1.1775
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.418&r2=1.419
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.112&r2=1.113
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.h.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.407&r2=1.408
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.223&r2=1.224
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/VERSION	2010/09/27 19:09:34	1.256
+++ LVM2/VERSION	2010/10/25 13:54:29	1.257
@@ -1 +1 @@
-2.02.75(2)-cvs (2010-09-24)
+2.02.75(2)-cvs (2010-10-25)
--- LVM2/VERSION_DM	2010/09/27 19:09:34	1.65
+++ LVM2/VERSION_DM	2010/10/25 13:54:29	1.66
@@ -1 +1 @@
-1.02.56-cvs (2010-09-24)
+1.02.56-cvs (2010-10-25)
--- LVM2/WHATS_NEW	2010/10/25 13:10:13	1.1774
+++ LVM2/WHATS_NEW	2010/10/25 13:54:29	1.1775
@@ -1,5 +1,6 @@
-Version 2.02.75 - 
-=====================================
+Version 2.02.75 - 25th October 2010
+===================================
+  Annotate more variables and parameters as const.
   Fix missing variable initialization in cluster_send() function from cmirrord.
   Fix pointer for VG name in _pv_resize_single error code path.
   Fix warning for changed alignment requirements for dmeventd read/write func.
@@ -7,37 +8,40 @@
   Don't take write lock in vgchange --refresh, --poll or --monitor.
   Skip dm devices in scan if they contain only error targets or are empty.
   Fix strict-aliasing compile warning in partition table scanning.
-  Add an option to automatically extend snapshots through dmeventd.
-  Remove dependency on libm, floor() is replaced with integer algorithm.
+  Fix pthread mutex usage deadlock in clvmd.
+  Automatically extend snapshots with dmeventd according to policy in lvm.conf.
+  Add activation/snapshot_autoextend_threshold/percent to lvm.conf.
+  Fix liblvm2cmd link order to support --as-needed.
+  Remove dependency on libm by replacing floor() by an integer-based algorithm.
   Fix hang when repairing a mirrored-log that had both devs fail.
   Convey need for snapshot-merge target in lvconvert error message and man page.
-  Add "devices/disable_after_error_count" to lvm.conf.
+  Add devices/disable_after_error_count config to limit access to failing devs.
   Give correct error message when creating a too-small snapshot.
-  Implement vgextend --restoremissing.
+  Implement vgextend --restoremissing to reinstate missing devs that return.
+  Make lvconvert respect --yes and --force when converting an inactive log.
   Refactor and add 'get' functions for lv properties/fields.
   Update script for fsadm testing.
   Better support of noninteractive shell execution of fsadm.
   Fix usage of --yes flag for ReiserFS resize in fsadm.
   Fix detection of mounted filesystems for fsadm when udev is used.
-  Fix assignment of default value to LVM variable is fsadm.
+  Fix assignment of default value to LVM variable in fsadm.
   Fix support for --yes flag for fsadm.
-  Do not execute lvresize with --dry-run option for fsadm.
+  Do not execute lvresize from fsadm --dry-run.
   Fix fsadm return error code from user's break action.
   Allow CC to be overridden at build time (for 'scan-build make').
   Rename 'flags' to 'status' in struct metadata_area.
   Avoid segfault by limiting partial mode for lvm1 metadata. (2.02.74)
-  Add dm_zalloc and use it and dm_pool_zalloc throughout.
+  Use dm_zalloc and dm_pool_zalloc throughout.
   Add pv_get_property and create generic internal _get_property function.
   Add 'get' functions for pv and vg properties/fields.
   Make generic GET_*_PROPERTY_FN macros with secondary macro for vg, pv & lv.
   Add tags_format_and_copy() common function and call from _tags_disp.
   Add id_format_and_copy() common function and call from _uuid_disp.
-  Simplify logic to create '{pv|vg|lv}_attr' strings.
   Refactor report.c '*_disp' functions to call supporting functions.
-  Refactor lib/metadata/metadata.[ch] into {pv|vg|lv}.[ch].
-  Fix memory leak of vg_read while using live copies of metadata in directories.
+  Move parts of metadata*.[ch] into new {pv|vg|lv}.[ch] files.
+  Fix vg_read memory leak with directory-based metadata.
   Fix memory leak of config_tree in reinitialization code path.
-  Swap pool destruction order in dmeventd_lvm2_exit() to fix leak report.
+  Fix pool destruction order in dmeventd_lvm2_exit() to avoid leak debug mesg.
   Read whole /proc/self/maps file before working with maps entries.
   Speed up unquoting of quoted double quotes and backslashes.
   Speed up CRC32 calculations by using a larger lookup table.
--- LVM2/WHATS_NEW_DM	2010/10/25 13:13:53	1.418
+++ LVM2/WHATS_NEW_DM	2010/10/25 13:54:29	1.419
@@ -1,6 +1,8 @@
-Version 1.02.56 - 
-=====================================
-  Fix API for dm_basename() and return const pointer for const input pointer.
+Version 1.02.56 - 25th October 2010
+===================================
+  Return const pointer from dm_basename() in libdevmapper.
+  Implement dmeventd -R to restart without state loss.
+  Add dm_zalloc and use it and dm_pool_zalloc throughout.
   Add --setuuid to dmsetup rename.
   Add dm_task_set_newuuid to set uuid of mapped device post-creation.
 
--- LVM2/lib/display/display.c	2010/08/17 16:25:33	1.112
+++ LVM2/lib/display/display.c	2010/10/25 13:54:29	1.113
@@ -27,13 +27,14 @@
 static const struct {
 	alloc_policy_t alloc;
 	const char str[12]; /* must be changed when size extends 11 chars */
+	const char repchar;
 } _policies[] = {
 	{
-	ALLOC_CONTIGUOUS, "contiguous"}, {
-	ALLOC_CLING, "cling"}, {
-	ALLOC_NORMAL, "normal"}, {
-	ALLOC_ANYWHERE, "anywhere"}, {
-	ALLOC_INHERIT, "inherit"}
+	ALLOC_CONTIGUOUS, "contiguous", 'c'}, {
+	ALLOC_CLING, "cling", 'l'}, {
+	ALLOC_NORMAL, "normal", 'n'}, {
+	ALLOC_ANYWHERE, "anywhere", 'a'}, {
+	ALLOC_INHERIT, "inherit", 'i'}
 };
 
 static const int _num_policies = sizeof(_policies) / sizeof(*_policies);
@@ -120,6 +121,17 @@
 	return v;
 }
 
+const char alloc_policy_char(alloc_policy_t alloc)
+{
+	int i;
+
+	for (i = 0; i < _num_policies; i++)
+		if (_policies[i].alloc == alloc)
+			return _policies[i].repchar;
+
+	return '-';
+}
+
 const char *get_alloc_string(alloc_policy_t alloc)
 {
 	int i;
--- LVM2/lib/display/display.h	2010/07/02 21:16:50	1.22
+++ LVM2/lib/display/display.h	2010/10/25 13:54:29	1.23
@@ -57,6 +57,7 @@
  * Allocation policy display conversion routines.
  */
 const char *get_alloc_string(alloc_policy_t alloc);
+const char alloc_policy_char(alloc_policy_t alloc);
 alloc_policy_t get_alloc_from_string(const char *str);
 
 char yes_no_prompt(const char *prompt, ...) __attribute__ ((format(printf, 1, 2)));
--- LVM2/lib/metadata/lv.c	2010/10/21 14:49:31	1.17
+++ LVM2/lib/metadata/lv.c	2010/10/25 13:54:29	1.18
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "display.h"
 #include "activate.h"
 #include "toolcontext.h"
 #include "segtype.h"
--- LVM2/lib/metadata/metadata.c	2010/10/25 13:35:13	1.407
+++ LVM2/lib/metadata/metadata.c	2010/10/25 13:54:29	1.408
@@ -3957,22 +3957,6 @@
 	return 1;
 }
 
-char alloc_policy_char(alloc_policy_t alloc)
-{
-	switch (alloc) {
-	case ALLOC_CONTIGUOUS:
-		return 'c';
-	case ALLOC_CLING:
-		return 'l';
-	case ALLOC_NORMAL:
-		return 'n';
-	case ALLOC_ANYWHERE:
-		return 'a';
-	default:
-		return 'i';
-	}
-}
-
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags)
 {
 	struct str_list *sl;
--- LVM2/lib/metadata/metadata.h	2010/10/05 17:34:07	1.223
+++ LVM2/lib/metadata/metadata.h	2010/10/25 13:54:29	1.224
@@ -412,7 +412,6 @@
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
-char alloc_policy_char(alloc_policy_t alloc);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
 
 #endif
--- LVM2/lib/metadata/vg.c	2010/09/30 20:47:18	1.7
+++ LVM2/lib/metadata/vg.c	2010/10/25 13:54:29	1.8
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "display.h"
 #include "activate.h"
 
 char *vg_fmt_dup(const struct volume_group *vg)


