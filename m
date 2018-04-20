From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:45 -0400
Subject: master - cleanup: enhance debug message
Message-ID: <201804201102.w3KB2jjb031388@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9731d48691e85641e45a127ddf77fb603aa4900c
Commit:        9731d48691e85641e45a127ddf77fb603aa4900c
Parent:        d437bd86ffcb8dc589ddf941ec7c12d493c89b33
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 19 12:32:01 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:17:01 2018 +0200

cleanup: enhance debug message

---
 lib/metadata/lv_manip.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 97a4e39..160943f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3439,11 +3439,12 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 					    (existing_extents + new_extents) / ah->area_multiple);
 	}
 
-	log_debug("Adjusted allocation request to %" PRIu32 " logical extents. Existing size %" PRIu32 ". New size %" PRIu32 ".",
-		  total_extents, existing_extents, total_extents + existing_extents);
+	if (total_extents || existing_extents)
+		log_debug("Adjusted allocation request to " FMTu32 " logical extents. Existing size " FMTu32 ". New size " FMTu32 ".",
+			  total_extents, existing_extents, total_extents + existing_extents);
 	if (ah->log_len)
-		log_debug("Mirror log of %" PRIu32 " extents of size %" PRIu32 " sectors needed for region size %" PRIu32  ".",
-			  ah->log_len, extent_size, ah->region_size);
+		log_debug("Mirror log of " FMTu32 " extents of size " FMTu32 " sectors needed for region size %s.",
+			  ah->log_len, extent_size, display_size(cmd, (uint64_t)ah->region_size));
 
 	if (mirrors || stripes)
 		total_extents += existing_extents;


