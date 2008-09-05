From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 05 Sep 2008 10:04:44 -0500
Subject: [Patch - addendum] Fix mirror corruption during primary device failure
Message-ID: <1220627086.11979.4.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There is another spot in tools/vgreduce.c that makes the same error as
in lib/metadata/mirror.c.  This patch addresses that.

I did duplicate the function I created in mirror.c in the previous
patch.

 brassow

Index: LVM2-cvs/tools/vgreduce.c
===================================================================
--- LVM2-cvs.orig/tools/vgreduce.c
+++ LVM2-cvs/tools/vgreduce.c
@@ -130,6 +130,31 @@ static int _remove_lv(struct cmd_context
 	return 1;
 }
 
+/*
+ * FIXME: exact same function as found in lib/metadata/mirror.c
+ *        should reuse code
+ */
+static int shift_mirror_legs(struct lv_segment *mirrored_seg, int leg_pos)
+{
+       int i;
+       struct lv_segment_area area;
+
+
+       if (leg_pos >= mirrored_seg->area_count)
+               return 1; /* -EINVAL */
+
+       area = mirrored_seg->areas[leg_pos];
+
+       /* Shift everyone down to fill the hole */
+       for (i = leg_pos+1; i < mirrored_seg->area_count; i++)
+               mirrored_seg->areas[i-1] = mirrored_seg->areas[i];
+
+       /* Stick this one at the end */
+       mirrored_seg->areas[i-1] = area;
+
+       return 0;
+}
+
 static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 {
 	struct list *pvh, *pvht;
@@ -250,9 +275,7 @@ static int _make_vg_consistent(struct cm
 					    lvl2->lv != seg_lv(mirrored_seg, s))
 						continue;
 					list_del(&lvl2->list);
-					area = mirrored_seg->areas[mimages - 1];
-					mirrored_seg->areas[mimages - 1] = mirrored_seg->areas[s];
-					mirrored_seg->areas[s] = area;
+					shift_mirror_legs(mirrored_seg, s);
 					mimages--;	/* FIXME Assumes uniqueness */
 				}
 			}



