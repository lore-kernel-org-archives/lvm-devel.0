From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:18 +0000 (UTC)
Subject: master - lvconvert: external detects more conflicts
Message-ID: <20141024144018.1A91060317@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=128131dbc579daf510c4aa7b5cd8f0ca076539a3
Commit:        128131dbc579daf510c4aa7b5cd8f0ca076539a3
Parent:        8a2f553b7d5f516ac750aadd4ca75cc4a20aef15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 19 22:04:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

lvconvert: external detects more conflicts

Check for more prohibited types for external origin conversion.
TODO: Move this function to separate validation code.
(Continuing in release fixes.)
---
 tools/lvconvert.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9155998..eb8a83b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2664,12 +2664,16 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_cache_type(lv) ||
+	if (lv_is_locked(lv) ||
+	    !lv_is_visible(lv) ||
+	    lv_is_cache_type(lv) ||
 	    lv_is_cow(lv) ||
 	    lv_is_pool(lv) ||
-	    lv_is_thin_pool_data(lv) ||
-	    lv_is_thin_pool_metadata(lv)) {
-		log_error("Can't use %s %s as external origin.",
+	    lv_is_pool_data(lv) ||
+	    lv_is_pool_metadata(lv)) {
+		log_error("Can't use%s%s %s %s as external origin.",
+			  lv_is_locked(lv) ? " locked" : "",
+			  lv_is_visible(lv) ? "" : " hidden",
 			  lvseg_name(first_seg(lv)),
 			  display_lvname(lv));
 		return 0;


