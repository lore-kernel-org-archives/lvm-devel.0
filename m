From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:03:38 -0000
Subject: LVM2/tools vgcreate.c vgextend.c
Message-ID: <20091005200338.22737.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:03:37

Modified files:
	tools          : vgcreate.c vgextend.c 

Log message:
	Refactor vgcreate/vgextend validation of vgname/pvname(s).
	
	Decrement argc and increment argv in a consistent way to allow for later
	code-sharing.  Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.51&r2=1.52

--- LVM2/tools/vgcreate.c	2009/10/05 20:02:48	1.67
+++ LVM2/tools/vgcreate.c	2009/10/05 20:03:37	1.68
@@ -22,6 +22,7 @@
 	struct volume_group *vg;
 	const char *tag;
 	const char *clustered_message = "";
+	char *vg_name;
 
 	if (!argc) {
 		log_error("Please provide volume group name and "
@@ -29,7 +30,11 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc == 1) {
+	vg_name = argv[0];
+	argc--;
+	argv++;
+
+	if (argc == 0) {
 		log_error("Please enter physical volume name(s)");
 		return EINVALID_CMD_LINE;
 	}
@@ -40,7 +45,7 @@
 	vp_def.max_lv = DEFAULT_MAX_LV;
 	vp_def.alloc = DEFAULT_ALLOC_POLICY;
 	vp_def.clustered = DEFAULT_CLUSTERED;
-	if (fill_vg_create_params(cmd, argv[0], &vp_new, &vp_def))
+	if (fill_vg_create_params(cmd, vg_name, &vp_new, &vp_def))
 		return EINVALID_CMD_LINE;
 
 	if (validate_vg_create_params(cmd, &vp_new))
@@ -63,7 +68,7 @@
 	}
 
 	/* attach the pv's */
-	if (!vg_extend(vg, argc - 1, argv + 1, NULL))
+	if (!vg_extend(vg, argc, argv, NULL))
 		goto_bad;
 
 	if (vp_new.max_lv != vg->max_lv)
--- LVM2/tools/vgextend.c	2009/10/05 20:02:49	1.51
+++ LVM2/tools/vgextend.c	2009/10/05 20:03:37	1.52
@@ -27,15 +27,15 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc == 1) {
-		log_error("Please enter physical volume(s)");
-		return EINVALID_CMD_LINE;
-	}
-
 	vg_name = skip_dev_dir(cmd, argv[0], NULL);
 	argc--;
 	argv++;
 
+	if (argc == 0) {
+		log_error("Please enter physical volume(s)");
+		return EINVALID_CMD_LINE;
+	}
+
 	log_verbose("Checking for volume group \"%s\"", vg_name);
 	vg = vg_read_for_update(cmd, vg_name, NULL, 0);
 	if (vg_read_error(vg)) {


