From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Jun 2012 11:51:28 +0000 (UTC)
Subject: master - thin: fix lvconvert error path NULL dereference
Message-ID: <20120622115128.C7C851688@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6bd3864b41fa1cb8e2763185ff860d320c45930f
Commit:        6bd3864b41fa1cb8e2763185ff860d320c45930f
Parent:        e9f9c6be26bb9c40269ebad6250e1a5b4759e74f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 14:55:00 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 13:50:21 2012 +0200

thin: fix lvconvert error path NULL dereference

For printing the name, use given command line parameter.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f1216ff..90157c8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Fix lvconvert error path NULL pointer dereference.
   Check for create_instance() fail in pvscan_lvmetad_single().
   Use 64bit math for reserved memory and stack.
   Add tests for kernel_send() errors in cmirrod.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 39e196b..074821d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1841,8 +1841,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 				      lp->pool_data_lv_name);
 
 	if (!pool_lv) {
-		log_error("Can't find pool logical volume %s.", pool_lv->name);
-		goto_out;
+		log_error("Can't find pool logical volume %s.", lp->lv_name);
+		return 0;
 	}
 
 	if ((pool_lv != metadata_lv)) {


