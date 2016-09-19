From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Sep 2016 12:01:36 +0000 (UTC)
Subject: master - thin: fix lvchange of discards and zero flag
Message-ID: <20160919120136.B1F966050A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e8449a5b921e60e6952ac5ff33e81a40abcd23a
Commit:        0e8449a5b921e60e6952ac5ff33e81a40abcd23a
Parent:        c2c2721d0082d79fab98875dd20f03d6abf72bea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 23 21:09:09 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 19 14:00:56 2016 +0200

thin: fix lvchange of discards and zero flag

Reload of thin-pool origin_only is designed to only post messages
to a thin-pool. It's not intended to be used for reload of thin-pool
table. Fix it by using standard call  'lv_update_and_reload()'.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ba14c6d..ebb9c8c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix lvchange --discard|--zero for active thin-pool.
   Enforce 4MiB or 25% metadata free space for thin pool operations.
   Fix lock-holder device for thin pool with inactive thin volumes.
   Use --alloc normal for mirror logs even if the mimages were stricter.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 4810392..250d720 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -136,7 +136,7 @@ static int _lvchange_pool_update(struct cmd_context *cmd,
 	if (!update)
 		return 0;
 
-	if (!lv_update_and_reload_origin(lv))
+	if (!lv_update_and_reload(lv))
 		return_0;
 
 	return 1;


