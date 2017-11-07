From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 7 Nov 2017 15:35:54 -0500
Subject: master - snapshot: prevent repeated merging
Message-ID: <201711072035.vA7KZsXn007634@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=014122256b50b30324fc848fa79492124bebeb39
Commit:        014122256b50b30324fc848fa79492124bebeb39
Parent:        1b6dfd4802c136509ffb9d9927b6611265d59e6b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 4 22:15:59 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 7 21:22:50 2017 +0100

snapshot: prevent repeated merging

Check and prevent starting another snapshot merge before
exiting merging is finished.

TODO: we can possibly implement smarter logic to drop existing
merging and start a new one.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6b426e4..fdf2c3a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Prevent start of new merge of snapshot if origin is already being merged.
 
 Version 2.02.176 - 3rd November 2017
 ====================================
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 3a025c7..438f34b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2008,6 +2008,15 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 	struct lvinfo info;
 	dm_percent_t snap_percent;
 
+	/* Check if merge is possible */
+	if (lv_is_merging_origin(origin)) {
+		log_error("Cannot merge snapshot %s into the origin %s "
+			  "with merging snapshot %s.",
+			  display_lvname(lv), display_lvname(origin),
+			  display_lvname(find_snapshot(origin)->lv));
+		return 0;
+	}
+
 	if (lv_is_external_origin(origin_from_cow(lv))) {
 		log_error("Cannot merge snapshot \"%s\" into "
 			  "the read-only external origin \"%s\".",


