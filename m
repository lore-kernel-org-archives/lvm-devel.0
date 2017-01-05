From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jan 2017 14:56:39 +0000 (UTC)
Subject: master - debug: show proper error message for layer mismatch
Message-ID: <20170105145639.D735960E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6a74025df1afb3d76bec435bc6a40d649217b42
Commit:        d6a74025df1afb3d76bec435bc6a40d649217b42
Parent:        3e9c03cbbcf102029d11f312e1cd1d20284b6d03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 5 15:49:07 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jan 5 15:54:14 2017 +0100

debug: show proper error message for layer mismatch

Show proper internal error for failing command when there are some
inconsitencies in sizes of LV and its layer instead of rather
meaningless error code 5.

(Could be hit i.e. if user tried to 'resize' cached LV and then
uncache such LV.)
---
 lib/metadata/lv_manip.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a954bf7..ad400b2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6537,8 +6537,11 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	    parent_seg->area_count != 1 ||
 	    seg_type(parent_seg, 0) != AREA_LV ||
 	    layer_lv != seg_lv(parent_seg, 0) ||
-	    parent_lv->le_count != layer_lv->le_count)
-		return_0;
+	    parent_lv->le_count != layer_lv->le_count) {
+		log_error(INTERNAL_ERROR "Inconsistent sizes of layer %s.",
+			  display_lvname(lv));
+		return 0;
+	}
 
 	if (!lv_empty(parent_lv))
 		return_0;


