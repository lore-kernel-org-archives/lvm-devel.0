From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jan 2010 00:18:38 -0000
Subject: LVM2/daemons/dmeventd/plugins/snapshot dmevent ...
Message-ID: <20100122001838.9440.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-22 00:18:37

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	fix lib include

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/01/21 22:15:46	1.5
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/01/22 00:18:37	1.6
@@ -12,7 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "dmlib.h"
+#include "lib.h"
 
 #include "lvm2cmd.h"
 #include "errors.h"


