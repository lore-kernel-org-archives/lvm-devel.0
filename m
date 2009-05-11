From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 11 May 2009 09:01:17 -0400
Subject: [PATCH 04/30] Update vg_size 'disp' function to call liblvm 'get' function.
In-Reply-To: <1242046903-15133-4-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-2-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-3-git-send-email-dwysocha@redhat.com>
	<1242046903-15133-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1242046903-15133-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move 'disp' function logic that calculates vg_size inside liblvm 'get'
function.

Should be no functional change.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/report/lvm_object_prop.c |    3 +--
 lib/report/report.c          |    3 ++-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/report/lvm_object_prop.c b/lib/report/lvm_object_prop.c
index e353772..15b7991 100644
--- a/lib/report/lvm_object_prop.c
+++ b/lib/report/lvm_object_prop.c
@@ -561,8 +561,7 @@ int lvm_vg_set_attr(vg_t *vg, const char *value)
  */
 uint64_t lvm_vg_get_size(const vg_t *vg)
 {
-	/* FIXME: implement function body */
-	return 0;
+	return (uint64_t) vg->extent_count * vg->extent_size;
 }
 int lvm_vg_set_size(vg_t *vg, const uint64_t value)
 {
diff --git a/lib/report/report.c b/lib/report/report.c
index 91e2b98..6865c20 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -23,6 +23,7 @@
 #include "segtype.h"
 #include "str_list.h"
 #include "lvmcache.h"
+#include "lvm_object_prop.h"
 
 struct lvm_report_object {
 	struct volume_group *vg;
@@ -672,7 +673,7 @@ static int _vgsize_disp(struct dm_report *rh, struct dm_pool *mem,
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t size;
 
-	size = (uint64_t) vg->extent_count * vg->extent_size;
+	size = lvm_vg_get_size(vg);
 
 	return _size64_disp(rh, mem, field, &size, private);
 }
-- 
1.6.0.6


