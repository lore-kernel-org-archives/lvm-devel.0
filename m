From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 14 Jan 2008 21:08:00 -0000
Subject: LVM2 lib/config/defaults.h lib/metadata/metada ...
Message-ID: <20080114210800.8561.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-01-14 21:07:58

Modified files:
	lib/config     : defaults.h 
	lib/metadata   : metadata-exported.h metadata.c 
	man            : vgsplit.8 
	test           : lvm-utils.sh t-vgcreate-usage.sh 
	                 t-vgsplit-operation.sh 
	tools          : commands.h toollib.c toollib.h vgcreate.c 
	                 vgsplit.c 

Log message:
	Allow vgcreate options as input to vgsplit when new vg is split destination.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.31&r2=1.32
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgsplit.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgsplit-operation.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/config/defaults.h	2008/01/10 22:21:25	1.37
+++ LVM2/lib/config/defaults.h	2008/01/14 21:07:58	1.38
@@ -64,6 +64,8 @@
 #define DEFAULT_PVMETADATACOPIES 1
 #define DEFAULT_LABELSECTOR UINT64_C(1)
 #define DEFAULT_READ_AHEAD "auto"
+#define DEFAULT_PE_SIZE 4096	/* In KB */
+
 
 #define DEFAULT_MSG_PREFIX "  "
 #define DEFAULT_CMD_NAME 0
--- LVM2/lib/metadata/metadata-exported.h	2008/01/10 18:35:50	1.31
+++ LVM2/lib/metadata/metadata-exported.h	2008/01/14 21:07:58	1.32
@@ -528,4 +528,16 @@
 
 uint32_t vg_status(const vg_t *vg);
 
+struct vgcreate_params {
+	char *vg_name;
+	uint32_t extent_size;
+	size_t max_pv;
+	size_t max_lv;
+	alloc_policy_t alloc;
+	int clustered; /* FIXME: put this into a 'status' variable instead? */
+};
+
+int validate_vg_create_params(struct cmd_context *cmd,
+			      struct vgcreate_params *vp);
+
 #endif
--- LVM2/lib/metadata/metadata.c	2008/01/07 20:42:57	1.146
+++ LVM2/lib/metadata/metadata.c	2008/01/14 21:07:58	1.147
@@ -378,6 +378,45 @@
 	return vg_name;
 }
 
+/*
+ * Validate parameters to vg_create() before calling.
+ * FIXME: move this inside the library, maybe inside vg_create
+ * - TODO: resolve error codes
+ */
+int validate_vg_create_params(struct cmd_context *cmd,
+			      struct vgcreate_params *vp)
+{
+	if (!validate_new_vg_name(cmd, vp->vg_name)) {
+		log_error("New volume group name \"%s\" is invalid",
+			  vp->vg_name);
+		return 1;
+	}
+
+	if (vp->alloc == ALLOC_INHERIT) {
+		log_error("Volume Group allocation policy cannot inherit "
+			  "from anything");
+		return 1;
+	}
+
+	if (!vp->extent_size) {
+		log_error("Physical extent size may not be zero");
+		return 1;
+	}
+
+	if (!(cmd->fmt->features & FMT_UNLIMITED_VOLS)) {
+		if (!vp->max_lv)
+			vp->max_lv = 255;
+		if (!vp->max_pv)
+			vp->max_pv = 255;
+		if (vp->max_lv > 255 || vp->max_pv > 255) {
+			log_error("Number of volumes may not exceed 255");
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name,
 			       uint32_t extent_size, uint32_t max_pv,
 			       uint32_t max_lv, alloc_policy_t alloc,
--- LVM2/man/vgsplit.8	2008/01/11 21:43:16	1.3
+++ LVM2/man/vgsplit.8	2008/01/14 21:07:58	1.4
@@ -3,13 +3,23 @@
 vgsplit \- split a volume group into two
 .SH SYNOPSIS
 .B vgsplit
-[\-A/\-\-autobackup y/n] 
-[\-d/\-\-debug] 
-[\-h/\-?/\-\-help] 
-[\-l/\-\-list]
-[\-M/\-\-metadatatype 1/2]
-[\-t/\-\-test] 
-[\-v/\-\-verbose] 
+.RB [ \-\-alloc
+.IR AllocationPolicy ]
+.RB [ \-A | \-\-autobackup " {" y | n }]
+.RB [ \-c | \-\-clustered " {" y | n }]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-l | \-\-list ]
+.RB [ \-\-maxlogicalvolumes
+.IR MaxLogicalVolumes ]
+.RB [ -M | \-\-metadatatype
+.IR type ]
+.RB [ -p | \-\-maxphysicalvolumes
+.IR MaxPhysicalVolumes ]
+.RB [ \-s | \-\-physicalextentsize
+.IR PhysicalExtentSize [ \fBkKmMgGtT\fR ]]
+.RB [ \-t | \-\-test ]
+.RB [ \-v | \-\-verbose ]
 SourceVolumeGroupName DestinationVolumeGroupName
 PhysicalVolumePath [PhysicalVolumePath...]
 .SH DESCRIPTION
