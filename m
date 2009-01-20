From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 Jan 2009 20:37:42 -0000
Subject: LVM2/tools lvm-static.c
Message-ID: <20090120203742.24198.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-01-20 20:37:42

Modified files:
	tools          : lvm-static.c 

Log message:
	Use tools.h in for lvm-static.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/tools/lvm-static.c	2009/01/20 17:07:53	1.7
+++ LVM2/tools/lvm-static.c	2009/01/20 20:37:41	1.8
@@ -13,8 +13,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "tools.h"
 #include "lvm2cmdline.h"
-#include "lib.h"
 
 int main(int argc, char **argv)
 {


