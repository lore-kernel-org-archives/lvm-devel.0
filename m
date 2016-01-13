From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 13 Jan 2016 13:46:45 +0000 (UTC)
Subject: master - lv: use brackets for invisible devices when formatting device segments
Message-ID: <20160113134645.2CC1A6066A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7f74a995029caa41ee3cf9aec0bd024a34bfd89a
Commit:        7f74a995029caa41ee3cf9aec0bd024a34bfd89a
Parent:        f1fe7af014003b6a4b1000eaf3f78a61885f8182
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 12 14:49:56 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 13 11:20:04 2016 +0100

lv: use brackets for invisible devices when formatting device segments

Include brackets for the name if the dev is invisible.
This change applies to all callers of _format_pvsegs fn:
  - lvseg_devices (the "lvs -o devices")
  - lvseg_metadata_devices (the "lvs -o metadata_devices)
  - lvseg_seg_pe_ranges (the "lvs -o seg_pe_ranges")
  - lvseg_seg_metadata_le_ranges (the "lvs -o seg_metadata_le_ranges")
---
 lib/metadata/lv.c |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 368ba19..d591f24 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -31,10 +31,13 @@ static int _utsinit = 0;
 static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			    int range_format, int metadata_areas_only)
 {
+	static const char pool_grow_object_failed_msg[] = "dm_pool_grow_object failed";
 	unsigned int s;
 	const char *name = NULL;
 	uint32_t extent = 0;
 	char extent_str[32];
+	struct logical_volume *lv;
+	int visible = 1;
 
 	if (!dm_pool_begin_object(mem, 256)) {
 		log_error("dm_pool_begin_object failed");
@@ -47,7 +50,9 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 	for (s = 0; s < seg->area_count; s++) {
 		switch (metadata_areas_only ? seg_metatype(seg, s) : seg_type(seg, s)) {
 		case AREA_LV:
-			name = metadata_areas_only ? seg_metalv(seg, s)->name : seg_lv(seg, s)->name;
+			lv = metadata_areas_only ? seg_metalv(seg, s) : seg_lv(seg, s);
+			visible = lv_is_visible(lv);
+			name = lv->name;
 			extent = metadata_areas_only ? seg_le(seg, s) : 0;
 			break;
 		case AREA_PV:
@@ -66,8 +71,18 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			return NULL;
 		}
 
+		if (!visible && !dm_pool_grow_object(mem, "[", 1)) {
+			log_error(pool_grow_object_failed_msg);
+			return NULL;
+		}
+
 		if (!dm_pool_grow_object(mem, name, strlen(name))) {
-			log_error("dm_pool_grow_object failed");
+			log_error(pool_grow_object_failed_msg);
+			return NULL;
+		}
+
+		if (!visible && !dm_pool_grow_object(mem, "]", 1)) {
+			log_error(pool_grow_object_failed_msg);
 			return NULL;
 		}
 
@@ -79,7 +94,7 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 			return NULL;
 		}
 		if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-			log_error("dm_pool_grow_object failed");
+			log_error(pool_grow_object_failed_msg);
 			return NULL;
 		}
 
@@ -90,14 +105,14 @@ static char *_format_pvsegs(struct dm_pool *mem, const struct lv_segment *seg,
 				return NULL;
 			}
 			if (!dm_pool_grow_object(mem, extent_str, strlen(extent_str))) {
-				log_error("dm_pool_grow_object failed");
+				log_error(pool_grow_object_failed_msg);
 				return NULL;
 			}
 		}
 
 		if ((s != seg->area_count - 1) &&
 		    !dm_pool_grow_object(mem, range_format ? " " : ",", 1)) {
-			log_error("dm_pool_grow_object failed");
+			log_error(pool_grow_object_failed_msg);
 			return NULL;
 		}
 	}


