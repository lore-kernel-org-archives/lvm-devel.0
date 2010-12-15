From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Dec 2010 12:49:55 -0000
Subject: LVM2 ./WHATS_NEW lib/device/device.c
Message-ID: <20101215124955.7535.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-12-15 12:49:55

Modified files:
	.              : WHATS_NEW 
	lib/device     : device.c 

Log message:
	Fix device.c #include to ensure 64-bit fopen64 use. (2.02.51)  (robbat2)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1837&r2=1.1838
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2010/12/13 10:49:02	1.1837
+++ LVM2/WHATS_NEW	2010/12/15 12:49:55	1.1838
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Fix device.c #include to ensure 64-bit fopen64 use. (2.02.51)
   Create /var/run/lvm directory during clvmd initialisation if missing.
   Use new dm_prepare_selinux_context instead of dm_set_selinux_context.
   Avoid revalidating the label cache immediately after scanning.
--- LVM2/lib/device/device.c	2010/10/20 15:07:30	1.35
+++ LVM2/lib/device/device.c	2010/12/15 12:49:55	1.36
@@ -13,7 +13,6 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include <libgen.h> /* dirname, basename */
 #include "lib.h"
 #include "lvm-types.h"
 #include "device.h"
@@ -21,6 +20,8 @@
 #include "filter.h"
 #include "xlate.h"
 
+#include <libgen.h> /* dirname, basename */
+
 /* See linux/genhd.h and fs/partitions/msdos */
 
 #define PART_MAGIC 0xAA55


