From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:16:55 +0000 (UTC)
Subject: master - libdm: call preload callback only when success
Message-ID: <20140224201655.B1FD060E53@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1911c61639164296d953eef6f1476a040648d5ec
Commit:        1911c61639164296d953eef6f1476a040648d5ec
Parent:        c132fc3ff6d031c136528ef00ecfbed417dae941
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 23 23:10:36 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:01:13 2014 +0100

libdm: call preload callback only when success

Do not call node's preload callback, if there is
any failure during preload.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-deptree.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a0b8066..072d21e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Do not call callback when preload fails.
   Wrap is_selinux_enabled() to be called just once.
   Use correctly signed 64b constant when working with raid volumes.
   Exit dmeventd with pidfile cleanup instead of raising SIGKILL on DIE request.
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 8592cdb..7fcc7ed 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2724,12 +2724,12 @@ int dm_tree_preload_children(struct dm_tree_node *dnode,
 	}
 
 	if (update_devs_flag ||
-	    (!dnode->info.exists && dnode->callback)) {
+	    (r && !dnode->info.exists && dnode->callback)) {
 		if (!dm_udev_wait(dm_tree_get_cookie(dnode)))
 			stack;
 		dm_tree_set_cookie(dnode, 0);
 
-		if (!dnode->info.exists && dnode->callback &&
+		if (r && !dnode->info.exists && dnode->callback &&
 		    !dnode->callback(dnode, DM_NODE_CALLBACK_PRELOADED,
 				     dnode->callback_data))
 		{


