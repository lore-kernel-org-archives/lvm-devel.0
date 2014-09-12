From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Sep 2014 12:44:57 +0000 (UTC)
Subject: master - raid: check result of get_segtype_from_string
Message-ID: <20140912124457.A0E3C61021@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40b7b107b186e1680db05dcb05230b978852d010
Commit:        40b7b107b186e1680db05dcb05230b978852d010
Parent:        08bde75093665001e7b30a7491c5bb9a53383d56
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:48:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:45:50 2014 +0200

raid: check result of get_segtype_from_string

Error here is rather highly unpexpected for these types, but
stay consistent with rest of the code and don't use unchecked value.
---
 lib/metadata/raid_manip.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4bfe9c9..b7ba464 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -362,7 +362,9 @@ static int _alloc_image_component(struct logical_volume *lv,
 		return 0;
 	}
 
-	segtype = get_segtype_from_string(lv->vg->cmd, "striped");
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, "striped")))
+		return_0;
+
 	if (!lv_add_segment(ah, first_area, 1, tmp_lv, segtype, 0, status, 0)) {
 		log_error("Failed to add segment to LV, %s", img_name);
 		return 0;
@@ -833,7 +835,8 @@ static int _raid_extract_images(struct logical_volume *lv, uint32_t new_count,
 	if (!lvl_array)
 		return_0;
 
-	error_segtype = get_segtype_from_string(lv->vg->cmd, "error");
+	if (!(error_segtype = get_segtype_from_string(lv->vg->cmd, "error")))
+		return_0;
 
 	/*
 	 * We make two passes over the devices.


