From: David Teigland <teigland@sourceware.org>
Date: Tue, 4 Feb 2020 17:13:03 -0500
Subject: master - writecache: fix splitcache when origin is raid
Message-ID: <65020.120020417125501343@us-mta-292.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a6078f96168e860474b42c42b1924fc353c4558
Commit:        2a6078f96168e860474b42c42b1924fc353c4558
Parent:        9255c7148ac3d920aafe58f78a9672dd3a0967bd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 4 16:05:56 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 4 16:12:09 2020 -0600

writecache: fix splitcache when origin is raid

---
 lib/metadata/lv_manip.c        | 13 +++++++++----
 test/shell/writecache-split.sh | 17 +++++++++++++++++
 2 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c9f7348..3604a63 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4535,6 +4535,9 @@ static int _for_each_sub_lv(struct logical_volume *lv, int level,
 		if (!_for_each_sub_lv(seg->pool_lv, level, fn, data))
 			return_0;
 
+		if (!_for_each_sub_lv(seg->writecache, level, fn, data))
+			return_0;
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
@@ -6989,7 +6992,7 @@ int move_lv_segments(struct logical_volume *lv_to,
 int remove_layer_from_lv(struct logical_volume *lv,
 			 struct logical_volume *layer_lv)
 {
-	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig", "_vdata" };
+	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig", "_wcorig", "_vdata" };
 	struct logical_volume *parent_lv;
 	struct lv_segment *parent_seg;
 	struct segment_type *segtype;
@@ -7069,8 +7072,8 @@ int remove_layer_from_lv(struct logical_volume *lv,
 	 *   currently supported only for thin data layer
 	 *   FIXME: without strcmp it breaks mirrors....
 	 */
-	if (!strstr(layer_lv->name, "_mimage"))
-		for (r = 0; r < DM_ARRAY_SIZE(_suffixes); ++r)
+	if (!strstr(layer_lv->name, "_mimage")) {
+		for (r = 0; r < DM_ARRAY_SIZE(_suffixes); ++r) {
 			if (strstr(layer_lv->name, _suffixes[r]) == 0) {
 				lv_names.old = layer_lv->name;
 				lv_names.new = parent_lv->name;
@@ -7078,6 +7081,8 @@ int remove_layer_from_lv(struct logical_volume *lv,
 					return_0;
 				break;
 			}
+		}
+	}
 
 	return 1;
 }
@@ -7093,7 +7098,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 					   uint64_t status,
 					   const char *layer_suffix)
 {
-	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig", "_vdata" };
+	static const char _suffixes[][8] = { "_tdata", "_cdata", "_corig", "_wcorig", "_vdata" };
 	int r;
 	char name[NAME_LEN];
 	struct dm_str_list *sl;
diff --git a/test/shell/writecache-split.sh b/test/shell/writecache-split.sh
index 7168d02..0f2dc47 100644
--- a/test/shell/writecache-split.sh
+++ b/test/shell/writecache-split.sh
@@ -128,6 +128,23 @@ vgextend --restoremissing $vg "$dev3"
 vgremove -ff $vg
 
 #
+# splitcache when origin is raid
+#
+
+vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
+
+lvcreate --type raid1 -m1 -L6 -n $lv1 -an $vg "$dev1" "$dev2"
+lvcreate -L6 -n $lv2 -an $vg "$dev3"
+lvconvert -y --type writecache --cachevol $lv2 $vg/$lv1
+lvchange -ay $vg/$lv1
+lvchange -an $vg/$lv1
+lvconvert --splitcache $vg/$lv1
+lvs $vg/$lv1
+lvs $vg/$lv2
+
+vgremove -ff $vg
+
+#
 # vgsplit should not separate cachevol from main lv
 #
 



