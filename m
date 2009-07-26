From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 01:54:40 -0000
Subject: LVM2/liblvm lvm.h lvm_vg.c
Message-ID: <20090726015440.11181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 01:54:40

Modified files:
	liblvm         : lvm.h lvm_vg.c 

Log message:
	Update lvm_vg_extend to do an implicit pvcreate on the device.
	
	Although the tools do not currently do this, we update lvm_vg_extend
	to do an implicit pvcreate on an uninitialized device.  The tools will
	soon be refactored to do this as well, but more work is needed in the
	tools.  For now we update lvm_vg_extend since this is the behavior
	required by liblvm.
	With this change, the simple liblvm unit test, test/api/vgtest.c
	should pass whether or not the device is initialized.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/liblvm/lvm.h	2009/07/24 12:48:21	1.12
+++ LVM2/liblvm/lvm.h	2009/07/26 01:54:40	1.13
@@ -146,6 +146,10 @@
  * After successfully adding a device, use lvm_vg_write to commit the new VG
  * to disk.  Upon failure, retry the operation or release the VG handle with
  * lvm_vg_close.
+ * If the device is not initialized for LVM use, it will be initialized
+ * before adding to the VG.  Although some internal checks are done,
+ * the caller should be sure the device is not in use by other subsystems
+ * before calling lvm_vg_extend.
  *
  * \param   vg
  *          VG handle obtained from lvm_vg_create.
--- LVM2/liblvm/lvm_vg.c	2009/07/24 15:12:50	1.9
+++ LVM2/liblvm/lvm_vg.c	2009/07/26 01:54:40	1.10
@@ -12,9 +12,6 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include <errno.h>
-#include <string.h>
-
 #include "lib.h"
 #include "lvm.h"
 #include "toolcontext.h"
@@ -23,6 +20,10 @@
 #include "locking.h"
 #include "lvm-string.h"
 #include "lvmcache.h"
+#include "metadata.h"
+
+#include <errno.h>
+#include <string.h>
 
 vg_t *lvm_vg_create(lvm_t libh, const char *vg_name)
 {
@@ -47,6 +48,14 @@
 		return 0;
 	}
 
+	/* If device not initialized, pvcreate it */
+	if (!pv_by_path(vg->cmd, device) &&
+	   (!pvcreate_single(vg->cmd, device, NULL))) {
+		log_error("Unable to initialize device for LVM use\n");
+		unlock_vg(vg->cmd, VG_ORPHANS);
+		return 0;
+	}
+
 	if (!vg_extend(vg, 1, (char **) &device)) {
 		unlock_vg(vg->cmd, VG_ORPHANS);
 		return 0;


