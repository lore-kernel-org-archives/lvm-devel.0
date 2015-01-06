From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  6 Jan 2015 09:03:37 +0000 (UTC)
Subject: master - cmirror: do not check for cmirror availability when creating deactivated cluster mirrors
Message-ID: <20150106090337.8708760EAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=509650ec4cb1ef65e277870e96976d7dd8882170
Commit:        509650ec4cb1ef65e277870e96976d7dd8882170
Parent:        cba6186325f0d5806cf1ddec276b3bb8e178687a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 6 09:59:04 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 6 09:59:04 2015 +0100

cmirror: do not check for cmirror availability when creating deactivated cluster mirrors

When creating cluster mirrors while they're not supposed to be activated
immediately after creation, we don't need to check for cmirrord availability.
We can just create these mirrors and let the check to be done on activation
later on. This is addendum for commit cba6186325f0d5806cf1ddec276b3bb8e178687a.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 260a76a..457cf9e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6817,8 +6817,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (!(create_segtype = get_segtype_from_string(vg->cmd, "striped")))
 			return_0;
 	} else if (seg_is_mirrored(lp) || seg_is_raid(lp)) {
-		if (lp->activate != CHANGE_AEY && vg_is_clustered(vg) &&
-		    seg_is_mirrored(lp) && !seg_is_raid(lp) &&
+		if (is_change_activating(lp->activate) && (lp->activate != CHANGE_AEY) &&
+		    vg_is_clustered(vg) && seg_is_mirrored(lp) && !seg_is_raid(lp) &&
 		    !cluster_mirror_is_available(vg->cmd)) {
 			log_error("Shared cluster mirrors are not available.");
 			return NULL;


