From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:50 +0000 (UTC)
Subject: master - metadata: add lv_is_historical fn to test if the LV is historical one
Message-ID: <20160303131950.C3ECF60232@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=baee45a103846a995b847e04c1c2985bfd1743e0
Commit:        baee45a103846a995b847e04c1c2985bfd1743e0
Parent:        673bc0636cf1a73321656b2129a6db1681fbd8f4
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:22:36 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:14 2016 +0100

metadata: add lv_is_historical fn to test if the LV is historical one

---
 lib/metadata/lv.c                |    5 +++++
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/snapshot_manip.c    |    3 +++
 3 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 459de6e..a5144e9 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -28,6 +28,11 @@
 static struct utsname _utsname;
 static int _utsinit = 0;
 
+int lv_is_historical(const struct logical_volume *lv)
+{
+	return lv->this_glv && lv->this_glv->is_historical;
+}
+
 static struct dm_list *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 				      int range_format, int metadata_areas_only,
 				      int mark_hidden)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index afd4723..b8699f7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1066,6 +1066,8 @@ int lv_is_cow_covering_origin(const struct logical_volume *lv);
 /* Test if given LV is visible from user's perspective */
 int lv_is_visible(const struct logical_volume *lv);
 
+int lv_is_historical(const struct logical_volume *lv);
+
 int pv_is_in_vg(struct volume_group *vg, struct physical_volume *pv);
 
 /* Given a cow or thin LV, return the snapshot lv_segment that uses it */
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 5fef001..e8a4dc5 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -113,6 +113,9 @@ int lv_is_cow_covering_origin(const struct logical_volume *lv)
 
 int lv_is_visible(const struct logical_volume *lv)
 {
+	if (lv_is_historical(lv))
+		return 1;
+
 	if (lv->status & SNAPSHOT)
 		return 0;
 


