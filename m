From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:34 +0000 (UTC)
Subject: master - lvchange: fix return code
Message-ID: <20160426213134.580E160509@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8bdc7af3749cbdc9110057daa837d2fe19dcf72
Commit:        d8bdc7af3749cbdc9110057daa837d2fe19dcf72
Parent:        84a5b19539483e5f06b4a1405bb76e46ce9226b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 25 13:40:26 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:28:01 2016 +0200

lvchange: fix return code

We already opened VG for this - so not an invalid cmdline.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b6d9fd2..d557459 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Use failed command return code when lvchanging read-only volume.
   Show creation transaction_id and zeroing state of pool with thin volume.
   Stop checking for dm_cache_mq policy with cache target 1.9 (alias to smq).
   Check first /sys/module/dm_* dir existance before using modprobe.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 631d7f8..0f46e2c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -915,7 +915,7 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 	     arg_count(cmd, metadataprofile_ARG))) {
 		log_error("Only -a permitted with read-only volume "
 			  "group \"%s\"", lv->vg->name);
-		return EINVALID_CMD_LINE;
+		return ECMD_FAILED;
 	}
 
 	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&


