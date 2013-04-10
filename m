From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 10 Apr 2013 21:47:25 +0000 (UTC)
Subject: master - mirror: Fix overly-concerning warning on mirror up-convert failure.
Message-ID: <20130410214725.12462672@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbcbb677313aa8a4116bcfd13ceccef05fb1f9a9
Commit:        cbcbb677313aa8a4116bcfd13ceccef05fb1f9a9
Parent:        95d28735ea3ad54be972707e40ee0211106ef1d1
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Apr 10 16:47:04 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Apr 10 16:47:04 2013 -0500

mirror:  Fix overly-concerning warning on mirror up-convert failure.

Attempting to up-convert an inactive mirror when there is insufficient
space leads to the following message:
  Unable to allocate extents for mirror(s).
  ABORTING: Failed to remove temporary mirror layer inactive_mimagetmp_3.
  Manual cleanup with vgcfgrestore and dmsetup may be required.
This is caused by a failure to execute the 'deactivate_lv' function in
the error condition.  The deactivate returns an error because the LV is
already inactive.  This patch checks if the LV is activate and calls
deactivate_lv only if it is.  This allows the error cleanup code to work
properly in this condition.

It wasn't that big of a deal anyway, since there was no previous vg_commit
that needed to be reverted.  IOW, no harm was done if the allocation failed.
The message was scary and useless.
---
 tools/lvconvert.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 318ac9b..7b4bb6e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1303,7 +1303,8 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 				    MIRROR_BY_LV)) {
 			layer_lv = seg_lv(first_seg(lv), 0);
 			if (!remove_layer_from_lv(lv, layer_lv) ||
-			    !deactivate_lv(cmd, layer_lv) ||
+			    (lv_is_active(layer_lv) &&
+			     !deactivate_lv(cmd, layer_lv)) ||
 			    !lv_remove(layer_lv) || !vg_write(lv->vg) ||
 			    !vg_commit(lv->vg)) {
 				log_error("ABORTING: Failed to remove "


