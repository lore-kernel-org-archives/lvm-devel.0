From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 8 Jun 2018 09:26:02 -0400
Subject: master - various: some missing #include zalloc.h
Message-ID: <201806081326.w58DQ2DA015664@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ac89fb8603d891458cbb55d9071db0c5c057db3
Commit:        0ac89fb8603d891458cbb55d9071db0c5c057db3
Parent:        61e67e51e112a317886fcfc70b2d479d08cbda90
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 8 14:18:09 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 8 14:18:09 2018 +0100

various: some missing #include zalloc.h

---
 daemons/dmeventd/dmeventd.c           |    1 +
 daemons/dmeventd/libdevmapper-event.c |    1 +
 tools/tool.h                          |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 4b4e1f0..3ad81ce 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -16,6 +16,7 @@
  * dmeventd - dm event daemon to monitor active mapped devices
  */
 
+#include "base/memory/zalloc.h"
 #include "device_mapper/misc/dm-logging.h"
 
 #include "daemons/dmeventd/libdevmapper-event.h"
diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 4673f01..157b5f1 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -12,6 +12,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
+#include "base/memory/zalloc.h"
 #include "device_mapper/misc/dm-logging.h"
 #include "device_mapper/misc/dmlib.h"
 #include "daemons/dmeventd/libdevmapper-event.h"
diff --git a/tools/tool.h b/tools/tool.h
index a4cef3d..fb6cab8 100644
--- a/tools/tool.h
+++ b/tools/tool.h
@@ -24,6 +24,7 @@
 
 #include <unistd.h>
 
+#include "base/memory/zalloc.h"
 #include "device_mapper/all.h"
 #include "lib/misc/util.h"
 