--- LVM2/test/lvm-utils.sh	2007/10/09 13:13:06	1.4
+++ LVM2/test/lvm-utils.sh	2008/01/14 21:07:58	1.5
@@ -50,6 +50,11 @@
   return 0;
 }
 
+check_vg_field_()
+{
+  return $(test $(vgs --noheadings -o $2 $1) == $3)
+}
+
 check_pv_size_()
 {
   return $(test $(pvs --noheadings -o pv_free $1) == $2)
--- LVM2/test/t-vgcreate-usage.sh	2008/01/11 07:02:35	1.1
+++ LVM2/test/t-vgcreate-usage.sh	2008/01/14 21:07:58	1.2
@@ -31,6 +31,24 @@
 lv=vgcreate-usage-$$
 
 test_expect_success \
+  'vgcreate accepts 8.00M physicalextentsize for VG' \
+  'vgcreate $vg --physicalextentsize 8.00M $d1 $d2 &&
+   check_vg_field_ $vg vg_extent_size 8.00M &&
+   vgremove $vg'
+
+test_expect_success \
+  'vgcreate accepts smaller (128) maxlogicalvolumes for VG' \
+  'vgcreate $vg --maxlogicalvolumes 128 $d1 $d2 &&
+   check_vg_field_ $vg max_lv 128 &&
+   vgremove $vg'
+
+test_expect_success \
+  'vgcreate accepts smaller (128) maxphysicalvolumes for VG' \
+  'vgcreate $vg --maxphysicalvolumes 128 $d1 $d2 &&
+   check_vg_field_ $vg max_pv 128 &&
+   vgremove $vg'
+
+test_expect_success \
   'vgcreate rejects a zero physical extent size' \
   'vgcreate --physicalextentsize 0 $vg $d1 $d2 2>err;
    status=$?; echo status=$?; test $status = 3 &&
@@ -50,14 +68,14 @@
 
 test_expect_success \
   'vgcreate rejects vgname greater than 128 characters' \
-  'vg=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome;
-   vgcreate $vg $d1 $d2 2>err;
+  'vginvalid=thisnameisridiculouslylongtotestvalidationcodecheckingmaximumsizethisiswhathappenswhenprogrammersgetboredandorarenotcreativedonttrythisathome;
+   vgcreate $vginvalid $d1 $d2 2>err;
    status=$?; echo status=$?; test $status = 3 &&
-   grep "New volume group name \"$vg\" is invalid\$" err'
+   grep "New volume group name \"$vginvalid\" is invalid\$" err'
 
 test_expect_success \
-  'vgcreate rejects already existing vgname "/dev/fd0"' \
-  'vg=/dev/fd0; vgcreate $vg $d1 $d2 2>err;
+  'vgcreate rejects already existing vgname "/tmp/$vg"' \
+  'touch /tmp/$vg; vgcreate $vg $d1 $d2 2>err;
    status=$?; echo status=$?; test $status = 3 &&
    grep "New volume group name \"$vg\" is invalid\$" err'
 
--- LVM2/test/t-vgsplit-operation.sh	2008/01/11 21:43:16	1.1
+++ LVM2/test/t-vgsplit-operation.sh	2008/01/14 21:07:58	1.2
@@ -48,6 +48,36 @@
    vgremove $vg1 &&
    vgremove $vg2'
 
+#test_expect_success \
+# 'vgcreate accepts 8.00M physicalextentsize for VG' \
+#  'vgcreate $vg --physicalextentsize 8.00M $d1 $d2 &&
+#   check_vg_field_ $vg vg_extent_size 8.00M &&
+#   vgremove $vg'
+
+test_expect_success \
+  'vgsplit accepts 8.00M physicalextentsize for new VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgsplit --physicalextentsize 8.00M $vg1 $vg2 $d1 &&
+   check_vg_field_ $vg2 vg_extent_size 8.00M &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_expect_success \
+  'vgsplit accepts --maxphysicalvolumes 128 on new VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgsplit --maxphysicalvolumes 128 $vg1 $vg2 $d1 &&
+   check_vg_field_ $vg2 max_pv 128 &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
+test_expect_success \
+  'vgsplit accepts --maxlogicalvolumes 128 on new VG' \
+  'vgcreate $vg1 $d1 $d2 &&
+   vgsplit --maxlogicalvolumes 128 $vg1 $vg2 $d1 &&
+   check_vg_field_ $vg2 max_lv 128 &&
+   vgremove $vg1 &&
+   vgremove $vg2'
+
 test_done
 # Local Variables:
 # indent-tabs-mode: nil
--- LVM2/tools/commands.h	2007/12/22 12:13:29	1.105
+++ LVM2/tools/commands.h	2008/01/14 21:07:58	1.106
@@ -874,17 +874,24 @@
    "Move physical volumes into a new volume group",
    "vgsplit " "\n"
    "\t[-A|--autobackup {y|n}] " "\n"
+   "\t[--alloc AllocationPolicy] " "\n"
+   "\t[-c|--clustered {y|n}] " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-h|--help] " "\n"
    "\t[-l|--list]" "\n"
