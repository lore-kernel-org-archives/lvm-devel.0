From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:09 +0000 (GMT)
Subject: master - writecache: correct usage of const struct
Message-ID: <20200828195909.A269A386EC3C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=03f9cd95b4bad1e055ce932742426b0724f607c3
Commit:        03f9cd95b4bad1e055ce932742426b0724f607c3
Parent:        fb7a3fe8d652592c41e149702efd101cc2954fed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 18:26:40 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

writecache: correct usage of const struct

---
 lib/metadata/writecache_manip.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index fade82ef5..0230d6160 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -59,7 +59,7 @@ int lv_is_writecache_cachevol(const struct logical_volume *lv)
 }
 
 static int _get_writecache_kernel_error(struct cmd_context *cmd,
-					struct logical_volume *lv,
+					const struct logical_volume *lv,
 					uint32_t *kernel_error)
 {
 	struct lv_with_info_and_seg_status status;
@@ -241,7 +241,7 @@ static int _lv_detach_writecache_cachevol_active(struct logical_volume *lv, int
 	struct volume_group *vg = lv->vg;
 	struct logical_volume *lv_fast;
 	struct logical_volume *lv_wcorig;
-	struct logical_volume *lv_old;
+	const struct logical_volume *lv_old;
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t kernel_error = 0;
 
@@ -299,7 +299,7 @@ static int _lv_detach_writecache_cachevol_active(struct logical_volume *lv, int
 	 * check for kernel errors based on the old version of LV which
 	 * is still present in the kernel.
 	 */
-	if (!(lv_old = (struct logical_volume *)lv_committed(lv))) {
+	if (!(lv_old = lv_committed(lv))) {
 		log_error("Failed to get lv_committed in writecache detach.");
 		return 0;
 	}


