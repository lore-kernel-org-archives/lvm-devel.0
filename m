From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 13 Nov 2015 18:06:38 +0000 (UTC)
Subject: master - pvmove: Remove unused find_pvmove_lv_from_pvname.
Message-ID: <20151113180638.A3F696163A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=970a42890905e62c43d20b3b4eb0ec7ece0af11c
Commit:        970a42890905e62c43d20b3b4eb0ec7ece0af11c
Parent:        b2e13ac552b6209c02c6e2c00aa0db2018135523
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 13 18:06:08 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 13 18:06:08 2015 +0000

pvmove: Remove unused find_pvmove_lv_from_pvname.

---
 lib/metadata/metadata-exported.h |    5 -----
 lib/metadata/mirror.c            |   18 ------------------
 2 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 2d118f4..f009687 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1185,11 +1185,6 @@ void lv_release_replicator_vgs(const struct logical_volume *lv);
 
 struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 				      struct device *dev, uint64_t lv_type);
-struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
-						  struct volume_group *vg,
-						  const char *name,
-						  const char *uuid,
-						  uint64_t lv_type);
 const struct logical_volume *find_pvmove_lv_in_lv(const struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv(const struct logical_volume *lv);
 const char *get_pvmove_pvname_from_lv_mirr(const struct logical_volume *lv_mirr);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index b69acf5..ae7b084 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1640,24 +1640,6 @@ struct logical_volume *find_pvmove_lv(struct volume_group *vg,
 	return NULL;
 }
 
-struct logical_volume *find_pvmove_lv_from_pvname(struct cmd_context *cmd,
-						  struct volume_group *vg,
-						  const char *name,
-						  const char *uuid __attribute__((unused)),
-						  uint64_t lv_type)
-{
-	struct physical_volume *pv;
-	struct logical_volume *lv;
-
-	if (!(pv = find_pv_by_name(cmd, name, 0, 0)))
-		return_NULL;
-
-	lv = find_pvmove_lv(vg, pv->dev, lv_type);
-	free_pv_fid(pv);
-
-	return lv;
-}
-
 struct dm_list *lvs_using_lv(struct cmd_context *cmd, struct volume_group *vg,
 			  struct logical_volume *lv)
 {


