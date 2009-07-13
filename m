From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 13 Jul 2009 00:12:34 -0400
Subject: [PATCH 1/5] Define handles to liblvm objects for pv, vg, lv, lvseg, pvseg.
In-Reply-To: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
References: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1247458358-24590-2-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Define the 5 main liblvm objects to be the pv, vg, lv, lvseg, and pvseg.
We need handles defined to all these objects in order for liblvm to be
equivalent to the reporting commands pvs, vgs, and lvs.

- move vg_t, lv_t, and pv_t from metadata-exported.h into lvm.h
- move lv_segment and pv_segment forward declarations into lvm.h
- add lvseg_t and pvseg_t to lvm.h

NOTE: We currently have an inconsistency in handle definitions.
lvm_t is defined as a pointer, while these other handles are just
structures.  We should pick one scheme and be consistent - perhaps
define all handles as pointers (this is what I've seen elsewhere).

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/metadata/metadata-exported.h |   11 +----------
 liblvm/lvm.h                     |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 7a2f813..47b2e8a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -22,16 +22,7 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
-
-struct physical_volume;
-typedef struct physical_volume pv_t;
-struct volume_group;
-typedef struct volume_group vg_t;
-
-struct logical_volume;
-
-struct lv_segment;
-struct pv_segment;
+#include "lvm.h"
 
 #define MAX_STRIPES 128U
 #define SECTOR_SHIFT 9L
diff --git a/liblvm/lvm.h b/liblvm/lvm.h
index 3b60510..4e71e15 100644
--- a/liblvm/lvm.h
+++ b/liblvm/lvm.h
@@ -18,6 +18,20 @@
 
 #include <stdint.h>
 
+/* Internal object structures */
+struct volume_group;
+struct physical_volume;
+struct logical_volume;
+struct lv_segment;
+struct pv_segment;
+
+/* liblvm handles to objects pv, vg, lv, pvseg, lvseg */
+typedef struct volume_group vg_t;
+typedef struct physical_volume pv_t;
+typedef struct logical_volume lv_t;
+typedef struct pv_segment pvseg_t;
+typedef struct lv_segment lvseg_t;
+
 struct lvm; /* internal data */
 
 /**
@@ -54,4 +68,5 @@ void lvm_destroy(lvm_t libh);
  */
 int lvm_reload_config(lvm_t libh);
 
+
 #endif /* _LIB_LVM_H */
-- 
1.6.0.6


