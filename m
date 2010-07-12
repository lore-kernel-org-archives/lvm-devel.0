From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Jul 2010 18:12:25 -0000
Subject: LVM2 ./WHATS_NEW liblvm/lvm2app.h
Message-ID: <20100712181225.17641.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-12 18:12:24

Modified files:
	.              : WHATS_NEW 
	liblvm         : lvm2app.h 

Log message:
	Update comments about memory handling in lvm2app.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1664&r2=1.1665
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm2app.h.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/WHATS_NEW	2010/07/12 11:37:49	1.1664
+++ LVM2/WHATS_NEW	2010/07/12 18:12:23	1.1665
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Update comments about memory handling in lvm2app.h.
   Add more verbose messages while checking volume_list and hosttags settings.
   Add log_error when strdup fails in {vg|lv}_change_tag().
   Remove unnecessary includes in liblvm files.
--- LVM2/liblvm/lvm2app.h	2010/06/16 13:01:25	1.17
+++ LVM2/liblvm/lvm2app.h	2010/07/12 18:12:23	1.18
@@ -929,8 +929,8 @@
  *
  * \memberof lv_t
  *
- * Memory is allocated using dm_malloc() and caller must free the memory
- * using dm_free().
+ * The memory allocated for the uuid is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
  *
  * \param   lv
  * Logical volume handle.
@@ -945,8 +945,8 @@
  *
  * \memberof lv_t
  *
- * Memory is allocated using dm_malloc() and caller must free the memory
- * using dm_free().
+ * The memory allocated for the uuid is tied to the vg_t handle and will be
+ * released when lvm_vg_close() is called.
  *
  * \param   lv
  * Logical volume handle.


