From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:45 +0000 (UTC)
Subject: master - raid: avoid _ at end of name of extracted metadata LV
Message-ID: <20161211223445.3C7A26038F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67f9e6b175815d7a91a10ecc3d5098d30dbfed91
Commit:        67f9e6b175815d7a91a10ecc3d5098d30dbfed91
Parent:        55ca8043d4bb0ef4435a24728cad34f8b0ff6c8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 10 14:51:00 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:20:51 2016 +0100

raid: avoid _ at end of name of extracted metadata LV

Do not generate @PREFIX at vg/LV1_rmeta_1_extracted_.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9e95792..63cdb89 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Avoid adding extra '_' at end of raid extracted images or metadata.
   Optimize another _rmeta clearing code.
   Fix deactivation of raid orphan devices for clustered VG.
   Fix lvconvert raid1 to mirror table reload order.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 159bfa2..58e3bcf 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1785,7 +1785,7 @@ static int _extract_image_component_error_seg(struct lv_segment *seg,
 	if (!remove_seg_from_segs_using_this_lv(lv, seg))
 		return_0;
 
-	if (!(lv->name = _generate_raid_name(lv, "extracted_", -1)))
+	if (!(lv->name = _generate_raid_name(lv, "extracted", -1)))
 		return_0;
 
 	if (set_error_seg && !replace_lv_with_error_segment(lv))


