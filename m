From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 3 Jan 2011 15:07:40 -0000
Subject: LVM2/test/api percent.c
Message-ID: <20110103150740.29956.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-03 15:07:40

Modified files:
	test/api       : percent.c 

Log message:
	Use system assert in test/api/percent.c, for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/api/percent.c	2010/12/21 01:14:34	1.3
+++ LVM2/test/api/percent.c	2011/01/03 15:07:39	1.4
@@ -12,9 +12,10 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lvm2app.h"
+#undef NDEBUG
 
-#define assert(x) do { if (!(x)) goto bad; } while (0)
+#include "lvm2app.h"
+#include "assert.h"
 
 int main(int argc, char *argv[])
 {
@@ -52,13 +53,4 @@
 
         lvm_vg_close(vg);
         return 0;
-
-bad:
-	if (handle && lvm_errno(handle))
-		fprintf(stderr, "LVM Error: %s\n", lvm_errmsg(handle));
-	if (vg)
-		lvm_vg_close(vg);
-	if (handle)
-		lvm_quit(handle);
-	return 1;
 }


