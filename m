From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 20:57:38 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_lv.c
Message-ID: <20090726205738.32677.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 20:57:38

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_lv.c 

Log message:
	Implement lvm_lv_activate and lvm_lv_deactivate liblvm calls.
	
	Limited implementation but other types of activation should probably have
	separate calls.  We also currently do not handle pvmoves or lvconverts.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/liblvm/.exported_symbols	2009/07/26 16:44:05	1.15
+++ LVM2/liblvm/.exported_symbols	2009/07/26 20:57:37	1.16
@@ -12,6 +12,8 @@
 lvm_vg_get_extent_count
 lvm_vg_get_free_extent_count
 lvm_vg_get_pv_count
+lvm_lv_activate
+lvm_lv_deactivate
 lvm_lv_get_uuid
 lvm_lv_get_name
 lvm_lv_get_size
--- LVM2/liblvm/lvm.h	2009/07/26 20:28:59	1.24
+++ LVM2/liblvm/lvm.h	2009/07/26 20:57:37	1.25
@@ -443,6 +443,31 @@
 lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
 
 /**
+ * Activate a logical volume.
+ *
+ * This API is the equivalent of the lvm command "lvchange -ay".
+ *
+ * NOTE: This API cannot currently handle LVs with an in-progress pvmove or
+ * lvconvert.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  0 (success) or -1 (failure).
+ */
+int lvm_lv_activate(lv_t *lv);
+
+/**
+ * Deactivate a logical volume.
+ *
+ * This API is the equivalent of the lvm command "lvchange -an".
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \return  0 (success) or -1 (failure).
+ */
+int lvm_lv_deactivate(lv_t *lv);
+
+/**
  * Remove a logical volume from a volume group.
  *
  * This function commits the change to disk and does _not_ require calling
--- LVM2/liblvm/lvm_lv.c	2009/07/26 20:28:59	1.5
+++ LVM2/liblvm/lvm_lv.c	2009/07/26 20:57:37	1.6
@@ -18,6 +18,8 @@
 #include "lvm-string.h"
 #include "defaults.h"
 #include "segtype.h"
+#include "locking.h"
+
 #include <string.h>
 
 /* FIXME: have lib/report/report.c _disp function call lv_size()? */
@@ -104,3 +106,51 @@
 		return -1;
 	return 0;
 }
+
+int lvm_lv_activate(lv_t *lv)
+{
+	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
+		return -1;
+
+	/* FIXME: handle pvmove stuff later */
+	if (lv->status & LOCKED) {
+		log_error("Unable to activate locked LV\n");
+		return -1;
+	}
+
+	/* FIXME: handle lvconvert stuff later */
+	if (lv->status & CONVERTING) {
+		log_error("Unable to activate LV with in-progress lvconvert\n");
+		return -1;
+	}
+
+	if (lv_is_origin(lv)) {
+		log_verbose("Activating logical volume \"%s\" "
+			    "exclusively", lv->name);
+		if (!activate_lv_excl(lv->vg->cmd, lv)) {
+			log_error("Activate exclusive failed.\n");
+			return -1;
+		}
+	} else {
+		log_verbose("Activating logical volume \"%s\"",
+			    lv->name);
+		if (!activate_lv(lv->vg->cmd, lv)) {
+			log_error("Activate failed.\n");
+			return -1;
+		}
+	}
+	return 0;
+}
+
+int lvm_lv_deactivate(lv_t *lv)
+{
+	if (!lv || !lv->vg || vg_read_error(lv->vg) || !lv->vg->cmd)
+		return -1;
+
+	log_verbose("Deactivating logical volume \"%s\"", lv->name);
+	if (!deactivate_lv(lv->vg->cmd, lv)) {
+		log_error("Deactivate failed.\n");
+		return -1;
+	}
+	return 0;
+}