+   "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
+   "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
+   "\t[-s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version]" "\n"
-   "\tExistingVolumeGroupName NewVolumeGroupName" "\n"
+   "\tSourceVolumeGroupName DestinationVolumeGroupName" "\n"
    "\tPhysicalVolumePath [PhysicalVolumePath...]\n",
 
-   autobackup_ARG, list_ARG, metadatatype_ARG, test_ARG)
+   alloc_ARG, autobackup_ARG, clustered_ARG, list_ARG,
+   maxlogicalvolumes_ARG, maxphysicalvolumes_ARG,
+   metadatatype_ARG, physicalextentsize_ARG, test_ARG)
 
 xx(version,
    "Display software and driver version information",
--- LVM2/tools/toollib.c	2008/01/03 19:03:32	1.123
+++ LVM2/tools/toollib.c	2008/01/14 21:07:58	1.124
@@ -1233,3 +1233,49 @@
 
 	return 1;
 }
+
+
+/*
+ * Set members of struct vgcreate_params from cmdline.
+ * Do preliminary validation with arg_*() interface.
+ * Further, more generic validation is done in validate_vgcreate_params().
+ * This function is to remain in tools directory, while
+ * validate_vgcreate_params() will be moved into the LVM library.
+ */
+int fill_vg_create_params(struct cmd_context *cmd,
+			  char *vg_name, struct vgcreate_params *vp)
+{
+	vp->vg_name = skip_dev_dir(cmd, vg_name, NULL);
+	vp->max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG, 0);
+	vp->max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
+	vp->alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
+
+	/* Units of 512-byte sectors */
+	vp->extent_size =
+	    arg_uint_value(cmd, physicalextentsize_ARG, DEFAULT_PE_SIZE);
+
+	if (arg_count(cmd, clustered_ARG))
+        	vp->clustered =
+			!strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
+	else
+		/* Default depends on current locking type */
+		vp->clustered = locking_is_clustered();
+
+	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
+		log_error("Physical extent size may not be negative");
+		return 1;
+	}
+
+	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, 0) == SIGN_MINUS) {
+		log_error("Max Logical Volumes may not be negative");
+		return 1;
+	}
+
+	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
+		log_error("Max Physical Volumes may not be negative");
+		return 1;
+	}
+
+	return 0;
+}
+
--- LVM2/tools/toollib.h	2007/12/20 22:37:42	1.54
+++ LVM2/tools/toollib.h	2008/01/14 21:07:58	1.55
@@ -98,4 +98,6 @@
 
 int validate_new_vg_name(struct cmd_context *cmd, const char *vg_name);
 
