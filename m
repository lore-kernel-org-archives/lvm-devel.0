From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:27:57 +0000 (UTC)
Subject: master - devmapper: fix compilation without devmapper
Message-ID: <20140430082757.1D71B60DAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=675fcfe9b7f5d624f8b9e45bc61869ef0ff830b5
Commit:        675fcfe9b7f5d624f8b9e45bc61869ef0ff830b5
Parent:        905d4cda7ae17aa1eb8f8d0e85b9d577e650bb60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 29 13:22:10 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:29 2014 +0200

devmapper: fix compilation without devmapper

Fix compilation when configured with --disable-devmapper option.
---
 lib/activate/activate.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a7ec751..6a9dd0a 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -200,7 +200,7 @@ int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_vol
 }
 
 #ifndef DEVMAPPER_SUPPORT
-void set_activation(int act)
+void set_activation(int act, int silent)
 {
 	static int warned = 0;
 
@@ -282,15 +282,15 @@ int lv_raid_message(const struct logical_volume *lv, const char *msg)
 {
 	return 0;
 }
-int lv_cache_block_info(const struct logical_volume *lv,
+int lv_cache_block_info(struct logical_volume *lv,
 			uint32_t *chunk_size, uint64_t *dirty_count,
 			uint64_t *used_count, uint64_t *total_count)
 {
 	return 0;
 }
-int lv_cache_policy_info(const struct logical_volume *lv,
-			 char **policy_name, int *policy_argc,
-			 const char *const **policy_argv)
+int lv_cache_policy_info(struct logical_volume *lv,
+			 const char **policy_name, int *policy_argc,
+			 const char ***policy_argv)
 {
 	return 0;
 }
@@ -309,6 +309,10 @@ int lv_thin_pool_transaction_id(const struct logical_volume *lv,
 {
 	return 0;
 }
+int lv_thin_device_id(const struct logical_volume *lv, uint32_t *device_id)
+{
+	return 0;
+}
 int lvs_in_vg_activated(const struct volume_group *vg)
 {
 	return 0;


