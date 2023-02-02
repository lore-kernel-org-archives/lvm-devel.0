From: David Teigland <teigland@sourceware.org>
Date: Thu,  2 Feb 2023 22:18:31 +0000 (GMT)
Subject: main - vg_read: remove unused code for md components
Message-ID: <20230202221831.07D7E3858C53@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57ad78d4369ee531ab0173b42aa91048eb316353
Commit:        57ad78d4369ee531ab0173b42aa91048eb316353
Parent:        8498874147c886032817c24d11231947a041bc2e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Feb 2 16:15:13 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 2 16:15:13 2023 -0600

vg_read: remove unused code for md components

This code was no longer used after ommit
87ee401eea3c3c3958ec5cda6e5c246b80503b8c
---
 lib/metadata/metadata.c | 44 +-------------------------------------------
 1 file changed, 1 insertion(+), 43 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 30b2c1779..91a23f931 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4643,11 +4643,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct volume_group *vg, *vg_ret = NULL;
 	struct metadata_area *mda, *mda2;
 	unsigned use_precommitted = precommitted;
-	struct device *mda_dev, *dev_ret = NULL, *dev;
+	struct device *mda_dev, *dev_ret = NULL;
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
-	struct pv_list *pvl;
 	int found_old_metadata = 0;
-	int found_md_component = 0;
 	unsigned use_previous_vg;
 
 	log_debug_metadata("Reading VG %s %s", vgname ?: "<no name>", vgid ?: "<no vgid>");
@@ -4866,46 +4864,6 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		goto_out;
 	}
 
-	/*
-	 * Usually md components are eliminated during label scan, or duplicate
-	 * resolution, but sometimes an md component can get through and be
-	 * detected in set_pv_device() (which will do an md component check if
-	 * the device/PV sizes don't match.)  In this case we need to fix up
-	 * lvmcache to drop the component dev and fix up metadata_areas_in_use
-	 * to drop it also.
-	 */
-	if (found_md_component) {
-		dm_list_iterate_items(pvl, &vg_ret->pvs) {
-			if (!(dev = lvmcache_device_from_pv_id(cmd, &pvl->pv->id, NULL)))
-				continue;
-
-			/* dev_is_md_component set this flag if it was found */
-			if (!(dev->flags & DEV_IS_MD_COMPONENT))
-				continue;
-
-			log_debug_metadata("Drop dev for MD component from cache %s.", dev_name(dev));
-			lvmcache_del_dev(dev);
-
-			dm_list_iterate_items(mda, &fid->metadata_areas_in_use)
-				if (mda_get_device(mda) == dev) {
-					log_debug_metadata("Drop mda from MD component from mda list %s.", dev_name(dev));
-					dm_list_del(&mda->list);
-					break;
-				}
-		}
-	}
-
-	/*
-	 * After dropping MD components there may be no remaining legitimate
-	 * devices for this VG.
-	 */
-	if (!lvmcache_vginfo_from_vgid(vgid)) {
-		log_debug_metadata("VG %s not found on any remaining devices.", vgname);
-		release_vg(vg_ret);
-		vg_ret = NULL;
-		goto out;
-	}
-
 	/*
 	 * Correct the lvmcache representation of the VG using the metadata
 	 * that we have chosen above (vg_ret).

