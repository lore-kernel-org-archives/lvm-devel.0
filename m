From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:42 -0500
Subject: master - cleanup: drop impossible test case
Message-ID: <201712041457.vB4EvgfA007136@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=10f37345ebbd4822083bd9451f59df6074995bb8
Commit:        10f37345ebbd4822083bd9451f59df6074995bb8
Parent:        1f6d79ab4827929420e032f4fb77e03393f336a8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 11:28:31 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: drop impossible test case

This test can never be true since info is embeded struct.
---
 libdm/libdm-deptree.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 9bc16c9..d0b4658 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1025,7 +1025,7 @@ out:
 static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 {
 	struct dm_task *dmt = NULL, *deps_dmt = NULL;
-	struct dm_info *info, deps_info;
+	struct dm_info *info = &dnode->info, deps_info;
 	struct dm_deps *deps = NULL;
 	const char *name, *uuid, *depname, *depuuid;
 	const char *default_uuid_prefix;
@@ -1033,11 +1033,6 @@ static int _node_clear_table(struct dm_tree_node *dnode, uint16_t udev_flags)
 	uint32_t i;
 	int r = 0;
 
-	if (!(info = &dnode->info)) {
-		log_error("_node_clear_table failed: missing info");
-		return 0;
-	}
-
 	if (!(name = dm_tree_node_get_name(dnode))) {
 		log_error("_node_clear_table failed: missing name");
 		return 0;


