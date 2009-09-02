From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:28:11 -0000
Subject: LVM2/tools vgmerge.c
Message-ID: <20090902212811.13138.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:28:11

Modified files:
	tools          : vgmerge.c 

Log message:
	Refactor vgmerge - create _vgmerge_from and _vgmerge_to.
	
	These functions are really identical but for clarity I made them separate
	functions in this patch.
	
	Should be no functional change.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/tools/vgmerge.c	2009/09/02 21:27:55	1.61
+++ LVM2/tools/vgmerge.c	2009/09/02 21:28:10	1.62
@@ -15,6 +15,33 @@
 
 #include "tools.h"
 
+static struct volume_group *_vgmerge_from(struct cmd_context *cmd,
+					  const char *vg_name_from)
+{
+	struct volume_group *vg_from;
+	log_verbose("Checking for volume group \"%s\"", vg_name_from);
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
+	if (vg_read_error(vg_from)) {
+		vg_release(vg_from);
+		return NULL;
+	}
+	return vg_from;
+}
+
+static struct volume_group *_vgmerge_to(struct cmd_context *cmd,
+					const char *vg_name_to)
+{
+	struct volume_group *vg_to;
+
+	log_verbose("Checking for volume group \"%s\"", vg_name_to);
+	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
+	if (vg_read_error(vg_to)) {
+		vg_release(vg_to);
+		return NULL;
+	}
+	return vg_to;
+}
+
 static int _vgmerge_single(struct cmd_context *cmd, const char *vg_name_to,
 			   const char *vg_name_from)
 {
@@ -28,17 +55,12 @@
 		return ECMD_FAILED;
 	}
 
-	log_verbose("Checking for volume group \"%s\"", vg_name_to);
-	vg_to = vg_read_for_update(cmd, vg_name_to, NULL, 0);
-	if (vg_read_error(vg_to)) {
-		vg_release(vg_to);
+	vg_to = _vgmerge_to(cmd, vg_name_to);
+	if (!vg_to)
 		return ECMD_FAILED;
-	}
 
-	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
-	if (vg_read_error(vg_from)) {
-		vg_release(vg_from);
+	vg_from = _vgmerge_from(cmd, vg_name_from);
+	if (!vg_from) {
 		unlock_and_release_vg(cmd, vg_to, vg_name_to);
 		return ECMD_FAILED;
 	}


