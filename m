From: Christine Caulfield <chrissie@fedoraproject.org>
Date: Mon, 23 Sep 2013 12:30:36 +0000 (UTC)
Subject: master - clvmd: Fix node up/down handing in corosync module
Message-ID: <20130923123036.D9AE760B58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=431eda63cc0ebff7c62dacb313cabcffbda6573a
Commit:        431eda63cc0ebff7c62dacb313cabcffbda6573a
Parent:        9658032cba4f6a2350bb35d5133a436bad84fec2
Author:        Christine Caulfield <ccaulfie@redhat.com>
AuthorDate:    Mon Sep 23 13:23:00 2013 +0100
Committer:     Christine Caulfield <ccaulfie@redhat.com>
CommitterDate: Mon Sep 23 13:23:00 2013 +0100

clvmd: Fix node up/down handing in corosync module

The corosync cluster interface for clvmd did not correctly
deal with node up/down events so that when a node was removed
from the cluster clvmd would prevent remote operations
from happening, as it thought the node was up but not
running clvmd.

This patch fixes that code by simplifying the case to node
being  up or down - which was the original intention
and is supported by pacemaker and CPG in the higher layers.

Signed-off-by: Christine Caulfield <ccaulfie@redhat.com>
---
 WHATS_NEW                      |    1 +
 daemons/clvmd/clvmd-corosync.c |   31 ++++---------------------------
 2 files changed, 5 insertions(+), 27 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 983e582..a3744dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -2,6 +2,7 @@ Version 2.02.102
 ======================================
   Fix missing build dependency for scripts subdir in Makefile.
   Extend lv_info() for more efficient lv_is_active_locally() check.
+  Fix node up/down handling in clvmd corosync module.
 
 Version 2.02.101 - 20th September 2013
 ======================================
diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index d85ec1e..9092c8a 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -89,7 +89,7 @@ quorum_callbacks_t quorum_callbacks = {
 
 struct node_info
 {
-	enum {NODE_UNKNOWN, NODE_DOWN, NODE_UP, NODE_CLVMD} state;
+	enum {NODE_DOWN, NODE_CLVMD} state;
 	int nodeid;
 };
 
@@ -255,26 +255,6 @@ static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 			ninfo->state = NODE_DOWN;
 	}
 
-	for (i=0; i<member_list_entries; i++) {
-		if (member_list[i].nodeid == 0) continue;
-		ninfo = dm_hash_lookup_binary(node_hash,
-				(char *)&member_list[i].nodeid,
-				COROSYNC_CSID_LEN);
-		if (!ninfo) {
-			ninfo = malloc(sizeof(struct node_info));
-			if (!ninfo) {
-				break;
-			}
-			else {
-				ninfo->nodeid = member_list[i].nodeid;
-				dm_hash_insert_binary(node_hash,
-						(char *)&ninfo->nodeid,
-						COROSYNC_CSID_LEN, ninfo);
-			}
-		}
-		ninfo->state = NODE_CLVMD;
-	}
-
 	num_nodes = member_list_entries;
 }
 
@@ -440,7 +420,6 @@ static int _cluster_do_node_callback(struct local_client *master_client,
 {
 	struct dm_hash_node *hn;
 	struct node_info *ninfo;
-	int somedown = 0;
 
 	dm_hash_iterate(hn, node_hash)
 	{
@@ -452,12 +431,10 @@ static int _cluster_do_node_callback(struct local_client *master_client,
 		DEBUGLOG("down_callback. node %d, state = %d\n", ninfo->nodeid,
 			 ninfo->state);
 
-		if (ninfo->state != NODE_DOWN)
-			callback(master_client, csid, ninfo->state == NODE_CLVMD);
-		if (ninfo->state != NODE_CLVMD)
-			somedown = -1;
+		if (ninfo->state == NODE_CLVMD)
+			callback(master_client, csid, 1);
 	}
-	return somedown;
+	return 0;
 }
 
 /* Real locking */


