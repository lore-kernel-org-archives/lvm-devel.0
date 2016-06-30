From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 30 Jun 2016 15:11:23 +0000 (UTC)
Subject: master - lvconvert: add missing alias for a thin-pool conversion
Message-ID: <20160630151123.C27FA6136E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8e39530efdffc42d21e9bc968ab3966b719876a
Commit:        a8e39530efdffc42d21e9bc968ab3966b719876a
Parent:        802ed9d4597443e21086b392d9ee160f6d99dde9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 30 10:09:54 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 30 10:09:54 2016 -0500

lvconvert: add missing alias for a thin-pool conversion

The case of converting a cache volume to a thin pool missed
recognizing the --thinpool alias for --type thin-pool.
---
 tools/lvconvert.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4808090..8ceb1c7 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3718,9 +3718,13 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 	if (arg_is_set(cmd, splitmirrors_ARG))
 		return _convert_cache_volume_splitmirrors(cmd, lv, lp);
 
-	if (new_type && !strcmp(new_type, "thin-pool"))
+	/* The --thinpool alias is ambiguous and not preferred. */
+
+	if ((new_type && !strcmp(new_type, "thin-pool")) || arg_is_set(cmd, thinpool_ARG))
 		return _convert_cache_volume_thin_pool(cmd, lv, lp);
 
+	/* The --thinpool alias for --type thin-pool is not preferred, so not shown. */
+
 	log_error("Operation not permitted on cache LV %s", display_lvname(lv));
 	log_error("Operations permitted on a cache LV are:\n"
 		  "  --splitcache\n"


