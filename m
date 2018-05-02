From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 2 May 2018 14:00:51 -0400
Subject: master - device/bcache: reorder includes
Message-ID: <201805021800.w42I0pcb031571@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8fd300f7df2c9f3a170dbf335d0ab242249c0627
Commit:        8fd300f7df2c9f3a170dbf335d0ab242249c0627
Parent:        972b535220d2d9f4df583bcc5e67e8cc14ca6294
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 2 18:59:43 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 2 18:59:43 2018 +0100

device/bcache: reorder includes

---
 lib/device/bcache.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.h b/lib/device/bcache.h
index a72b83b..2b0d965 100644
--- a/lib/device/bcache.h
+++ b/lib/device/bcache.h
@@ -15,12 +15,12 @@
 #ifndef BCACHE_H
 #define BCACHE_H
 
+#include "libdevmapper.h"
+
 #include <linux/fs.h>
 #include <stdint.h>
 #include <stdbool.h>
 
-#include "libdevmapper.h"
-
 /*----------------------------------------------------------------*/
 
 // FIXME: move somewhere more sensible


