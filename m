From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Mar 2007 20:47:42 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c tools/lvrena ...
Message-ID: <20070309204742.19653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-09 20:47:41

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c lvrename.c pvmove.c toollib.c 
	                 toollib.h vgcfgrestore.c vgcreate.c vgextend.c 
	                 vgmerge.c vgreduce.c vgrename.c 

Log message:
	Support the /dev/mapper prefix on most command lines.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.582&r2=1.583
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.132&r2=1.133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgrestore.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcreate.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgextend.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgrename.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2007/03/08 21:37:48	1.582
+++ LVM2/WHATS_NEW	2007/03/09 20:47:41	1.583
@@ -1,5 +1,6 @@
 Version 2.02.24 -
 ====================================
+  Support the /dev/mapper prefix on most command lines.
 
 Version 2.02.23 - 8th March 2007
 ================================
--- LVM2/tools/lvcreate.c	2007/01/10 14:13:46	1.132
+++ LVM2/tools/lvcreate.c	2007/03/09 20:47:41	1.133
@@ -95,7 +95,7 @@
 			}
 
 		} else {
-			vg_name = skip_dev_dir(cmd, argv[0]);
+			vg_name = skip_dev_dir(cmd, argv[0], NULL);
 			if (strrchr(vg_name, '/')) {
 				log_error("Volume group name expected "
 					  "(no slash)");
--- LVM2/tools/lvrename.c	2007/01/12 20:38:30	1.41
+++ LVM2/tools/lvrename.c	2007/03/09 20:47:41	1.42
@@ -29,7 +29,7 @@
 	struct lv_list *lvl;
 
 	if (argc == 3) {
-		vg_name = skip_dev_dir(cmd, argv[0]);
+		vg_name = skip_dev_dir(cmd, argv[0], NULL);
 		lv_name_old = argv[1];
 		lv_name_new = argv[2];
 		if (strchr(lv_name_old, '/') &&
--- LVM2/tools/pvmove.c	2006/09/02 01:18:17	1.32
+++ LVM2/tools/pvmove.c	2007/03/09 20:47:41	1.33
@@ -27,7 +27,7 @@
 	if (!strchr(arg, '/'))
 		return arg;
 
-	lvname = skip_dev_dir(cmd, arg);
+	lvname = skip_dev_dir(cmd, arg, NULL);
 	while (*lvname == '/')
 		lvname++;
 	if (!strchr(lvname, '/')) {
--- LVM2/tools/toollib.c	2007/01/15 21:55:11	1.96
+++ LVM2/tools/toollib.c	2007/03/09 20:47:41	1.97
@@ -88,21 +88,53 @@
 /*
  * Strip dev_dir if present
  */
-char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name)
+char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
+		   unsigned *dev_dir_found)
 {
-	/* FIXME Do this properly */
+	const char *dmdir = dm_dir();
+	size_t dmdir_len = strlen(dmdir), vglv_sz;
+	char *vgname, *lvname, *layer, *vglv;
 
+	/* FIXME Do this properly */
 	if (*vg_name == '/') {
 		while (*vg_name == '/')
 			vg_name++;
 		vg_name--;
 	}
 
+	/* Reformat string if /dev/mapper found */
+	if (!strncmp(vg_name, dmdir, dmdir_len) && vg_name[dmdir_len] == '/') {
+		if (dev_dir_found)
+			*dev_dir_found = 1;
+		vg_name += dmdir_len;
+		while (*vg_name == '/')
+			vg_name++;
+
+		if (!dm_split_lvm_name(cmd->mem, vg_name, &vgname, &lvname, &layer) ||
+		    *layer) {
+			log_error("skip_dev_dir: Couldn't split up device name %s",
+				  vg_name);
+			return (char *) vg_name;
+		}
+		vglv_sz = strlen(vgname) + strlen(lvname) + 2;
+		if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
+		    dm_snprintf(vglv, vglv_sz, "%s%s%s", vgname,
+				 *lvname ? "/" : "",
+				 lvname) < 0) {
+			log_error("vg/lv string alloc failed");
+			return (char *) vg_name;
+		}
+		return vglv;
+	}
+
 	if (!strncmp(vg_name, cmd->dev_dir, strlen(cmd->dev_dir))) {
+		if (dev_dir_found)
+			*dev_dir_found = 1;
 		vg_name += strlen(cmd->dev_dir);
 		while (*vg_name == '/')
 			vg_name++;
-	}
+	} else if (dev_dir_found)
+		*dev_dir_found = 0;
 
 	return (char *) vg_name;
 }
@@ -222,7 +254,7 @@
 		for (; opt < argc; opt++) {
 			const char *lv_name = argv[opt];
 			char *vgname_def;
-			int dev_dir_found = 0;
+			unsigned dev_dir_found = 0;
 
 			/* Do we have a tag or vgname or lvname? */
 			vgname = lv_name;
@@ -243,18 +275,8 @@
 			}
 
 			/* FIXME Jumbled parsing */
-			if (*vgname == '/') {
-				while (*vgname == '/')
-					vgname++;
-				vgname--;
-			}
-			if (!strncmp(vgname, cmd->dev_dir,
-				     strlen(cmd->dev_dir))) {
-				vgname += strlen(cmd->dev_dir);
-				dev_dir_found = 1;
-				while (*vgname == '/')
-					vgname++;
-			}
+			vgname = skip_dev_dir(cmd, vgname, &dev_dir_found);
+
 			if (*vgname == '/') {
 				log_error("\"%s\": Invalid path for Logical "
 					  "Volume", argv[opt]);
@@ -528,7 +550,7 @@
 				continue;
 			}
 
-			vg_name = skip_dev_dir(cmd, vg_name);
+			vg_name = skip_dev_dir(cmd, vg_name, NULL);
 			if (strchr(vg_name, '/')) {
 				log_error("Invalid volume group name: %s",
 					  vg_name);
@@ -830,7 +852,7 @@
 	if (!vg_path)
 		return 0;
 
-	vg_path = skip_dev_dir(cmd, vg_path);
+	vg_path = skip_dev_dir(cmd, vg_path, NULL);
 
 	if (strchr(vg_path, '/')) {
 		log_error("Environment Volume Group in LVM_VG_NAME invalid: "
--- LVM2/tools/toollib.h	2006/11/03 21:07:15	1.44
+++ LVM2/tools/toollib.h	2007/03/09 20:47:41	1.45
@@ -76,7 +76,8 @@
 
 char *default_vgname(struct cmd_context *cmd);
 const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
-char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name);
+char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
+		   unsigned *dev_dir_found);
 
 /*
  * Builds a list of pv's from the names in argv.  Used in
--- LVM2/tools/vgcfgrestore.c	2006/08/25 23:02:33	1.12
+++ LVM2/tools/vgcfgrestore.c	2007/03/09 20:47:41	1.13
@@ -24,7 +24,7 @@
 		return ECMD_FAILED;
 	}
 
-	vg_name = skip_dev_dir(cmd, argv[0]);
+	vg_name = skip_dev_dir(cmd, argv[0], NULL);
 
 	if (!validate_name(vg_name)) {
 		log_error("Volume group name \"%s\" is invalid", vg_name);
--- LVM2/tools/vgcreate.c	2006/08/25 23:02:33	1.47
+++ LVM2/tools/vgcreate.c	2007/03/09 20:47:41	1.48
@@ -38,7 +38,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name = skip_dev_dir(cmd, argv[0]);
+	vg_name = skip_dev_dir(cmd, argv[0], NULL);
 	max_lv = arg_uint_value(cmd, maxlogicalvolumes_ARG, 0);
 	max_pv = arg_uint_value(cmd, maxphysicalvolumes_ARG, 0);
 	alloc = arg_uint_value(cmd, alloc_ARG, ALLOC_NORMAL);
--- LVM2/tools/vgextend.c	2006/09/02 01:18:17	1.27
+++ LVM2/tools/vgextend.c	2007/03/09 20:47:41	1.28
@@ -32,7 +32,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name = skip_dev_dir(cmd, argv[0]);
+	vg_name = skip_dev_dir(cmd, argv[0], NULL);
 	argc--;
 	argv++;
 
--- LVM2/tools/vgmerge.c	2006/11/30 23:11:42	1.35
+++ LVM2/tools/vgmerge.c	2007/03/09 20:47:41	1.36
@@ -253,12 +253,12 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name_to = skip_dev_dir(cmd, argv[0]);
+	vg_name_to = skip_dev_dir(cmd, argv[0], NULL);
 	argc--;
 	argv++;
 
 	for (; opt < argc; opt++) {
-		vg_name_from = skip_dev_dir(cmd, argv[opt]);
+		vg_name_from = skip_dev_dir(cmd, argv[opt], NULL);
 
 		ret = _vgmerge_single(cmd, vg_name_to, vg_name_from);
 		if (ret > ret_max)
--- LVM2/tools/vgreduce.c	2007/01/31 16:26:23	1.56
+++ LVM2/tools/vgreduce.c	2007/03/09 20:47:41	1.57
@@ -461,7 +461,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name = skip_dev_dir(cmd, argv[0]);
+	vg_name = skip_dev_dir(cmd, argv[0], NULL);
 	argv++;
 	argc--;
 
--- LVM2/tools/vgrename.c	2007/03/08 21:08:25	1.42
+++ LVM2/tools/vgrename.c	2007/03/09 20:47:41	1.43
@@ -35,8 +35,8 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	vg_name_old = skip_dev_dir(cmd, argv[0]);
-	vg_name_new = skip_dev_dir(cmd, argv[1]);
+	vg_name_old = skip_dev_dir(cmd, argv[0], NULL);
+	vg_name_new = skip_dev_dir(cmd, argv[1], NULL);
 
 	dev_dir = cmd->dev_dir;
 	length = strlen(dev_dir);


