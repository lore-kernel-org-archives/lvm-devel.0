From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:36 +0000 (UTC)
Subject: master - lvchange: always check for sigint
Message-ID: <20160426213136.6D59960509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c215e1be5ce35177a0491c0d6495865efbe34b51
Commit:        c215e1be5ce35177a0491c0d6495865efbe34b51
Parent:        d8bdc7af3749cbdc9110057daa837d2fe19dcf72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 25 13:44:42 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:29:08 2016 +0200

lvchange: always check for sigint

Check sigint() state during process_each_lv.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d557459..3f036e1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Improve support for interrupting procesing of volumes during lvchange.
   Use failed command return code when lvchanging read-only volume.
   Show creation transaction_id and zeroing state of pool with thin volume.
   Stop checking for dm_cache_mq policy with cache target 1.9 (alias to smq).
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0f46e2c..6a6a619 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -907,6 +907,9 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	struct logical_volume *origin;
 	char snaps_msg[128];
 
+	if (sigint_caught())
+		return_ECMD_FAILED;
+
 	if (!(lv->vg->status & LVM_WRITE) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
@@ -1062,8 +1065,6 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 			return_ECMD_FAILED;
 		doit += _lvchange_persistent(cmd, lv);
 		docmds++;
-		if (sigint_caught())
-			return_ECMD_FAILED;
 	}
 
 	if (arg_count(cmd, discards_ARG) ||