+int fill_vg_create_params(struct cmd_context *cmd,
+			  char *vg_name, struct vgcreate_params *vp);
 #endif
--- LVM2/tools/vgcreate.c	2008/01/11 07:02:34	1.53
+++ LVM2/tools/vgcreate.c	2008/01/14 21:07:58	1.54
@@ -15,54 +15,11 @@
 
 #include "tools.h"
 
-#define DEFAULT_EXTENT 4096	/* In KB */
-
-static int validate_vg_create_params(struct cmd_context *cmd,
-				     const char *vg_name,
-				     const uint32_t extent_size,
-				     size_t *max_pv,
-				     size_t *max_lv,
-				     const alloc_policy_t alloc)
-{
-	if (!validate_new_vg_name(cmd, vg_name)) {
-		log_error("New volume group name \"%s\" is invalid", vg_name);
-		return 0;
-	}
-
-	if (alloc == ALLOC_INHERIT) {
-		log_error("Volume Group allocation policy cannot inherit "
-			  "from anything");
-		return 0;
-	}
-
-	if (!extent_size) {
-		log_error("Physical extent size may not be zero");
-		return 0;
-	}
-
-	if (!(cmd->fmt->features & FMT_UNLIMITED_VOLS)) {
-		if (!*max_lv)
-			*max_lv = 255;
-		if (!*max_pv)
-			*max_pv = 255;
-		if (*max_lv > 255 || *max_pv > 255) {
-			log_error("Number of volumes may not exceed 255");
-			return 0;
-		}
-	}
-
-	return 1;
-}
-
 int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 {
-	size_t max_lv, max_pv;
-	uint32_t extent_size;
-	char *vg_name;
+	struct vgcreate_params vp;
 	struct volume_group *vg;
 	const char *tag;
-	alloc_policy_t alloc;
-	int clustered;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -75,44 +32,23 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name = skip_dev_dir(cmd, argv[0], NULL);
-	max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG, 0);
-	max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
-	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
-
-	if (arg_sign_value(cmd, physicalextentsize_ARG, 0) == SIGN_MINUS) {
-		log_error("Physical extent size may not be negative");
-		return EINVALID_CMD_LINE;
-	}
-
-	if (arg_sign_value(cmd, maxlogicalvolumes_ARG, 0) == SIGN_MINUS) {
-		log_error("Max Logical Volumes may not be negative");
+	if (fill_vg_create_params(cmd, argv[0], &vp))
 		return EINVALID_CMD_LINE;
-	}
 
-	if (arg_sign_value(cmd, maxphysicalvolumes_ARG, 0) == SIGN_MINUS) {
-		log_error("Max Physical Volumes may not be negative");
-		return EINVALID_CMD_LINE;
-	}
-
-	/* Units of 512-byte sectors */
-	extent_size =
-	    arg_uint_value(cmd, physicalextentsize_ARG, DEFAULT_EXTENT);
-
-	if (!validate_vg_create_params(cmd, vg_name, extent_size,
-				       &max_pv, &max_lv, alloc))
+	if (validate_vg_create_params(cmd, &vp))
 	    return EINVALID_CMD_LINE;
 
 	/* Create the new VG */
