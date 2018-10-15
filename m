From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:56:14 -0400
Subject: master - cov: avoid selfrecursive inclusion of toolcontext.h
Message-ID: <201810151556.w9FFuEaB020759@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=06a4a356dbd320e23bd95e1feb045e91c63f3d51
Commit:        06a4a356dbd320e23bd95e1feb045e91c63f3d51
Parent:        fdd76da33dabcb6bd696f22413a692b9900d5bcc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:50:25 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: avoid selfrecursive inclusion of  toolcontext.h

---
 lib/filters/filter-md.c |    1 +
 lib/label/label.h       |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 4c3f23d..2214986 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -16,6 +16,7 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
+#include "lib/commands/toolcontext.h"
 
 #ifdef __linux__
 
diff --git a/lib/label/label.h b/lib/label/label.h
index a353a67..447fc86 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -19,7 +19,6 @@
 #include "lib/uuid/uuid.h"
 #include "lib/device/device.h"
 #include "lib/device/bcache.h"
-#include "lib/commands/toolcontext.h"
 
 #define LABEL_ID "LABELONE"
 #define LABEL_SIZE SECTOR_SIZE	/* Think very carefully before changing this */
@@ -27,6 +26,9 @@
 #define LABEL_SCAN_SIZE (LABEL_SCAN_SECTORS << SECTOR_SHIFT)
 
 struct labeller;
+struct dev_filter;
+struct cmd_context;
+struct logical_volume;
 
 /* On disk - 32 bytes */
 struct label_header {


