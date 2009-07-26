From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 14:36:53 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_lv.c
Message-ID: <20090726143653.16658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 14:36:52

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_lv.c 

Log message:
	Add lvm_vg_remove_lv liblvm function.
	
	Add a very simple version of lvm_vg_remove_lv.
	Since we currently can only create linear LVs, this simple remove function
	is adequate.  We must refactor lvremove_single a bit.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/liblvm/.exported_symbols	2009/07/26 13:06:59	1.10
+++ LVM2/liblvm/.exported_symbols	2009/07/26 14:36:52	1.11
@@ -30,3 +30,4 @@
 lvm_list_vg_names
 lvm_list_vg_ids
 lvm_vg_create_lv_linear
+lvm_vg_remove_lv
--- LVM2/liblvm/lvm.h	2009/07/26 13:06:59	1.15
+++ LVM2/liblvm/lvm.h	2009/07/26 14:36:52	1.16
@@ -117,6 +117,17 @@
 lv_t *lvm_vg_create_lv_linear(vg_t *vg, const char *name, uint64_t size);
 
 /**
+ * Remove a logical volume from a volume group.
+ * This API commits the change to disk and does _not_ require calling
+ * lvm_vg_write.
+ * Currently only removing linear LVs are possible.
+ *
+ * FIXME: This API should probably not commit to disk but require calling
+ * lvm_vg_write.
+ */
+int lvm_vg_remove_lv(lv_t *lv);
+
+/**
  * Return stored error no describing last LVM API error.
  *
  * Users of liblvm should use lvm_errno to determine success or failure
--- LVM2/liblvm/lvm_lv.c	2009/07/26 13:06:59	1.3
+++ LVM2/liblvm/lvm_lv.c	2009/07/26 14:36:52	1.4
@@ -96,3 +96,9 @@
 	return lvl->lv;
 }
 
+int lvm_vg_remove_lv(lv_t *lv)
+{
+	if (!lv || !lv->vg || vg_read_error(lv->vg))
+		return 0;
+	return lv_remove_single(lv->vg->cmd, lv, DONT_PROMPT);
+}


