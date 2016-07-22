From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 22 Jul 2016 15:01:49 +0000 (UTC)
Subject: master - lvconvert: change error message
Message-ID: <20160722150149.C57956078D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c3b92b550ee1ba0c165acb7da87cc5cd8cf3eb9
Commit:        2c3b92b550ee1ba0c165acb7da87cc5cd8cf3eb9
Parent:        7fc1617819236d4d6f8b0ffbcd4980fcc5bc5de6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 22 10:00:24 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jul 22 10:00:24 2016 -0500

lvconvert: change error message

for implicit pool conversion since it's also used
when the lv is already a pool
---
 tools/lvconvert.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9dd7254..5d29cc4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3913,7 +3913,7 @@ static int _convert_striped_thin(struct cmd_context *cmd, struct logical_volume
 {
 	/* lvconvert --thin includes an implicit conversion of the thinpool arg to type thin-pool. */
 	if (!_lvconvert_pool(cmd, lv, lp)) {
-		log_error("Implicit conversion of --thinpool arg to type thin-pool failed.");
+		log_error("Conversion of --thinpool arg to type thin-pool failed.");
 		return 0;
 	}
 
@@ -3939,7 +3939,7 @@ static int _convert_striped_cache(struct cmd_context *cmd, struct logical_volume
 {
 	/* lvconvert --cache includes an implicit conversion of the cachepool arg to type cache-pool. */
 	if (!_lvconvert_pool(cmd, lv, lp)) {
-		log_error("Implicit conversion of --cachepool arg to type cache-pool failed.");
+		log_error("Conversion of --cachepool arg to type cache-pool failed.");
 		return 0;
 	}
 


