From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 5 Oct 2009 20:03:09 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20091005200309.18629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-10-05 20:03:08

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	liblvm         : lvm_vg.c 

Log message:
	Allow calling fill_default_pvcreate_params from tools.
	
	We need defaults for pvcreate_params at a higher level - this will
	allow us to use a common function from the tools to take defaults,
	then fill in any non-defaults from the commandline.
	
	Future patches will refactor vgcreate/vgextend to call this function
	if one or more pvcreate parameters are given on the commandline.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.287&r2=1.288
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/lib/metadata/metadata-exported.h	2009/10/05 20:02:48	1.115
+++ LVM2/lib/metadata/metadata-exported.h	2009/10/05 20:03:08	1.116
@@ -371,6 +371,7 @@
 struct physical_volume *pvcreate_single(struct cmd_context *cmd,
 					const char *pv_name,
 					struct pvcreate_params *pp);
+void fill_default_pvcreate_params(struct pvcreate_params *pp);
 
 /*
 * Utility functions
--- LVM2/lib/metadata/metadata.c	2009/10/05 20:02:48	1.287
+++ LVM2/lib/metadata/metadata.c	2009/10/05 20:03:08	1.288
@@ -1272,7 +1272,7 @@
 	return 1;
 }
 
-static void fill_default_pvcreate_params(struct pvcreate_params *pp)
+void fill_default_pvcreate_params(struct pvcreate_params *pp)
 {
 	memset(pp, 0, sizeof(*pp));
 	pp->zero = 0;
--- LVM2/liblvm/lvm_vg.c	2009/10/05 20:02:48	1.31
+++ LVM2/liblvm/lvm_vg.c	2009/10/05 20:03:08	1.32
@@ -41,6 +41,8 @@
 
 int lvm_vg_extend(vg_t vg, const char *device)
 {
+	struct pvcreate_params pp;
+
 	if (vg_read_error(vg))
 		return -1;
 
@@ -52,15 +54,8 @@
 		return -1;
 	}
 
-	/* If device not initialized, pvcreate it */
-	if (!pv_by_path(vg->cmd, device) &&
-	   (!pvcreate_single(vg->cmd, device, NULL))) {
-		log_error("Unable to initialize device for LVM use");
-		unlock_vg(vg->cmd, VG_ORPHANS);
-		return -1;
-	}
-
-	if (!vg_extend(vg, 1, (char **) &device, NULL)) {
+	fill_default_pvcreate_params(&pp);
+	if (!vg_extend(vg, 1, (char **) &device, &pp)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return -1;
 	}


