From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:21:50 -0500
Subject: [PATCH 02/21] Move vg_t, lv_t, and pv_t from metadata-exported.h into lvm2.h
In-Reply-To: <1234153329-2829-2-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h                       |    9 +++++++++
 lib/metadata/metadata-exported.h |    8 +-------
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index f348035..bfa1852 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -60,4 +60,13 @@ void lvm_destroy(lvm_handle_t libh);
  */
 int lvm_reload_config(lvm_handle_t libh);
 
+struct volume_group;
+typedef struct volume_group vg_t;
+
+struct physical_volume;
+typedef struct physical_volume pv_t;
+
+struct logical_volume;
+typedef struct logical_volume lv_t;
+
 #endif
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a1c45ce..257bf91 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -22,13 +22,7 @@
 #define _LVM_METADATA_EXPORTED_H
 
 #include "uuid.h"
-
-struct physical_volume;
-typedef struct physical_volume pv_t;
-struct volume_group;
-typedef struct volume_group vg_t;
-
-struct logical_volume;
+#include "lvm2.h"
 
 struct lv_segment;
 struct pv_segment;
-- 
1.6.0.5


