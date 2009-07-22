From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 22 Jul 2009 22:24:17 -0000
Subject: LVM2/liblvm .exported_symbols lvm.h lvm_vg.c
Message-ID: <20090722222417.32676.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-22 22:24:17

Modified files:
	liblvm         : .exported_symbols lvm.h lvm_vg.c 

Log message:
	Add lvm_vg_open() to open an existing VG for reading or writing.
	
	lvm_vg_open() calls internal vg_read() function which is the entry point
	for reading an existing VG.  In addition to the mode, we include a 'flags'
	parameter for future extensions.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/.exported_symbols.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/liblvm/.exported_symbols	2009/07/22 03:13:13	1.3
+++ LVM2/liblvm/.exported_symbols	2009/07/22 22:24:16	1.4
@@ -5,6 +5,7 @@
 lvm_vg_extend
 lvm_vg_set_extent_size
 lvm_vg_write
+lvm_vg_open
 lvm_vg_close
 lvm_vg_remove
 lvm_errno
--- LVM2/liblvm/lvm.h	2009/07/16 03:07:46	1.4
+++ LVM2/liblvm/lvm.h	2009/07/22 22:24:16	1.5
@@ -190,4 +190,27 @@
  */
 int lvm_vg_close(vg_t *vg);
 
+/**
+ * Open an existing VG.
+ *
+ * Open a VG for reading or writing.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ *
+ * \param   vgname
+ *          Name of the VG to open.
+ *
+ * \param   mode
+ *          Open mode - either "r" (read) or "w" (read/write).
+ *          Any other character results in an error with EINVAL set.
+ *
+ * \param   flags
+ *          Open flags - currently ignored.
+ *
+ * \return  non-NULL VG handle (success) or NULL (failure).
+ */
+vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+		  uint32_t flags);
+
 #endif /* _LIB_LVM_H */
--- LVM2/liblvm/lvm_vg.c	2009/07/22 03:13:35	1.2
+++ LVM2/liblvm/lvm_vg.c	2009/07/22 22:24:16	1.3
@@ -12,6 +12,9 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <errno.h>
+#include <string.h>
+
 #include "lib.h"
 #include "lvm.h"
 #include "toolcontext.h"
@@ -80,3 +83,26 @@
 bad:
 	return 0;
 }
+
+vg_t *lvm_vg_open(lvm_t libh, const char *vgname, const char *mode,
+		  uint32_t flags)
+{
+	uint32_t internal_flags = 0;
+	vg_t *vg;
+
+	if (!strncmp(mode, "w", 1))
+		internal_flags |= READ_FOR_UPDATE;
+	else if (strncmp(mode, "r", 1)) {
+		log_errno(EINVAL, "Invalid VG open mode");
+		return NULL;
+	}
+
+	vg = vg_read((struct cmd_context *)libh, vgname, NULL, internal_flags);
+	if (vg_read_error(vg)) {
+		/* FIXME: use log_errno either here in inside vg_read */
+		vg_release(vg);
+		return NULL;
+	}
+
+	return vg;
+}


