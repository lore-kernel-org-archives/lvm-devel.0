From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 9 Jul 2010 16:57:35 -0000
Subject: LVM2/liblvm lvm_lv.c lvm_misc.c lvm_misc.h lvm ...
Message-ID: <20100709165735.19125.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-09 16:57:34

Modified files:
	liblvm         : lvm_lv.c lvm_misc.c lvm_misc.h lvm_vg.c 

Log message:
	Remove unnecessary list of includes in liblvm files.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_misc.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_vg.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/liblvm/lvm_lv.c	2010/07/09 15:34:47	1.23
+++ LVM2/liblvm/lvm_lv.c	2010/07/09 16:57:34	1.24
@@ -22,8 +22,6 @@
 #include "activate.h"
 #include "lvm_misc.h"
 
-#include <string.h>
-
 static int _lv_check_handle(const lv_t lv, const int vg_writeable)
 {
 	if (!lv || !lv->vg || vg_read_error(lv->vg))
--- LVM2/liblvm/lvm_misc.c	2010/02/24 18:16:54	1.1
+++ LVM2/liblvm/lvm_misc.c	2010/07/09 16:57:34	1.2
@@ -12,7 +12,9 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "lvm2app.h"
 #include "lvm_misc.h"
+#include "lib.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list)
 {
--- LVM2/liblvm/lvm_misc.h	2010/02/24 18:16:54	1.1
+++ LVM2/liblvm/lvm_misc.h	2010/07/09 16:57:34	1.2
@@ -14,15 +14,7 @@
 #ifndef _LVM2APP_MISC_H
 #define _LVM2APP_MISC_H
 
-#include "lib.h"
-#include "lvm2app.h"
-#include "toolcontext.h"
-#include "metadata-exported.h"
-#include "archiver.h"
-#include "locking.h"
-#include "lvm-string.h"
-#include "lvmcache.h"
-#include "metadata.h"
+#include "libdevmapper.h"
 
 struct dm_list *tag_list_copy(struct dm_pool *p, struct dm_list *tag_list);
 
--- LVM2/liblvm/lvm_vg.c	2010/07/09 15:34:47	1.42
+++ LVM2/liblvm/lvm_vg.c	2010/07/09 16:57:34	1.43
@@ -15,17 +15,12 @@
 #include "lib.h"
 #include "lvm2app.h"
 #include "toolcontext.h"
-#include "metadata-exported.h"
+#include "metadata.h"
 #include "archiver.h"
 #include "locking.h"
-#include "lvm-string.h"
 #include "lvmcache.h"
-#include "metadata.h"
 #include "lvm_misc.h"
 
-#include <errno.h>
-#include <string.h>
-
 int lvm_vg_add_tag(vg_t vg, const char *tag)
 {
 	if (vg_read_error(vg))


