From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun,  8 Aug 2010 10:57:15 +0200
Subject: [PATCH 03/25] Skip check missing rem.VGs for non-activate locks
In-Reply-To: <cover.1281256234.git.zkabelac@redhat.com>
References: <cover.1281256234.git.zkabelac@redhat.com>
Message-ID: <5e0428222a9ff6bc7d71745bd6e77db8d6c87447.1281256235.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Skip call for checking whether this LV needs to locks some
more remote VGs (applies to replicator_dev devices).

The effect is, that deactivation of replicator-dev devices does
not require to take a lock for remote VGs, so avoids repeated invoke
of deactivate_lv.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/locking/locking.h            |    2 +-
 lib/metadata/metadata-exported.h |    2 +-
 lib/metadata/replicator_manip.c  |    5 ++++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/lib/locking/locking.h b/lib/locking/locking.h
index 488d194..af02844 100644
--- a/lib/locking/locking.h
+++ b/lib/locking/locking.h
@@ -136,7 +136,7 @@ int check_lvm1_vg_inactive(struct cmd_context *cmd, const char *vgname);
 	(vg_is_clustered((lv)->vg) ? LCK_CLUSTER_VG : 0)
 
 #define lock_lv_vol(cmd, lv, flags)	\
-	(find_replicator_vgs((lv)) ? \
+	((find_replicator_vgs((lv), (flags))) ? \
 		lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv)) : \
 		0)
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index a72a6bf..41ef566 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -831,7 +831,7 @@ struct cmd_vg *cmd_vg_lookup(struct dm_list *cmd_vgs,
 int cmd_vg_read(struct cmd_context *cmd, struct dm_list *cmd_vgs);
 void cmd_vg_release(struct dm_list *cmd_vgs);
 
-int find_replicator_vgs(struct logical_volume *lv);
+int find_replicator_vgs(struct logical_volume *lv, uint32_t flags);
 
 int lv_read_replicator_vgs(struct logical_volume *lv);
 void lv_release_replicator_vgs(struct logical_volume *lv);
diff --git a/lib/metadata/replicator_manip.c b/lib/metadata/replicator_manip.c
index b3a2fff..272ceac 100644
--- a/lib/metadata/replicator_manip.c
+++ b/lib/metadata/replicator_manip.c
@@ -608,11 +608,14 @@ void cmd_vg_release(struct dm_list *cmd_vgs)
  * Find all needed remote VGs for processing given LV.
  * Missing VGs are added to VG's cmd_vg list and flag cmd_missing_vgs is set.
  */
-int find_replicator_vgs(struct logical_volume *lv)
+int find_replicator_vgs(struct logical_volume *lv, uint32_t flags)
 {
 	struct replicator_site *rsite;
 	int ret = 1;
 
+	if ((flags & LCK_TYPE_MASK) == LCK_READ)
+		return 1; /* no need to check for remote vgs */
+
 	if (!lv_is_replicator_dev(lv))
 		return 1;
 
-- 
1.7.2.1


