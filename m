From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 May 2015 09:11:47 +0000 (UTC)
Subject: master - cleanup: gcc warn fix, don't hide pvs()
Message-ID: <20150527091147.EB4F96118E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1531ab26d047d95c03c6e5f101c52dd47d47435
Commit:        d1531ab26d047d95c03c6e5f101c52dd47d47435
Parent:        1aba262edb7f0bfac897223868779053f4921ff9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 22 16:23:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 27 11:10:43 2015 +0200

cleanup: gcc warn fix, don't hide pvs()

---
 daemons/lvmetad/lvmetad-core.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 449e332..db8d918 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -473,8 +473,8 @@ static void mark_outdated_pv(lvmetad_state *s, const char *vgid, const char *pvi
 static void chain_outdated_pvs(lvmetad_state *s, const char *vgid, struct dm_config_tree *metadata_cft, struct dm_config_node *metadata)
 {
 	struct dm_config_tree *cft = dm_hash_lookup(s->vgid_to_outdated_pvs, vgid), *pvmeta;
-	struct dm_config_node *pv, *res, *pvs = cft ? dm_config_find_node(cft->root, "outdated_pvs/pv_list") : NULL;
-	struct dm_config_value *pvs_v = pvs ? pvs->v : NULL;
+	struct dm_config_node *pv, *res, *out_pvs = cft ? dm_config_find_node(cft->root, "outdated_pvs/pv_list") : NULL;
+	struct dm_config_value *pvs_v = out_pvs ? out_pvs->v : NULL;
 	if (!pvs_v)
 		return;
 	if (!(res = make_config_node(metadata_cft, "outdated_pvs", metadata_cft->root, 0)))


