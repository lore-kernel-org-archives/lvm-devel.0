From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:55 +0000 (UTC)
Subject: master - thin: lvchange allows to change perms of thin snap
Message-ID: <20121003131455.A7FEEF7A@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e9f83147d5da3120604c67354b4d6f027ac10ed0
Commit:        e9f83147d5da3120604c67354b4d6f027ac10ed0
Parent:        d442c3ef0cec424db797714704859fbc2154f000
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 19 14:55:34 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:13:32 2012 +0200

thin: lvchange allows to change perms of thin snap

Thin snapshots are individual thin volumes so they can have its own
control for rw permissions.
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dce8241..0927c49 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Support changes of permissions for thin snapshot volumes.
   Enhance insert_layer_for_lv() with recursive rename for _tdata LVs.
   Skip building dm tree for thin pool when called with origin_only flag.
   Add internal lv_rename_update() to rename LV without updating mda.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index d1cb4cf..b2c1fe4 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -722,7 +722,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return EINVALID_CMD_LINE;
 	}
 
-	if (lv_is_origin(lv) &&
+	if (lv_is_origin(lv) && !lv_is_thin_volume(lv) &&
 	    (arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
 	     arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
 	     arg_count(cmd, alloc_ARG))) {


