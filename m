From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Jul 2009 01:20:23 -0000
Subject: LVM2/liblvm lvm.h lvm_vg.c
Message-ID: <20090723012023.22248.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-23 01:20:23

Modified files:
	liblvm         : lvm.h lvm_vg.c 

Log message:
	Update lvm_vg_create to use NULL / non-NULL return for the time being.
	
	Some of the error interface is still TBD.  Rather than exporting a lot
	of codes, etc, just use a simple pass / fail.  The allows our unit test
	to not segfault if trying to create a VG that already exists.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/liblvm/lvm.h	2009/07/22 22:24:16	1.5
+++ LVM2/liblvm/lvm.h	2009/07/23 01:20:22	1.6
@@ -110,8 +110,7 @@
  * \param   libh
  *          Handle obtained from lvm_create.
  *
- * \return  A VG handle with error code set appropriately.
- * FIXME: Update error handling description after errno and logging patches
+ * \return  non-NULL vg handle (success) or NULL (failure)
  */
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name);
 
--- LVM2/liblvm/lvm_vg.c	2009/07/22 22:24:16	1.3
+++ LVM2/liblvm/lvm_vg.c	2009/07/23 01:20:22	1.4
@@ -24,7 +24,15 @@
 
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
 {
-	return vg_create((struct cmd_context *)libh, vg_name);
+	vg_t *vg;
+
+	vg = vg_create((struct cmd_context *)libh, vg_name);
+	/* FIXME: error handling is still TBD */
+	if (vg_read_error(vg)) {
+		vg_release(vg);
+		return NULL;
+	}
+	return vg;
 }
 
 int lvm_vg_extend(vg_t *vg, const char *device)


