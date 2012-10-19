From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Oct 2012 13:37:45 +0000 (UTC)
Subject: master - lvchange: support --yes option for --persistent
Message-ID: <20121019133745.2C4ABA1046@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f5a5d1f53d4dac462f447c0db692229f4a501b3
Commit:        5f5a5d1f53d4dac462f447c0db692229f4a501b3
Parent:        bc7d3b74f10bae4fd5931346f954601b89ddeee9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 19 14:16:15 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 19 15:33:46 2012 +0200

lvchange: support --yes option for --persistent

Support using command: lvchange --yes --persistent
to skip y|n prompt.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ad0756a..7d3995b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Support use of option --yes for lvchange --persistent.
   Fix memory leak on error path for pvcreate with invalid uuid.
   Use lv_is_active() instead of lv_info() call.
   Cleanup some log_error message and use log_warn instead.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 842b2da..8eabbbb 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -660,6 +660,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 			return 0;
 
 		if (active && !arg_count(cmd, force_ARG) &&
+		    !arg_count(cmd, yes_ARG) &&
 		    yes_no_prompt("Logical volume %s will be "
 				  "deactivated temporarily. "
 				  "Continue? [y/n]: ", lv->name) == 'n') {


