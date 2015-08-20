From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Thu, 20 Aug 2015 17:07:10 +0000 (UTC)
Subject: master - cmirrord: fix stack smashing
Message-ID: <20150820170710.69E2A60960@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ea1cb6dc972868d89ff17cb03f65ce3088009b3
Commit:        1ea1cb6dc972868d89ff17cb03f65ce3088009b3
Parent:        8821cc416e8a295f47c49cad060727a69769eaf5
Author:        Ferenc W??gner <wferi@niif.hu>
AuthorDate:    Wed Jul 8 14:41:25 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Aug 20 19:06:47 2015 +0200

cmirrord: fix stack smashing

With clusters larger than 3 nodes, the 32-byte debug buffer in
cpg_join_callback() is too small to contain all the node IDs, because
32-bit identifiers are generally rendered in 10 decimal digits.  No fixed
size is good in all cases, but this is conditionally logged debug info,
so we can simply truncate it.  Double the size, nevertheless.
---
 daemons/cmirrord/cluster.c |   18 ++++++++++++++----
 1 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 3fd5d23..4a4bdab 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -1294,7 +1294,9 @@ static void cpg_join_callback(struct clog_cpg *match,
 	uint32_t my_pid = (uint32_t)getpid();
 	uint32_t lowest = match->lowest_id;
 	struct clog_request *rq;
-	char dbuf[32] = { 0 };
+	char dbuf[64] = { 0 };
+	char *dbuf_p = dbuf;
+	size_t dbuf_rem = sizeof dbuf;
 
 	/* Assign my_cluster_id */
 	if ((my_cluster_id == 0xDEAD) && (joined->pid == my_pid))
@@ -1310,9 +1312,17 @@ static void cpg_join_callback(struct clog_cpg *match,
 	if (joined->nodeid == my_cluster_id)
 		goto out;
 
-	for (i = 0; i < member_list_entries - 1; i++)
-		sprintf(dbuf+strlen(dbuf), "%u-", member_list[i].nodeid);
-	sprintf(dbuf+strlen(dbuf), "(%u)", joined->nodeid);
+	for (i = 0; i < member_list_entries - 1; i++) {
+		int written = snprintf(dbuf_p, dbuf_rem, "%u-", member_list[i].nodeid);
+		if (written < 0) continue; /* impossible */
+		if ((unsigned)written >= dbuf_rem) {
+			dbuf_rem = 0;
+			break;
+		}
+		dbuf_rem -= written;
+		dbuf_p += written;
+	}
+	snprintf(dbuf_p, dbuf_rem, "(%u)", joined->nodeid);
 	LOG_COND(log_checkpoint, "[%s] Joining node, %u needs checkpoint [%s]",
 		 SHORT_UUID(match->name.value), joined->nodeid, dbuf);
 


