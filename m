From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  3 Jun 2016 10:47:19 +0000 (UTC)
Subject: master - cleanup: compile fixes for --disable-devmapper
Message-ID: <20160603104719.3D1A460507@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e4db009b8f215cb7f593f4b76a6f4bd4293e2ca
Commit:        8e4db009b8f215cb7f593f4b76a6f4bd4293e2ca
Parent:        8012c223e0beb858bc2a6b1ea809c4a98a90a5c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 3 12:38:46 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 3 12:46:43 2016 +0200

cleanup: compile fixes for --disable-devmapper

Make lvm2 compilable when configured with: --disable-devmapper.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   15 ++-------------
 lib/mm/memlock.c        |    9 +++++++--
 3 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ea36c17..92b95c0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Fix compilation error when building with configure --disable-devmapper.
   Fix lvmconfig --type diff to display complete diff if config cascade used.
   Automatically filter out partitioned loop devices with partscan (losetup -P).
   Fix lvm devtypes internal error if -S used with field name from pvs/vgs/lvs.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1260b10..089af53 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -253,8 +253,9 @@ int lv_status(struct cmd_context *cmd, const struct lv_segment *lv_seg,
 int lv_cache_status(const struct logical_volume *cache_lv,
 		    struct lv_status_cache **status)
 {
+	return 0;
 }
-int lv_check_not_in_use(const struct logical_volume *lv)
+int lv_check_not_in_use(const struct logical_volume *lv, int error_if_used)
 {
         return 0;
 }
@@ -287,18 +288,6 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
 }
-int lv_cache_block_info(struct logical_volume *lv,
-			uint32_t *chunk_size, uint64_t *dirty_count,
-			uint64_t *used_count, uint64_t *total_count)
-{
-	return 0;
-}
-int lv_cache_policy_info(struct logical_volume *lv,
-			 const char **policy_name, int *policy_argc,
-			 const char ***policy_argv)
-{
-	return 0;
-}
 int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
 			 dm_percent_t *percent)
 {
diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 851cd33..da90144 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -72,6 +72,11 @@ void memlock_reset(void)
 	return;
 }
 
+int memlock_count_daemon(void)
+{
+	return 0;
+}
+
 #else				/* DEVMAPPER_SUPPORT */
 
 static size_t _size_stack;
@@ -645,9 +650,9 @@ void memlock_unlock(struct cmd_context *cmd)
 	_unlock_mem_if_possible(cmd);
 }
 
-#endif
-
 int memlock_count_daemon(void)
 {
 	return _memlock_count_daemon;
 }
+
+#endif


