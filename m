From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:04:09 -0000
Subject: LVM2/tools commands.h vgcreate.c vgextend.c
Message-ID: <20091005200409.27381.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:04:08

Modified files:
	tools          : commands.h vgcreate.c vgextend.c 

Log message:
	Add implicit pvcreate support to vgcreate and vgextend.
	
	Adds implicit pvcreate support when calling vgcreate or vgextend with
	device paths that are not yet PVs.  This changes the behavior of vgcreate
	and vgextend from failing with an error message to implicitly pvcreating.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/tools/commands.h	2009/08/04 15:53:04	1.131
+++ LVM2/tools/commands.h	2009/10/05 20:04:08	1.132
@@ -757,7 +757,9 @@
    "\tVolumeGroupName PhysicalVolume [PhysicalVolume...]\n",
 
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
-   maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG)
+   maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
+   force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
+   metadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
@@ -820,7 +822,10 @@
    "\t[--version]" "\n"
    "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
 
-   autobackup_ARG, test_ARG)
+   autobackup_ARG, test_ARG,
+   force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
+   metadatasize_ARG, metadatacopies_ARG, dataalignment_ARG,
+   dataalignmentoffset_ARG)
 
 xx(vgimport,
    "Register exported volume group with system",
--- LVM2/tools/vgcreate.c	2009/10/05 20:03:37	1.68
+++ LVM2/tools/vgcreate.c	2009/10/05 20:04:08	1.69
@@ -23,6 +23,7 @@
 	const char *tag;
 	const char *clustered_message = "";
 	char *vg_name;
+	struct pvcreate_params pp;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -34,8 +35,8 @@
 	argc--;
 	argv++;
 
-	if (argc == 0) {
-		log_error("Please enter physical volume name(s)");
+	fill_default_pvcreate_params(&pp);
+	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
@@ -68,7 +69,7 @@
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc, argv, NULL))
+	if (!vg_extend(vg, argc, argv, &pp))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
--- LVM2/tools/vgextend.c	2009/10/05 20:03:37	1.52
+++ LVM2/tools/vgextend.c	2009/10/05 20:04:08	1.53
@@ -20,6 +20,7 @@
 	char *vg_name;
 	struct volume_group *vg = NULL;
 	int r = ECMD_FAILED;
+	struct pvcreate_params pp;
 
 	if (!argc) {
 		log_error("Please enter volume group name and "
@@ -31,8 +32,8 @@
 	argc--;
 	argv++;
 
-	if (argc == 0) {
-		log_error("Please enter physical volume(s)");
+	fill_default_pvcreate_params(&pp);
+	if (!pvcreate_validate_params(cmd, argc, argv, &pp)) {
 		return EINVALID_CMD_LINE;
 	}
 
@@ -54,7 +55,7 @@
 		goto_bad;
 
 	/* extend vg */
-	if (!vg_extend(vg, argc, argv, NULL))
+	if (!vg_extend(vg, argc, argv, &pp))
 		goto_bad;
 
 	/* ret > 0 */


