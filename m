From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 Jul 2016 19:34:42 +0000 (UTC)
Subject: master - lvconvert: don't show aliases in error output
Message-ID: <20160708193442.C371C6105E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=39921284a03fd2d2c3f3ac22c3e69cba913494bf
Commit:        39921284a03fd2d2c3f3ac22c3e69cba913494bf
Parent:        5cd39f1dc4013d5d9b150abe544187413daeaac9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 8 13:29:19 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 8 14:34:36 2016 -0500

lvconvert: don't show aliases in error output

We want to consistently use the standard command form.
The aliases are now mentioned in the man page for reference.
---
 tools/lvconvert.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ce858ae..0009270 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -4076,9 +4076,9 @@ static int _convert_thin_pool(struct cmd_context *cmd, struct logical_volume *lv
 
 	log_error("Operation not permitted on thin pool LV %s", display_lvname(lv));
 	log_error("Operations permitted on a thin pool LV are:\n"
-		  "  --splitcache           (operates on cache sub LV)\n"
-		  "  --uncache              (operates on cache sub LV)\n"
-		  "  --type cache | --cache (operates on data sub LV)\n"
+		  "  --splitcache  (operates on cache sub LV)\n"
+		  "  --uncache     (operates on cache sub LV)\n"
+		  "  --type cache  (operates on data sub LV)\n"
 		  "  --repair\n");
 	return 0;
 }
@@ -4137,7 +4137,7 @@ static int _convert_cache_pool(struct cmd_context *cmd, struct logical_volume *l
 
 	log_error("Operation not permitted on cache pool LV %s", display_lvname(lv));
 	log_error("Operations permitted on a cache pool LV are:\n"
-		  "  --splitcache        (operates on cache LV)\n");
+		  "  --splitcache    (operates on cache LV)\n");
 	return 0;
 }
 
@@ -4255,9 +4255,9 @@ static int _convert_raid(struct cmd_context *cmd, struct logical_volume *lv,
 		  "  --merge\n"
 		  "  --repair\n"
 		  "  --replace\n"
-		  "  --type snapshot | --snapshot\n"
-		  "  --type thin | --thin\n"
-		  "  --type cache | --cache\n"
+		  "  --type snapshot\n"
+		  "  --type thin\n"
+		  "  --type cache\n"
 		  "  --type thin-pool\n"
 		  "  --type cache-pool\n"
 		  "  --type raid*\n"
@@ -4316,13 +4316,13 @@ static int _convert_striped(struct cmd_context *cmd, struct logical_volume *lv,
 	log_error("Operation not permitted on striped or linear LV %s", display_lvname(lv));
 	log_error("Operations permitted on a striped or linear LV are:\n"
 		  "  --merge\n"
-		  "  --type snapshot | --snapshot\n"
-		  "  --type thin | --thin\n"
-		  "  --type cache | --cache\n"
+		  "  --type snapshot\n"
+		  "  --type thin\n"
+		  "  --type cache\n"
 		  "  --type thin-pool\n"
 		  "  --type cache-pool\n"
-		  "  --type mirror | --mirrors\n"
-		  "  --type raid* | --mirrors\n");
+		  "  --type mirror\n"
+		  "  --type raid*\n");
 	return 0;
 }
 


