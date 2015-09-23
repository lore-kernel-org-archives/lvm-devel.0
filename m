From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 23 Sep 2015 14:27:09 +0000 (UTC)
Subject: master - libdm: Improve raid segment parameter handling.
Message-ID: <20150923142709.2751A6030E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96a621019871c5fcde42aeae9df465231302b859
Commit:        96a621019871c5fcde42aeae9df465231302b859
Parent:        192d9ad97769f2c16f3ebe67e51cfb287e67f67c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Sep 23 15:25:46 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 23 15:25:46 2015 +0100

libdm: Improve raid segment parameter handling.

---
 libdm/libdm-deptree.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index cc00014..1a66d98 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2369,6 +2369,20 @@ static int _mirror_emit_segment_line(struct dm_task *dmt, struct load_segment *s
 
 	return 1;
 }
+ 
+/* Is parameter non-zero? */
+#define PARAM_IS_SET(p) (p) ? 1 : 0
+
+/* Return number of bits assuming 4 * 64 bit size */
+static int _get_params_count(uint64_t bits)
+{
+	int r = 0;
+
+	r += 2 * hweight32(bits & 0xFFFFFFFF);
+	r += 2 * hweight32(bits >> 32);
+
+	return r;
+}
 
 static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 				   uint32_t minor, struct load_segment *seg,
@@ -2382,25 +2396,11 @@ static int _raid_emit_segment_line(struct dm_task *dmt, uint32_t major,
 	if ((seg->flags & DM_NOSYNC) || (seg->flags & DM_FORCESYNC))
 		param_count++;
 
-	if (seg->region_size)
-		param_count += 2;
-
-	if (seg->writebehind)
-		param_count += 2;
-
-	if (seg->min_recovery_rate)
-		param_count += 2;
-
-	if (seg->max_recovery_rate)
-		param_count += 2;
-
-	/* rebuilds is 64-bit */
-	param_count += 2 * hweight32(seg->rebuilds & 0xFFFFFFFF);
-	param_count += 2 * hweight32(seg->rebuilds >> 32);
+	param_count += 2 * (PARAM_IS_SET(seg->region_size) + PARAM_IS_SET(seg->writebehind) +
+			    PARAM_IS_SET(seg->min_recovery_rate) + PARAM_IS_SET(seg->max_recovery_rate));
 
-	/* rebuilds is 64-bit */
-	param_count += 2 * hweight32(seg->writemostly & 0xFFFFFFFF);
-	param_count += 2 * hweight32(seg->writemostly >> 32);
+	param_count += _get_params_count(seg->rebuilds);
+	param_count += _get_params_count(seg->writemostly);
 
 	if ((seg->type == SEG_RAID1) && seg->stripe_size)
 		log_error("WARNING: Ignoring RAID1 stripe size");


