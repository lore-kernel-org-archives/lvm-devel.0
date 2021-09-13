From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:13 +0000 (GMT)
Subject: main - cov: initialize attr
Message-ID: <20210913103613.BC8E33858006@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a8ee13900db58b018e143fbf6a3435c7803e82fe
Commit:        a8ee13900db58b018e143fbf6a3435c7803e82fe
Parent:        be1c2a1ae2da445309f04ac4e3ed7470ff29d436
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 10 22:32:26 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: initialize attr

---
 lib/activate/activate.c    | 2 +-
 lib/metadata/cache_manip.c | 2 +-
 lib/metadata/lv_manip.c    | 2 +-
 lib/metadata/raid_manip.c  | 4 ++--
 lib/misc/lvm-exec.c        | 2 +-
 5 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b44efc617..727bd2386 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1491,7 +1491,7 @@ int lvs_in_vg_opened(const struct volume_group *vg)
  */
 int raid4_is_supported(struct cmd_context *cmd, const struct segment_type *segtype)
 {
-	unsigned attrs;
+	unsigned attrs = 0;
 
 	if (segtype_is_raid4(segtype) &&
 	    (!segtype->ops->target_present ||
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 98821430f..b717e8a36 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -749,7 +749,7 @@ static const char *_get_default_cache_policy(struct cmd_context *cmd)
 static cache_metadata_format_t _get_default_cache_metadata_format(struct cmd_context *cmd)
 {
 	const struct segment_type *segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_CACHE);
-	unsigned attr;
+	unsigned attr = 0;
 	cache_metadata_format_t f;
 
 	if (!segtype ||
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4697ebbd8..e2efbf03a 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5216,7 +5216,7 @@ static int _lvresize_check(struct logical_volume *lv,
 
 	if (lv_is_raid(lv) &&
 	    lp->resize == LV_REDUCE) {
-		unsigned attrs;
+		unsigned attrs = 0;
 		const struct segment_type *segtype = first_seg(lv)->segtype;
 
 		if (!segtype->ops->target_present ||
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f0d401cde..60a10332e 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -46,7 +46,7 @@ static int _check_restriping(uint32_t new_stripes, struct logical_volume *lv)
  */
 static int _reshape_is_supported(struct cmd_context *cmd, const struct segment_type *segtype)
 {
-	unsigned attrs;
+	unsigned attrs = 0;
 
 	if (!segtype->ops->target_present ||
             !segtype->ops->target_present(cmd, NULL, &attrs) ||
@@ -65,7 +65,7 @@ static int _reshape_is_supported(struct cmd_context *cmd, const struct segment_t
 static int _rebuild_with_emptymeta_is_supported(struct cmd_context *cmd,
 						const struct segment_type *segtype)
 {
-	unsigned attrs;
+	unsigned attrs = 0;
 
 	if (!segtype->ops->target_present ||
             !segtype->ops->target_present(cmd, NULL, &attrs) ||
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index c60897ca6..77a2e0653 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -50,7 +50,7 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	     int *rstatus, int sync_needed)
 {
 	pid_t pid;
-	int status;
+	int status = 0;
 	char buf[PATH_MAX * 2];
 
 	if (rstatus)


