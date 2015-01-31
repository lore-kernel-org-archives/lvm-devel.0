From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:12:56 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - add dump.h
Message-ID: <20150131141256.40E26610E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0dbd1141e34a89b107158e29387ba826b1606541
Commit:        0dbd1141e34a89b107158e29387ba826b1606541
Parent:        645f4fad66ce5d649776a1ec98171616b5bec40e
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Jan 31 15:12:50 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Jan 31 15:12:50 2015 +0100

add dump.h

---
 lib/metadata/dump.h |   74 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/dump.h b/lib/metadata/dump.h
new file mode 100644
index 0000000..2de9f86
--- /dev/null
+++ b/lib/metadata/dump.h
@@ -0,0 +1,74 @@
+/* FIXME: REMOVEME: development output */
+static void dump_area(const char *msg, struct lv_segment *seg, unsigned a)
+{
+	struct physical_volume *pv;
+	struct pv_segment *pvseg;
+	struct logical_volume *lv;
+
+	if (seg_type(seg, a) == AREA_PV) {
+		pv = seg_pv(seg, a);
+		pvseg = seg_pvseg(seg, a);
+
+		printf("pv[(%u]=%p", a, pv);
+		printf(" pe=%u", pvseg->pe);
+		printf(" len=%u\n", pvseg->len);
+
+	} else if (seg_type(seg, a) == AREA_LV) {
+		lv = seg_lv(seg, a);
+
+		printf("seg_lv[seg, %u]=%p",	a, lv);
+		printf(" name=%s\n",lv->name);
+
+	} else
+		printf("v[%u]=AREA_UNASSIGNED\n", a);
+}
+
+static void dump_lv(const char *msg, struct logical_volume *lv);
+static void dump_seg(const char *msg, struct lv_segment *seg, int self)
+{
+	unsigned a;
+
+	printf("%s seg=%p", msg, seg);
+	printf(" name=%s", 		lvseg_name(seg));
+	printf(" lv->name=%s",		seg->lv->name);
+	printf(" lv=%p", 		seg->lv);
+	printf(" le=%u", 		seg->le);
+	printf(" len=%u", 		seg->len);
+	printf(" status=%llu", 		(unsigned long long) seg->status);
+	printf(" stripe_size=%u", 	seg->stripe_size);
+	printf(" area_count=%u",	seg->area_count);
+	printf(" area_len=%u", 		seg->area_len);
+	printf(" chunk_size=%u", 	seg->chunk_size);
+	printf(" region_size=%u\n", 	seg->region_size);
+
+	if (self)
+		return;
+
+	for (a = 0; a < seg->area_count; a++) {
+		if (seg->meta_areas && seg_metatype(seg, a) == AREA_LV)
+			dump_lv(msg, seg_metalv(seg, a));
+		else {
+			dump_area(msg, seg, a);
+			continue;
+		}
+
+		if (seg_type(seg, a) == AREA_LV)
+			dump_lv(msg, seg_lv(seg, a));
+		else
+			dump_area(msg, seg, a);
+	}
+}
+
+static void dump_lv(const char *msg, struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	printf("---> %s lv=%p <---\n", msg, lv);
+	printf("lv->name=%s",	lv->name);
+	printf(" le_count=%u",	lv->le_count);
+	printf(" size=%llu",	(unsigned long long) lv->size);
+	printf(" status=%lX\n",	lv->status);
+
+	dm_list_iterate_items(seg, &lv->segments)
+		dump_seg(msg, seg, 0);
+}


