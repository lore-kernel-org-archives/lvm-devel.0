From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:33 +0000 (UTC)
Subject: master - thin: fix error path mem leak
Message-ID: <20151109092833.1887A60CD3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80c3fb786cc236f200026624ded4c668b37ef22d
Commit:        80c3fb786cc236f200026624ded4c668b37ef22d
Parent:        3cadc1c87e4f1f6cede3895a7f7f28f37eaf9648
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 17:04:03 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

thin: fix error path mem leak

Coverity: when parsing of thin-pool status would have failed,
it could have leaked memory pool and dmt struct.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d0a1476..6368b32 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Fix memory leak on error path of failing thin-pool percentage check.
   Add missing test for failing node allocation in lvmetad.
   Correct configure messages when enabling/disabling lvmlockd.
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 964eef5..6ec9d22 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -567,7 +567,7 @@ static int _ignore_unusable_thins(struct device *dev)
 
 	dm_get_next_target(dmt, next, &start, &length, &target_type, &params);
 	if (!dm_get_status_thin_pool(mem, params, &status))
-		return_0;
+		goto_out;
 
 	if (status->read_only || status->out_of_data_space) {
 		log_warn("WARNING: %s: Thin's thin-pool needs inspection.",


