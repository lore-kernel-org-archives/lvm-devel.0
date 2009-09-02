From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 2 Sep 2009 21:26:50 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090902212650.12487.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-09-02 21:26:50

Modified files:
	tools          : vgsplit.c 

Log message:
	Refactor vgsplit - create _vgsplit_from function to open source vg.
	
	Should be no functional change and allows future reorder of source and dest
	vgs.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.89&r2=1.90

--- LVM2/tools/vgsplit.c	2009/09/02 21:26:34	1.89
+++ LVM2/tools/vgsplit.c	2009/09/02 21:26:50	1.90
@@ -244,6 +244,27 @@
 }
 
 /*
+ * Open the source of the vgsplit operation.
+ * Returns
+ * - non-NULL: VG handle w/VG lock held
+ * - NULL: no VG lock held
+ */
+static struct volume_group *_vgsplit_from(struct cmd_context *cmd,
+					  const char *vg_name_from)
+{
+	struct volume_group *vg_from;
+
+	log_verbose("Checking for volume group \"%s\"", vg_name_from);
+
+	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
+	if (vg_read_error(vg_from)) {
+		vg_release(vg_from);
+		return NULL;
+	}
+	return vg_from;
+}
+
+/*
  * Has the user given an option related to a new vg as the split destination?
  */
 static int new_vg_option_specified(struct cmd_context *cmd)
@@ -293,13 +314,9 @@
 		return ECMD_FAILED;
 	}
 
-	log_verbose("Checking for volume group \"%s\"", vg_name_from);
-
-	vg_from = vg_read_for_update(cmd, vg_name_from, NULL, 0);
-	if (vg_read_error(vg_from)) {
-		vg_release(vg_from);
+	vg_from = _vgsplit_from(cmd, vg_name_from);
+	if (!vg_from)
 		return ECMD_FAILED;
-	}
 
 	/*
 	 * Set metadata format of original VG.


