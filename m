From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 27 Jul 2009 21:00:52 -0000
Subject: LVM2/liblvm lvm.h lvm_lv.c lvm_pv.c
Message-ID: <20090727210052.32557.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-27 21:00:51

Modified files:
	liblvm         : lvm.h lvm_lv.c lvm_pv.c 

Log message:
	Add skeletons of lvm_lv_resize and lvm_pv_resize - not yet implemented.
	
	These lower-priority interfaces are not currently implemented in liblvm
	but are on the TODO list in the near term.
	
	Author: Thomas Woerner <twoerner@redhat.com>
	Acked-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/liblvm/lvm.h	2009/07/27 17:44:29	1.30
+++ LVM2/liblvm/lvm.h	2009/07/27 21:00:50	1.31
@@ -565,6 +565,18 @@
  */
 uint64_t lvm_lv_is_suspended(const lv_t *lv);
 
+/**
+ * Resize logical volume to new_size bytes.
+ *
+ * \param   lv
+ *          Logical volume handle.
+ * \param   new_size
+ *          New size in bytes.
+ * \return  0 (success) or -1 (failure).
+ *
+ */
+int lvm_lv_resize(const lv_t *lv, uint64_t new_size);
+
 /************************** physical volume handling ************************/
 
 /**
@@ -616,4 +628,16 @@
  */
 uint64_t lvm_pv_get_mda_count(const pv_t *pv);
 
+/**
+ * Resize physical volume to new_size bytes.
+ *
+ * \param   pv
+ *          Physical volume handle.
+ * \param   new_size
+ *          New size in bytes.
+ * \return  0 (success) or -1 (failure).
+ *
+ */
+int lvm_pv_resize(const pv_t *pv, uint64_t new_size);
+
 #endif /* _LIB_LVM_H */
--- LVM2/liblvm/lvm_lv.c	2009/07/26 20:58:11	1.7
+++ LVM2/liblvm/lvm_lv.c	2009/07/27 21:00:50	1.8
@@ -173,3 +173,10 @@
 	}
 	return 0;
 }
+
+int lvm_lv_resize(const lv_t *lv, uint64_t new_size)
+{
+	/* FIXME: add lv resize code here */
+	log_error("NOT IMPLEMENTED YET\n");
+	return -1;
+}
--- LVM2/liblvm/lvm_pv.c	2009/07/26 13:06:59	1.2
+++ LVM2/liblvm/lvm_pv.c	2009/07/27 21:00:50	1.3
@@ -42,3 +42,10 @@
 {
 	return (uint64_t) pv_mda_count(pv);
 }
+
+int lvm_pv_resize(const pv_t *pv, uint64_t new_size)
+{
+	/* FIXME: add pv resize code here */
+	log_error("NOT IMPLEMENTED YET\n");
+	return -1;
+}


