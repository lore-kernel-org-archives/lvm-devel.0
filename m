From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 14 Dec 2018 09:17:09 -0500
Subject: master - libdm: use libdm header
Message-ID: <201812141417.wBEEH9Pw010266@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c377643339be97940554323909d51b12c933f9e
Commit:        3c377643339be97940554323909d51b12c933f9e
Parent:        46a8d2e898a48b1df86fe07d13df8aa994e32808
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 13:11:48 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 15:08:34 2018 +0100

libdm: use libdm header

User libdm header file.
---
 WHATS_NEW_DM            |    1 +
 libdm/datastruct/list.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index aa1734c..3d45bc3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.155 - 
 ====================================
+  Include correct internal header inside libdm list.c.
   Enhance ioctl flattening and add parameters only when needed.
   Add DM_DEVICE_ARM_POLL for API completness matching kernel.
   Do not add parameters for RESUME with DM_DEVICE_CREATE dm task.
diff --git a/libdm/datastruct/list.c b/libdm/datastruct/list.c
index d80cb9a..74053c5 100644
--- a/libdm/datastruct/list.c
+++ b/libdm/datastruct/list.c
@@ -13,7 +13,7 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "lib/misc/lib.h"
+#include "libdm/misc/dmlib.h"
 #include <assert.h>
 
 /*