-	if (!(vg = vg_create(cmd, vg_name, extent_size, max_pv, max_lv, alloc,
+	if (!(vg = vg_create(cmd, vp.vg_name, vp.extent_size, vp.max_pv,
+			     vp.max_lv, vp.alloc,
 			     argc - 1, argv + 1)))
 		return ECMD_FAILED;
 
-	if (max_lv != vg->max_lv)
+	if (vp.max_lv != vg->max_lv)
 		log_warn("WARNING: Setting maxlogicalvolumes to %d "
 			 "(0 means unlimited)", vg->max_lv);
 
-	if (max_pv != vg->max_pv)
+	if (vp.max_pv != vg->max_pv)
 		log_warn("WARNING: Setting maxphysicalvolumes to %d "
 			 "(0 means unlimited)", vg->max_pv);
 
@@ -129,18 +65,13 @@
 
 		if (!str_list_add(cmd->mem, &vg->tags, tag)) {
 			log_error("Failed to add tag %s to volume group %s",
-				  tag, vg_name);
+				  tag, vp.vg_name);
 			return ECMD_FAILED;
 		}
 	}
 
-	if (arg_count(cmd, clustered_ARG))
-        	clustered = !strcmp(arg_str_value(cmd, clustered_ARG, "n"), "y");
-	else
-		/* Default depends on current locking type */
-		clustered = locking_is_clustered();
-
-	if (clustered)
+	/* FIXME: move this inside vg_create? */
+	if (vp.clustered)
 		vg->status |= CLUSTERED;
 	else
 		vg->status &= ~CLUSTERED;
@@ -150,26 +81,26 @@
 		return ECMD_FAILED;
 	}
 
-	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
-		log_error("Can't get lock for %s", vg_name);
+	if (!lock_vol(cmd, vp.vg_name, LCK_VG_WRITE | LCK_NONBLOCK)) {
+		log_error("Can't get lock for %s", vp.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	if (!archive(vg)) {
-		unlock_vg(cmd, vg_name);
+		unlock_vg(cmd, vp.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
 	/* Store VG on disk(s) */
 	if (!vg_write(vg) || !vg_commit(vg)) {
-		unlock_vg(cmd, vg_name);
+		unlock_vg(cmd, vp.vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
-	unlock_vg(cmd, vg_name);
+	unlock_vg(cmd, vp.vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
 
 	backup(vg);
--- LVM2/tools/vgsplit.c	2008/01/11 21:43:16	1.43
+++ LVM2/tools/vgsplit.c	2008/01/14 21:07:58	1.44
@@ -212,6 +212,7 @@
 
 int vgsplit(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct vgcreate_params vp;
 	char *vg_name_from, *vg_name_to;
 	struct volume_group *vg_to, *vg_from;
 	int opt;
@@ -259,11 +260,18 @@
 		/* FIXME: need some common logic */
 		cmd->fmt = vg_from->fid->fmt;
 
+		/* FIXME: original code took defaults from vg_from */
+		if (fill_vg_create_params(cmd, vg_name_to, &vp))
+			return EINVALID_CMD_LINE;
+
+		if (validate_vg_create_params(cmd, &vp))
+			return EINVALID_CMD_LINE;
+
 		/* Create new VG structure */
 		/* FIXME: allow user input same params as to vgcreate tool */
-		if (!(vg_to = vg_create(cmd, vg_name_to, vg_from->extent_size,
-					vg_from->max_pv, vg_from->max_lv,
-					vg_from->alloc, 0, NULL)))
+		if (!(vg_to = vg_create(cmd, vg_name_to, vp.extent_size,
+					vp.max_pv, vp.max_lv,
+					vp.alloc, 0, NULL)))
 			goto error;
 
 		if (vg_from->status & CLUSTERED)


