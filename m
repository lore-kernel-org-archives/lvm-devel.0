From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:25 +0000 (UTC)
Subject: master - cache: use target_present_version
Message-ID: <20160505220125.1186560C56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd79027cae16be4f7fcae98568c2063ac37c9e3a
Commit:        fd79027cae16be4f7fcae98568c2063ac37c9e3a
Parent:        4d116d7a28974648183623c46014b9dcff48748d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 27 11:13:36 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:34:35 2016 +0200

cache: use target_present_version

Using new function.
Also add trace for error path.
---
 lib/cache_segtype/cache.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 199bda6..b3edff8 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -227,15 +227,13 @@ static int _target_present(struct cmd_context *cmd,
 	const char *str;
 
 	if (!activation())
-		return 0;
+		return_0;
 
 	if (!_cache_checked) {
 		_cache_checked = 1;
 
-		if (!(_cache_present = target_present(cmd, TARGET_NAME_CACHE, 1)))
-			return 0;
-
-		if (!target_version(TARGET_NAME_CACHE, &maj, &min, &patchlevel))
+		if (!(_cache_present = target_present_version(cmd, TARGET_NAME_CACHE, 1,
+							      &maj, &min, &patchlevel)))
 			return_0;
 
 		if ((maj < 1) ||


