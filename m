From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:42 +0000 (UTC)
Subject: master - lvconvert: check ret code of mirror_remove_missing
Message-ID: <20140520195342.C7DE160190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c70c100cce6cdd1f3723203c2cec4427eba7a464
Commit:        c70c100cce6cdd1f3723203c2cec4427eba7a464
Parent:        bbf4b2c1c9da174c607daee9f920f32517d48e6a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 12:57:42 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:49:42 2014 +0200

lvconvert: check ret code of mirror_remove_missing

When mirror_remove_missing() fails, stop repairing mirror.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5e13c04..86ed3bc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Check for failing mirror_remove_missing() function.
   Prompt before converting volumes to thin pool and thin pool metadata.
   Add dumpconfig --type profilable-{metadata,command} to select profile type.
   Exit immediately with error if command profile is found invalid.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 79a78a4..3c20257 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1639,7 +1639,8 @@ static int _lvconvert_mirrors_repair(struct cmd_context *cmd,
 	failed_mimages = _failed_mirrors_count(lv);
 	failed_logs = _failed_logs_count(lv);
 
-	mirror_remove_missing(cmd, lv, 0);
+	if (!mirror_remove_missing(cmd, lv, 0))
+		return_0;
 
 	if (failed_mimages)
 		log_error("Mirror status: %d of %d images failed.",


