From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Aug 2012 20:30:32 +0000 (UTC)
Subject: master - report: provide discard field value in full
Message-ID: <20120807203032.C4B6C3283@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4fdfa9d314eeb02b6e4eb0e4bf053415b6b825e
Commit:        e4fdfa9d314eeb02b6e4eb0e4bf053415b6b825e
Parent:        0650a16a2273f9ce8b224533083055b67cbff892
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 7 18:48:34 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 7 18:48:34 2012 +0100

report: provide discard field value in full

I think it's better not to abbreviate human-readable fields like
'discard' to a single character.  Users can truncate it to the
first character themselves if they wish.

It's confusing to use the variable name discard for different things in
different places - use discard_str when it's a string not the enum.
---
 lib/report/columns.h |    2 +-
 lib/report/report.c  |   21 +++++----------------
 2 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 7bcaaab..c869d14 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -140,7 +140,7 @@ FIELD(SEGS, seg, NUM, "Region", region_size, 6, size32, region_size, "For mirror
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunksize, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "Chunk", list, 5, chunksize, chunk_size, "For snapshots, the unit of data used when tracking changes.", 0)
 FIELD(SEGS, seg, NUM, "#Thins", list, 4, thincount, thin_count, "For thin pools, the number of thin volumes in this pool.", 0)
-FIELD(SEGS, seg, NUM, "Dis", list, 3, discard, discard, "For thin pools, discard handling (i)ignore, (n)o_passdown, (p)assdown.", 0)
+FIELD(SEGS, seg, NUM, "Discard", list, 7, discard, discard, "For thin pools, how discards are handled.", 0)
 FIELD(SEGS, seg, NUM, "Zero", list, 4, thinzero, zero, "For thin pools, if zeroing is enabled.", 0)
 FIELD(SEGS, seg, NUM, "TransId", list, 4, transactionid, transaction_id, "For thin pools, the transaction id.", 0)
 FIELD(SEGS, seg, NUM, "Start", list, 5, segstart, seg_start, "Offset within the LV to the start of the segment in current units.", 0)
diff --git a/lib/report/report.c b/lib/report/report.c
index 3121db3..b66be4f 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -568,29 +568,18 @@ static int _discard_disp(struct dm_report *rh, struct dm_pool *mem,
 			 struct dm_report_field *field,
 			 const void *data, void *private)
 {
-	static const struct {
-		const char c[2];
-		unsigned val;
-		thin_discard_t discard;
-	} const arr[] = {
-		{ "p", 0, THIN_DISCARD_PASSDOWN },
-		{ "n", 1, THIN_DISCARD_NO_PASSDOWN },
-		{ "i", 2, THIN_DISCARD_IGNORE },
-		{ "" }
-	};
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-	unsigned i = 0;
+	const char *discard_str;
 
 	if (seg_is_thin_volume(seg))
 		seg = first_seg(seg->pool_lv);
 
 	if (seg_is_thin_pool(seg)) {
-		while (arr[i].c[0] && seg->discard != arr[i].discard)
-			i++;
+		discard_str = get_pool_discard_name(seg->discard);
+		return dm_report_field_string(rh, field, &discard_str);
+	}
 
-		dm_report_field_set_value(field, arr[i].c, &arr[i].val);
-	} else
-		dm_report_field_set_value(field, "", NULL);
+	dm_report_field_set_value(field, "", NULL);
 
 	return 1;
 }


