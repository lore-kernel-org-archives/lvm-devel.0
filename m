From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:23 +0000 (UTC)
Subject: master - lvconvert more test for thin external origin
Message-ID: <20141006133323.A06C660DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2b18a5f8b4f6c5b116655f7e9e7c102462f693f
Commit:        b2b18a5f8b4f6c5b116655f7e9e7c102462f693f
Parent:        60d2a63368686d309c01f1e59d695d0ee8ec9153
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 13:15:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:21:36 2014 +0200

lvconvert more test for thin external origin

Some LV types were not properly disallowed to be used as external origin.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    9 +++++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5fc42d6..6b768ea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Fix detection of unsupported thin external lvconversions.
   Fix detection of unsupported cache and thin pool lvconversions.
   Fix detection of unsupported lvconversion of cache to snapshot.
   Improve code for creation of cache and cache pool volumes.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 36fafbe..070c5e4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2664,8 +2664,13 @@ static int _lvconvert_thin(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_pool(lv)) {
-		log_error("Can't use pool %s as external origin.",
+	if (lv_is_cache_type(lv) ||
+	    lv_is_cow(lv) ||
+	    lv_is_pool(lv) ||
+	    lv_is_thin_pool_data(lv) ||
+	    lv_is_thin_pool_metadata(lv)) {
+		log_error("Can't use %s %s as external origin.",
+			  first_seg(lv)->segtype->name,
 			  display_lvname(lv));
 		return 0;
 	}


