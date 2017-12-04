From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:58:05 -0500
Subject: master - cleanup: use log_warn
Message-ID: <201712041458.vB4Ew5Bu007190@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f73cadd2d7cf7eaef2bc9c9944b2c72fb67bf2d
Commit:        1f73cadd2d7cf7eaef2bc9c9944b2c72fb67bf2d
Parent:        76322d3b3e1cf7e118a8207975ae8342de454fa3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 15:16:08 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: use log_warn

Fucntion is not failing execution -> log_warn.
---
 libdm/libdm-deptree.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index c976cce..fb33605 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -2929,7 +2929,8 @@ int dm_tree_children_use_uuid(struct dm_tree_node *dnode,
 
 	while ((child = dm_tree_next_child(&handle, dnode, 0))) {
 		if (!(uuid = dm_tree_node_get_uuid(child))) {
-			log_error("Failed to get uuid for dtree node.");
+			log_warn("WARNING: Failed to get uuid for dtree node %s.",
+				 _node_name(child));
 			return 1;
 		}
 


