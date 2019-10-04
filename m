From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 4 Oct 2019 11:33:23 -0400
Subject: master - vdo: correct internal API for set_vdo_write_policy
Message-ID: <201910041533.x94FXNnP031037@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c756f7680202f0a59dea917527e95f68c7a9af4b
Commit:        c756f7680202f0a59dea917527e95f68c7a9af4b
Parent:        9d8a028e8cd9aaa34030af26046b04d87149be32
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 4 14:59:25 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 4 17:31:55 2019 +0200

vdo: correct internal API for set_vdo_write_policy

This is 'setting' function.
---
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/vdo_manip.c         |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index ea8635e..081e9a5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1308,7 +1308,7 @@ int parse_vdo_pool_status(struct dm_pool *mem, const struct logical_volume *vdo_
 struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 					   const struct dm_vdo_target_params *vtp,
 					   uint32_t *virtual_extents);
-int get_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy);
+int set_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy);
 int fill_vdo_target_params(struct cmd_context *cmd,
 			   struct dm_vdo_target_params *vtp,
 			   struct profile *profile);
diff --git a/lib/metadata/vdo_manip.c b/lib/metadata/vdo_manip.c
index 4877e77..7ed3ef9 100644
--- a/lib/metadata/vdo_manip.c
+++ b/lib/metadata/vdo_manip.c
@@ -404,7 +404,7 @@ struct logical_volume *convert_vdo_pool_lv(struct logical_volume *data_lv,
 	return data_lv;
 }
 
-int get_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy)
+int set_vdo_write_policy(enum dm_vdo_write_policy *vwp, const char *policy)
 {
 	if (strcasecmp(policy, "sync") == 0)
 		*vwp = DM_VDO_WRITE_POLICY_SYNC;
@@ -467,7 +467,7 @@ int fill_vdo_target_params(struct cmd_context *cmd,
 		find_config_tree_int(cmd, allocation_vdo_max_discard_CFG, profile);
 
 	policy = find_config_tree_str(cmd, allocation_vdo_write_policy_CFG, profile);
-	if (!get_vdo_write_policy(&vtp->write_policy, policy))
+	if (!set_vdo_write_policy(&vtp->write_policy, policy))
 		return_0;
 
 	return 1;


