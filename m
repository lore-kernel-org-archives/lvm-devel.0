From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 2 May 2018 14:45:55 -0400
Subject: master - bcache: reorder includes in .c file too
Message-ID: <201805021845.w42IjtPx007499@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90d0ff66362f3f21f79b5204bcc072c12185883b
Commit:        90d0ff66362f3f21f79b5204bcc072c12185883b
Parent:        8fd300f7df2c9f3a170dbf335d0ab242249c0627
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 2 19:45:06 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 2 19:45:06 2018 +0100

bcache: reorder includes in .c file too

---
 lib/device/bcache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index 68d2e53..742b7ee 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -14,6 +14,10 @@
 
 #define _GNU_SOURCE
 
+#include "bcache.h"
+#include "dm-logging.h"
+#include "log.h"
+
 #include <errno.h>
 #include <fcntl.h>
 #include <sys/stat.h>
@@ -28,10 +32,6 @@
 #include <sys/ioctl.h>
 #include <sys/user.h>
 
-#include "bcache.h"
-#include "dm-logging.h"
-#include "log.h"
-
 #define SECTOR_SHIFT 9L
 
 //----------------------------------------------------------------


