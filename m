From: David Teigland <teigland@sourceware.org>
Date: Tue, 6 Nov 2018 16:42:48 -0500
Subject: master - cache: clean up segment line creation
Message-ID: <201811062142.wA6Lgmur004739@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85b4b2f92490a7e12d3aaf67df1db7a0bcc6937e
Commit:        85b4b2f92490a7e12d3aaf67df1db7a0bcc6937e
Parent:        e26dacf30a656276afdc36516cb7b330da4ff705
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 5 15:50:37 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 6 11:36:28 2018 -0600

cache: clean up segment line creation

---
 device_mapper/libdm-deptree.c |   22 +++++++++++++---------
 1 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/device_mapper/libdm-deptree.c b/device_mapper/libdm-deptree.c
index 16858b4..5d03545 100644
--- a/device_mapper/libdm-deptree.c
+++ b/device_mapper/libdm-deptree.c
@@ -2544,7 +2544,7 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 				    char *params, size_t paramsize)
 {
 	int pos = 0;
-	/* unsigned feature_count; */
+	unsigned feature_count;
 	char data[DM_FORMAT_DEV_BUFSIZE];
 	char metadata[DM_FORMAT_DEV_BUFSIZE];
 	char origin[DM_FORMAT_DEV_BUFSIZE];
@@ -2569,19 +2569,23 @@ static int _cache_emit_segment_line(struct dm_task *dmt,
 	EMIT_PARAMS(pos, " %u", seg->data_block_size);
 
 	/* Features */
-	/* feature_count = hweight32(seg->flags); */
-	/* EMIT_PARAMS(pos, " %u", feature_count); */
+
+	feature_count = 1; /* One of passthrough|writeback|writethrough is always set. */
+
 	if (seg->flags & DM_CACHE_FEATURE_METADATA2)
-		EMIT_PARAMS(pos, " 2 metadata2 ");
-	else
-		EMIT_PARAMS(pos, " 1 ");
+		feature_count++;
+
+	EMIT_PARAMS(pos, " %u", feature_count);
+
+	if (seg->flags & DM_CACHE_FEATURE_METADATA2)
+		EMIT_PARAMS(pos, " metadata2");
 
 	if (seg->flags & DM_CACHE_FEATURE_PASSTHROUGH)
-		EMIT_PARAMS(pos, "passthrough");
+		EMIT_PARAMS(pos, " passthrough");
         else if (seg->flags & DM_CACHE_FEATURE_WRITEBACK)
-		EMIT_PARAMS(pos, "writeback");
+		EMIT_PARAMS(pos, " writeback");
 	else
-		EMIT_PARAMS(pos, "writethrough");
+		EMIT_PARAMS(pos, " writethrough");
 
 	/* Cache Policy */
 	name = seg->policy_name ? : "default";


