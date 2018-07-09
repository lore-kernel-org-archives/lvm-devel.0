From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 9 Jul 2018 09:35:39 -0400
Subject: master - vgchange: vdo support
Message-ID: <201807091335.w69DZd17030854@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12213445b5f86155665ed6f027082e93c4f6cf85
Commit:        12213445b5f86155665ed6f027082e93c4f6cf85
Parent:        7b8aa4af57a8064ea3fa29355283aada2dac0db0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 1 12:03:23 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 9 15:29:16 2018 +0200

vgchange: vdo support

Support vgchange usage with VDO segtype.
Also changing extent size need small update for vdo virtual extent.

TODO: API needs enhancements so it's not about adding ifs() everywhere.
---
 lib/metadata/vg.c |    5 +++++
 tools/vgchange.c  |    7 ++++++-
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 75a054f..20c2aec 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -504,6 +504,11 @@ int vg_set_extent_size(struct volume_group *vg, uint32_t new_extent_size)
 					     new_extent_size))
 				return_0;
 
+			if (!_recalc_extents(&seg->vdo_pool_virtual_extents, lv->name,
+					     " virtual extents", old_extent_size,
+					     new_extent_size))
+				return_0;
+
 			/* foreach area */
 			for (s = 0; s < seg->area_count; s++) {
 				switch (seg_type(seg, s)) {
diff --git a/tools/vgchange.c b/tools/vgchange.c
index c444c30..fa0fd53 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -107,6 +107,9 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (lv_is_mirror_image(lv) || lv_is_mirror_log(lv))
 			continue;
 
+		if (lv_is_vdo_pool(lv))
+			continue;
+
 		if (lv_activation_skip(lv, activate, arg_is_set(cmd, ignoreactivationskip_ARG)))
 			continue;
 
@@ -219,7 +222,9 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 
 	       	if ((lv_open = lvs_in_vg_opened(vg))) {
 			dm_list_iterate_items(lvl, &vg->lvs) {
-				if (lv_is_visible(lvl->lv) && !lv_check_not_in_use(lvl->lv, 1)) {
+				if (lv_is_visible(lvl->lv) &&
+				    !lv_is_vdo_pool(lvl->lv) && // FIXME: API skip flag missing
+				    !lv_check_not_in_use(lvl->lv, 1)) {
 					log_error("Can't deactivate volume group \"%s\" with %d open logical volume(s)",
 						  vg->name, lv_open);
 					return 0;


