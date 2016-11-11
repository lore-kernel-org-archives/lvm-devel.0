From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 16:00:13 +0000 (UTC)
Subject: master - cleanup: avoid using double __ in extracted image name
Message-ID: <20161111160013.0C09C60255@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6db5b91231ce7ac84fafd4190bb3b4a079db1f49
Commit:        6db5b91231ce7ac84fafd4190bb3b4a079db1f49
Parent:        1bdcb01f63f849950f381a0a33a046f01f3d6f2a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 8 16:21:25 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:58:20 2016 +0100

cleanup: avoid using double __ in extracted image name

---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4d3d63f..b88ddcc 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1056,10 +1056,10 @@ static int _extract_image_components(struct lv_segment *seg, uint32_t idx,
 	seg_metatype(seg, idx) = AREA_UNASSIGNED;
 
 	/* FIXME Remove duplicated prefix? */
-	if (!(data_lv->name = _generate_raid_name(data_lv, "_extracted", -1)))
+	if (!(data_lv->name = _generate_raid_name(data_lv, "extracted", -1)))
 		return_0;
 
-	if (!(meta_lv->name = _generate_raid_name(meta_lv, "_extracted", -1)))
+	if (!(meta_lv->name = _generate_raid_name(meta_lv, "extracted", -1)))
 		return_0;
 
 	*extracted_rmeta = meta_lv;


