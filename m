From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:53 +0000 (UTC)
Subject: master - liblvm: insert layer with subvolume renames
Message-ID: <20121003131453.41443F7A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d442c3ef0cec424db797714704859fbc2154f000
Commit:        d442c3ef0cec424db797714704859fbc2154f000
Parent:        4648d33d0704de23876582f35786023ebc954fe9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 6 15:21:18 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:13:32 2012 +0200

liblvm: insert layer with subvolume renames

Rename also subvolumes if we are inserting _tdata layer.
(Currently it breaks mirrors if it would be generic, needs fixing).
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   13 +++++++++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8050db8..dce8241 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Enhance insert_layer_for_lv() with recursive rename for _tdata LVs.
   Skip building dm tree for thin pool when called with origin_only flag.
   Add internal lv_rename_update() to rename LV without updating mda.
   Ensure descriptors 0,1,2 are always available.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index eb5794c..4f86d14 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3795,6 +3795,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	struct logical_volume *layer_lv;
 	struct segment_type *segtype;
 	struct lv_segment *mapseg;
+	struct lv_names lv_names;
 	unsigned exclusive = 0;
 
 	/* create an empty layer LV */
@@ -3891,6 +3892,18 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	lv_where->le_count = layer_lv->le_count;
 	lv_where->size = (uint64_t) lv_where->le_count * lv_where->vg->extent_size;
 
+	/*
+	 * recuresively rename sub LVs
+	 *   currently supported only for thin data layer
+	 *   FIXME: without strcmp it breaks mirrors....
+	 */
+	if (strcmp(layer_suffix, "_tdata") == 0) {
+		lv_names.old = lv_where->name;
+		lv_names.new = layer_lv->name;
+		if (!for_each_sub_lv(cmd, layer_lv, _rename_cb, (void *) &lv_names))
+			return 0;
+	}
+
 	return layer_lv;
 }
 


