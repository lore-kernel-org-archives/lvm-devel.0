From: Joe Thornber <thornber@sourceware.org>
Date: Thu, 7 Jun 2018 11:21:04 -0400
Subject: master - device_mapper: fixup a couple of includes
Message-ID: <201806071521.w57FL4TX012759@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=74460cd009267564be032a373e78ec5eba67b4ce
Commit:        74460cd009267564be032a373e78ec5eba67b4ce
Parent:        3e781ea446bb7ddc9a494cbba6b6104dd51c3910
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed Jun 6 14:45:16 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed Jun 6 14:45:16 2018 +0100

device_mapper: fixup a couple of includes

"libdevmapper.h" -> "device_mapper/libdevmapper.h"
---
 device_mapper/misc/dm-logging.h |    2 +-
 device_mapper/misc/dmlib.h      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/device_mapper/misc/dm-logging.h b/device_mapper/misc/dm-logging.h
index a35480e..e355bc5 100644
--- a/device_mapper/misc/dm-logging.h
+++ b/device_mapper/misc/dm-logging.h
@@ -16,7 +16,7 @@
 #ifndef _DM_LOGGING_H
 #define _DM_LOGGING_H
 
-#include "libdevmapper.h"
+#include "device_mapper/libdevmapper.h"
 
 extern dm_log_with_errno_fn dm_log_with_errno;
 
diff --git a/device_mapper/misc/dmlib.h b/device_mapper/misc/dmlib.h
index ba376bc..88b6ac3 100644
--- a/device_mapper/misc/dmlib.h
+++ b/device_mapper/misc/dmlib.h
@@ -26,7 +26,7 @@
 #define _REENTRANT
 #define _GNU_SOURCE
 
-#include "libdevmapper.h"
+#include "device_mapper/libdevmapper.h"
 #include "lib/misc/util.h"
 #include "dm-logging.h"
 


