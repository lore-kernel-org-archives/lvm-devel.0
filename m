From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 21:21:18 +0000 (UTC)
Subject: master - thin: lvextend will fail is autoextend is 0%
Message-ID: <20121014212118.49BA122FD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16060b101bdb541376fdfd7c0e6cac8cf73c0271
Commit:        16060b101bdb541376fdfd7c0e6cac8cf73c0271
Parent:        a6f53b5c0d2a23f73af7d4a2778dfc0da4da0944
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 14 19:43:25 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 14 23:17:30 2012 +0200

thin: lvextend will fail is autoextend is 0%

Since extending by 0% will not increase the size of pool,
return failure.
---
 WHATS_NEW        |    1 +
 tools/lvresize.c |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a170bfe..d60cad5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Using autoextend percent 0 for thin pool fails 'lvextend --use-policies'.
   Introduce blkdeactivate script.
   Implement devices/global_filter (affects lvmetad).
   Make vgscan --cache an alias to pvscan --cache.
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 18e5917..4c9580d 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -293,6 +293,8 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 		policy_amount =
 			find_config_tree_int(cmd, "activation/thin_pool_autoextend_percent",
 					     DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT);
+		if (!policy_amount && policy_threshold < PERCENT_100)
+                        return 0;
 	} else {
 		policy_threshold =
 			find_config_tree_int(cmd, "activation/snapshot_autoextend_threshold",


