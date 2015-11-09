From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:20 +0000 (UTC)
Subject: master - lvmetad: validate mda is not NULL
Message-ID: <20151109092820.7B5C760DE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b83a20b80a1f2f239e5c8496e819edd039965a6c
Commit:        b83a20b80a1f2f239e5c8496e819edd039965a6c
Parent:        99def8f43912958bb8567a123b9725c0e3389048
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:43:09 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

lvmetad: validate mda is not NULL

Coverity: make it explicitely obvious metadata area is not NULL.
---
 lib/cache/lvmetad.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index c859413..5c10cf4 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1310,6 +1310,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	struct _lvmetad_pvscan_baton baton;
 	/* Create a dummy instance. */
 	struct format_instance_ctx fic = { .type = 0 };
+	struct metadata_area *mda;
 
 	if (!lvmetad_active()) {
 		log_error("Cannot proceed since lvmetad is not active.");
@@ -1353,8 +1354,11 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	 * Note that the single_device parameter also gets ignored and this code
 	 * can scan further devices.
 	 */
-	if (!baton.vg && !(baton.fid->fmt->features & FMT_MDAS))
-		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->ops->vg_read(baton.fid, lvmcache_vgname_from_info(info), NULL, NULL, NULL, 1);
+	if (!baton.vg && !(baton.fid->fmt->features & FMT_MDAS)) {
+		if ((mda = (struct metadata_area *)dm_list_first(&baton.fid->metadata_areas_in_use)))
+			baton.vg = mda->ops->vg_read(baton.fid, lvmcache_vgname_from_info(info),
+						     NULL, NULL, NULL, 1);
+	}
 
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);


