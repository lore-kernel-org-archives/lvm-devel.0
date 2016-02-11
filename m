From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:41 +0000 (UTC)
Subject: master - dm: fix thin-pool targer params order
Message-ID: <20160211173941.E5E6E60DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f91622741f95713539b863338743eb217e0731c2
Commit:        f91622741f95713539b863338743eb217e0731c2
Parent:        e32e793c43280c898ff6b20d22488af568825287
Author:        M.H. Tsai <mingnus@gmail.com>
AuthorDate:    Wed Jan 27 19:11:03 2016 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:32:24 2016 +0100

dm: fix thin-pool targer params order

Wrong thin-pool feature flag ordering in dm table: It will lead to
unnecessary table reload.

Fix it by placeing feature flags in order they are returned from the
kernel so current 'table line diff' code will not see a difference.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2fb1274..f54868f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.116 - 
 ====================================
+  Fix thin-pool table parameter feature order to match kernel output.
 
 Version 1.02.115 - 25th January 2016
 ====================================
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 1b9d6d3..f8b6d89 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2477,11 +2477,11 @@ static int _thin_pool_emit_segment_line(struct dm_task *dmt,
 
 	EMIT_PARAMS(pos, "%s %s %d %" PRIu64 " %d%s%s%s%s%s", metadata, pool,
 		    seg->data_block_size, seg->low_water_mark, features,
-		    seg->error_if_no_space ? " error_if_no_space" : "",
-		    seg->read_only ? " read_only" : "",
 		    seg->skip_block_zeroing ? " skip_block_zeroing" : "",
 		    seg->ignore_discard ? " ignore_discard" : "",
-		    seg->no_discard_passdown ? " no_discard_passdown" : ""
+		    seg->no_discard_passdown ? " no_discard_passdown" : "",
+		    seg->error_if_no_space ? " error_if_no_space" : "",
+		    seg->read_only ? " read_only" : ""
 		   );
 
 	return 1;


