From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 13 Nov 2015 10:19:17 +0000 (UTC)
Subject: master - cleanup: better error message
Message-ID: <20151113101917.32C2D60FDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6dadebb1e45b0adc63380b5c61fb37f6d7ffee5a
Commit:        6dadebb1e45b0adc63380b5c61fb37f6d7ffee5a
Parent:        1f2a42c7b79ff99b29a999f0b636f340e5355456
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 13 11:05:00 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 13 11:17:06 2015 +0100

cleanup: better error message

Use display_lvname.
---
 tools/lvconvert.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9fc064b..335f6a4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2246,19 +2246,20 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 	/* Check if merge is possible */
 	if (lv_is_merging_origin(origin)) {
 		log_error("Snapshot %s is already merging into the origin.",
-			  find_snapshot(origin)->lv->name);
+			  display_lvname(find_snapshot(origin)->lv));
 		return 0;
 	}
 
 	if (lv_is_external_origin(origin)) {
-		log_error("\"%s\" is read-only external origin \"%s\".",
-			  lv->name, origin_from_cow(lv)->name);
+		origin = origin_from_cow(lv);
+		log_error("%s is read-only external origin %s.",
+			  display_lvname(lv), display_lvname(origin));
 		return 0;
 	}
 
 	if (lv_is_origin(origin)) {
 		log_error("Merging into the old snapshot origin %s is not supported.",
-			  origin->name);
+			  display_lvname(origin));
 		return 0;
 	}
 
@@ -2288,7 +2289,8 @@ static int _lvconvert_merge_thin_snapshot(struct cmd_context *cmd,
 			goto_out;
 
 		if (origin_is_active && !activate_lv(cmd, lv)) {
-			log_error("Failed to reactivate origin %s.", lv->name);
+			log_error("Failed to reactivate origin %s.",
+				  display_lvname(lv));
 			goto out;
 		}
 


