From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:11 +0000 (UTC)
Subject: master - cleanup: drop assign before use
Message-ID: <20161003155111.C90D760A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9fe4f2337bfaaa30e647ed1d20be7fb76d598559
Commit:        9fe4f2337bfaaa30e647ed1d20be7fb76d598559
Parent:        cea441f4d1e19f170d9161203ef843c59f3fbf70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 3 13:04:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:49:55 2016 +0200

cleanup: drop assign before use

Drop unneeded assigns singe vars are set later in code before
their first use (Coverity).
---
 daemons/lvmetad/lvmetad-core.c |    2 +-
 lib/cache/lvmcache.c           |    2 +-
 lib/metadata/raid_manip.c      |    2 +-
 lib/metadata/thin_manip.c      |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 36a5cec..ee0c52f 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1249,8 +1249,8 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	const char *old_vgid = NULL;
 	const char *new_vgid = NULL;
 	const char *new_metadata_vgid;
+	int new_seq;
 	int old_seq = -1;
-	int new_seq = -1;
 	int needs_repair = 0;
 	int abort_daemon = 0;
 	int retval = 0;
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 5e402f0..a15481f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -858,7 +858,7 @@ static void _choose_preferred_devs(struct cmd_context *cmd,
 				   struct dm_list *add_cache_devs)
 {
 	char uuid[64] __attribute__((aligned(8)));
-	const char *reason = "none";
+	const char *reason;
 	struct dm_list altdevs;
 	struct dm_list new_unused;
 	struct dev_types *dt = cmd->dev_types;
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index f8a3c46..e87a4e5 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -956,7 +956,7 @@ static int _raid_add_images(struct logical_volume *lv,
 			    int commit, int use_existing_area_len)
 {
 	int rebuild_flag_cleared = 0;
-	struct lv_segment *seg = first_seg(lv);
+	struct lv_segment *seg;
 	uint32_t s;
 
 	if (!_raid_add_images_without_commit(lv, new_count, pvs, use_existing_area_len))
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index a02a7e6..e7a2c33 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -472,7 +472,7 @@ static int _check_pool_create(const struct logical_volume *lv)
 
 int update_pool_lv(struct logical_volume *lv, int activate)
 {
-	int monitored = DMEVENTD_MONITOR_IGNORE;
+	int monitored;
 	int ret = 1;
 
 	if (!lv_is_thin_pool(lv)) {


