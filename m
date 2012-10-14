From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 21:21:11 +0000 (UTC)
Subject: master - cleanup: resolve dereferencing type-punned pointer
Message-ID: <20121014212111.8DA8E22FD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6595cae6e9b65658430714b9731b604c036d0816
Commit:        6595cae6e9b65658430714b9731b604c036d0816
Parent:        4379365cae3a1efa8299e0d6cf248520a136c798
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 20:51:07 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 14 23:14:00 2012 +0200

cleanup: resolve dereferencing type-punned pointer

fix gcc warning:
dereferencing type-punned pointer will break strict-aliasing rules
Replace call by value and pass just const pointer to pvid.
---
 lib/cache/lvmetad.c     |    8 ++++----
 lib/cache/lvmetad.h     |    2 +-
 lib/metadata/metadata.c |    2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 1a52787..a3b45d5 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -444,7 +444,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
-		if (pvl->pv->dev && !lvmetad_pv_found(pvl->pv->id, pvl->pv->dev,
+		if (pvl->pv->dev && !lvmetad_pv_found(&pvl->pv->id, pvl->pv->dev,
 						      vg->fid ? vg->fid->fmt : pvl->pv->fmt,
 						      pvl->pv->label_sector, NULL, NULL))
 			return 0;
@@ -657,7 +657,7 @@ static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 	return 1;
 }
 
-int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_type *fmt,
+int lvmetad_pv_found(const struct id *pvid, struct device *device, const struct format_type *fmt,
 		     uint64_t label_sector, struct volume_group *vg, activation_handler handler)
 {
 	char uuid[64];
@@ -670,7 +670,7 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	if (!lvmetad_active() || test_mode())
 		return 1;
 
-	if (!id_write_format(&pvid, uuid, sizeof(uuid)))
+	if (!id_write_format(pvid, uuid, sizeof(uuid)))
                 return_0;
 
 	pvmeta = dm_config_create();
@@ -848,7 +848,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	 * *exact* image of the system, the lvmetad instance that went out of
 	 * sync needs to be killed.
 	 */
-	if (!lvmetad_pv_found(*(struct id *)dev->pvid, dev, lvmcache_fmt(info),
+	if (!lvmetad_pv_found((const struct id *) &dev->pvid, dev, lvmcache_fmt(info),
 			      label->sector, baton.vg, handler)) {
 		release_vg(baton.vg);
 		goto_bad;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 724922d..5f0f552 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -93,7 +93,7 @@ int lvmetad_vg_remove(struct volume_group *vg);
  * number on the cached and on the discovered PV match but the metadata content
  * does not.
  */
-int lvmetad_pv_found(struct id pvid, struct device *device,
+int lvmetad_pv_found(const struct id *pvid, struct device *device,
 		     const struct format_type *fmt, uint64_t label_sector,
 		     struct volume_group *vg, activation_handler handler);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5a633b6..c210a63 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3807,7 +3807,7 @@ int pv_write(struct cmd_context *cmd __attribute__((unused)),
 	if (!pv->fmt->ops->pv_write(pv->fmt, pv))
 		return_0;
 
-	if (!lvmetad_pv_found(pv->id, pv->dev, pv->fmt, pv->label_sector,
+	if (!lvmetad_pv_found(&pv->id, pv->dev, pv->fmt, pv->label_sector,
 			      NULL, NULL))
 		return_0;
 


