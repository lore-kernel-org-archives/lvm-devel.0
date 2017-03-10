From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:45 -0500
Subject: master - cleanup: use FMTu
Message-ID: <201703101837.v2AIbjhB029201@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a11b875074936fa7ae357133f1e2e3f18ebdc3eb
Commit:        a11b875074936fa7ae357133f1e2e3f18ebdc3eb
Parent:        d11b8eef893b9bd05b2e923f8637e527df16ac01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 9 23:41:54 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

cleanup: use FMTu

Replace some PRIu with FMTu for formating strings.
---
 libdm/libdm-targets.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index f44abfd..1709c2b 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -119,7 +119,7 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 		goto_bad;
 
 	msg_fields = "<raid_type> <#devices> <health_chars> and <sync_ratio> ";
-	if (sscanf(params, "%s %u %s %" PRIu64 "/%" PRIu64,
+	if (sscanf(params, "%s %u %s " FMTu64 "/" FMTu64,
 		   s->raid_type,
 		   &s->dev_count,
 		   s->dev_health,
@@ -146,7 +146,7 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 	if (!(s->sync_action = dm_pool_zalloc(mem, pp - p)))
 		goto_bad;
 
-	if (sscanf(p, "%s %" PRIu64, s->sync_action, &s->mismatch_count) != 2)
+	if (sscanf(p, "%s " FMTu64, s->sync_action, &s->mismatch_count) != 2)
 		goto_bad;
 
 	if (num_fields < 7)
@@ -162,7 +162,7 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 	msg_fields = "<data_offset>";
 	if (!(p = _skip_fields(params, 6))) /* skip pre-1.9.0 params */
 		goto bad;
-	if (sscanf(p, "%" PRIu64, &s->data_offset) != 1)
+	if (sscanf(p, FMTu64, &s->data_offset) != 1)
 		goto bad;
 
 out:
@@ -244,14 +244,14 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 
 	/* Read in args that have definitive placement */
 	if (sscanf(params,
-		   " %" PRIu32
-		   " %" PRIu64 "/%" PRIu64
-		   " %" PRIu32
-		   " %" PRIu64 "/%" PRIu64
-		   " %" PRIu64 " %" PRIu64
-		   " %" PRIu64 " %" PRIu64
-		   " %" PRIu64 " %" PRIu64
-		   " %" PRIu64
+		   " " FMTu32
+		   " " FMTu64 "/" FMTu64
+		   " " FMTu32
+		   " " FMTu64 "/" FMTu64
+		   " " FMTu64 " " FMTu64
+		   " " FMTu64 " " FMTu64
+		   " " FMTu64 " " FMTu64
+		   " " FMTu64
 		   " %d",
 		   &s->metadata_block_size,
 		   &s->metadata_used_blocks, &s->metadata_total_blocks,


