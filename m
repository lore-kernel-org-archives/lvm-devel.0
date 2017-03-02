From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 2 Mar 2017 16:22:38 -0500
Subject: master - lvs: enhance stripes and region size field descriptions
Message-ID: <201703022122.v22LMcjk031016@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca859b5149ad21adad9be03e8df794a496b746bb
Commit:        ca859b5149ad21adad9be03e8df794a496b746bb
Parent:        d3bcec599354df6c2645d5872be0bae293caccb4
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 2 22:21:23 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 2 22:22:16 2017 +0100

lvs: enhance stripes and region size field descriptions

Now that we got the "data_stripes" field key, adjust the "stripes" field description.
Enhance the "regionsize" field description to cover raids as well.
---
 lib/report/columns.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 0452641..31255d7 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -241,7 +241,7 @@ FIELD(VGS, vg, NUM, "#VMdaCps", cmd, 0, vgmdacopies, vg_mda_copies, "Target numb
  * SEGS type fields
  */
 FIELD(SEGS, seg, STR, "Type", list, 0, segtype, segtype, "Type of LV segment.", 0)
-FIELD(SEGS, seg, NUM, "#Str", list, 0, seg_stripes, stripes, "Number of data stripes or mirror/raid1 legs.", 0)
+FIELD(SEGS, seg, NUM, "#Str", list, 0, seg_stripes, stripes, "Number of stripes or mirror/raid1 legs.", 0)
 FIELD(SEGS, seg, NUM, "#DStr", list, 0, seg_data_stripes, data_stripes, "Number of data stripes or mirror/raid1 legs.", 0)
 FIELD(SEGS, seg, NUM, "RSize", list, 0, seg_reshape_len, reshape_len, "Size of out-of-place reshape space in current units.", 0)
 FIELD(SEGS, seg, SIZ, "RSize", list, 0, seg_reshape_len_le, reshape_len_le, "Size of out-of-place reshape space in physical extents.", 0)
@@ -250,7 +250,7 @@ FIELD(SEGS, seg, NUM, "DOff", list, 0, seg_data_offset, data_offset, "Data offse
 FIELD(SEGS, seg, NUM, "NOff", list, 0, seg_new_data_offset, new_data_offset, "New data offset after any reshape on each image device.", 0)
 FIELD(SEGS, seg, NUM, "#Par", list, 0, seg_parity_chunks, parity_chunks, "Number of (rotating) parity chunks.", 0)
 FIELD(SEGS, seg, SIZ, "Stripe", stripe_size, 0, size32, stripe_size, "For stripes, amount of data placed on one device before switching to the next.", 0)
-FIELD(SEGS, seg, SIZ, "Region", region_size, 0, size32, region_size, "For mirrors, the unit of data copied when synchronising devices.", 0)
+FIELD(SEGS, seg, SIZ, "Region", region_size, 0, size32, region_size, "For mirrors/raids, the unit of data per leg when synchronizing devices.", 0)
 FIELD(SEGS, seg, SIZ, "Chunk", list, 0, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 0, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
 FIELD(SEGS, seg, STR, "Discards", list, 0, discards, discards, "For thin pools, how discards are handled.", 0)


