From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  3 Apr 2013 10:55:05 +0000 (UTC)
Subject: master - lvmetad: Check for reappeared PVs.
Message-ID: <20130403105505.A84F35DA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=382fc878d7be5252d7ad93f2740ee25bd500d53e
Commit:        382fc878d7be5252d7ad93f2740ee25bd500d53e
Parent:        00ed6759c8cbf2f4497fa0d5f7df69780159539a
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Apr 3 12:48:28 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Apr 3 12:48:28 2013 +0200

lvmetad: Check for reappeared PVs.

---
 lib/cache/lvmetad.c     |    2 ++
 lib/metadata/metadata.c |    4 ++--
 lib/metadata/metadata.h |    3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index a7354a7..4ea3dbd 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -389,6 +389,8 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 				pvl->pv->dev = lvmcache_device(info);
 				if (!pvl->pv->dev)
 					pvl->pv->status |= MISSING_PV;
+				else
+					check_reappeared_pv(vg, pvl->pv);
 				if (!lvmcache_fid_add_mdas_pv(info, fid)) {
 					vg = NULL;
 					goto_out;	/* FIXME error path */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 911a4c8..bde1cb0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2836,8 +2836,8 @@ int vg_missing_pv_count(const struct volume_group *vg)
 	return ret;
 }
 
-static void check_reappeared_pv(struct volume_group *correct_vg,
-				struct physical_volume *pv)
+void check_reappeared_pv(struct volume_group *correct_vg,
+			 struct physical_volume *pv)
 {
 	struct pv_list *pvl;
 
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 0c13a97..4f504ed 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -491,4 +491,7 @@ int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 uint64_t find_min_mda_size(struct dm_list *mdas);
 char *tags_format_and_copy(struct dm_pool *mem, const struct dm_list *tags);
 
+void check_reappeared_pv(struct volume_group *correct_vg,
+			 struct physical_volume *pv);
+
 #endif


