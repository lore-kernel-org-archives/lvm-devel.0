From: Jacek Konieczny <jajcus@jajcus.net>
Date: Fri, 16 Nov 2012 19:42:51 +0100
Subject: [PATCH] clvmd/corosync: Cluster nodes down ok if quorate
In-Reply-To: <20121116153347.GB25670@jajo.eggsoft>
References: <20121116153347.GB25670@jajo.eggsoft>
Message-ID: <1353091371-3570-1-git-send-email-jajcus@jajcus.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

clvmd would refuse to handle cluster commands if any corosync cluster
node is down. If we have quorum and all active cluster nodes are running
clvmd, then cluster operations are safe (provided proper fencing is in
place, but DLM takes care of that).

Problem noticed here:
   http://www.redhat.com/archives/linux-lvm/2011-January/msg00039.html
and here:
   http://www.redhat.com/archives/linux-lvm/2012-November/msg00023.html

Signed-off-by: Jacek Konieczny <jajcus@jajcus.net>
---
 daemons/clvmd/clvmd-corosync.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd-corosync.c b/daemons/clvmd/clvmd-corosync.c
index d85ec1e..603ba4f 100644
--- a/daemons/clvmd/clvmd-corosync.c
+++ b/daemons/clvmd/clvmd-corosync.c
@@ -58,6 +58,7 @@ static void corosync_cpg_confchg_callback(cpg_handle_t handle,
 				 const struct cpg_address *left_list, size_t left_list_entries,
 				 const struct cpg_address *joined_list, size_t joined_list_entries);
 static void _cluster_closedown(void);
+static int _is_quorate(void);
 
 /* Hash list of nodes in the cluster */
 static struct dm_hash_table *node_hash;
@@ -455,7 +456,8 @@ static int _cluster_do_node_callback(struct local_client *master_client,
 		if (ninfo->state != NODE_DOWN)
 			callback(master_client, csid, ninfo->state == NODE_CLVMD);
 		if (ninfo->state != NODE_CLVMD)
-			somedown = -1;
+			if (ninfo->state != NODE_DOWN || !_is_quorate()) 
+				somedown = -1;
 	}
 	return somedown;
 }
@@ -528,7 +530,7 @@ static int _unlock_resource(const char *resource, int lockid)
 	return 0;
 }
 
-static int _is_quorate()
+static int _is_quorate(void)
 {
 	int quorate;
 	if (quorum_getquorate(quorum_handle, &quorate) == CS_OK)
-- 
1.7.7.4


