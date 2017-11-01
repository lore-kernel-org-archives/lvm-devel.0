From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 31 Oct 2017 20:02:14 -0400
Subject: master - lv_manip: hide layered LV temporarily
Message-ID: <201711010002.vA102EtI010613@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=373372c8ab3749bc76ced37cec04b00aae6e5979
Commit:        373372c8ab3749bc76ced37cec04b00aae6e5979
Parent:        0ba393954296ee9521fffc83fbf4507060f08ffd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 1 00:51:39 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 1 00:55:24 2017 +0100

lv_manip: hide layered LV temporarily

Since vg_validate() now rejects LVs without segments and
insert_layer_for_segments_on_pv() gets just created
'layer_lv' without segment,  it needs to be hidden
from vg->lvs during processing of _align_segment_boundary_to_pe_range()
as this function calls  lv_validate() and now requires
vg to be consistent.  LV is then put back into vg->lvs.
---
 lib/metadata/lv_manip.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f0e492b..c4c2fdf 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7054,9 +7054,19 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 			 layer_lv->name, lv_where->name,
 			 pvl ? pv_dev_name(pvl->pv) : "any");
 
+	/* Temporarily hide layer_lv from vg->lvs list
+	 * so the lv_split_segment() passes  vg_validate()
+	 * since here layer_lv has empty segment list */
+	if (!(lvl = find_lv_in_vg(lv_where->vg, layer_lv->name)))
+		return_0;
+	dm_list_del(&lvl->list);
+
 	if (!_align_segment_boundary_to_pe_range(lv_where, pvl))
 		return_0;
 
+	/* Put back layer_lv in vg->lv */
+	dm_list_add(&lv_where->vg->lvs, &lvl->list);
+
 	/* Work through all segments on the supplied PV */
 	dm_list_iterate_items(seg, &lv_where->segments) {
 		for (s = 0; s < seg->area_count; s++) {


