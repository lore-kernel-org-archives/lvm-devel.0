From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:29 +0000 (UTC)
Subject: master - cleanup: use unrelated temporary variables
Message-ID: <20130615221629.C2EFA60D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=636c51ae3f0fda00b38851ead7f419bc834786a4
Commit:        636c51ae3f0fda00b38851ead7f419bc834786a4
Parent:        450ac7be4297012d57880e39261eda726cb75eba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 21:49:12 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:33 2013 +0200

cleanup: use unrelated temporary variables

use of tmp_rq2 is unrelated to tmp_rq - so use separate
variable.
---
 daemons/cmirrord/cluster.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 70c76c3..f19b2a9 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -1020,7 +1020,7 @@ static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gna
 	int i_am_server;
 	int response = 0;
 	struct clog_request *rq = msg;
-	struct clog_request *tmp_rq;
+	struct clog_request *tmp_rq, *tmp_rq2;
 	struct clog_cpg *match;
 
 	match = find_clog_cpg(handle);
@@ -1151,18 +1151,17 @@ static void cpg_message_callback(cpg_handle_t handle, const struct cpg_name *gna
 
 		if (match->state == INVALID) {
 			LOG_DBG("Log not valid yet, storing request");
-			tmp_rq = malloc(DM_ULOG_REQUEST_SIZE);
-			if (!tmp_rq) {
+			if (!(tmp_rq2 = malloc(DM_ULOG_REQUEST_SIZE))) {
 				LOG_ERROR("cpg_message_callback:  Unable to"
 					  " allocate transfer structs");
 				r = -ENOMEM; /* FIXME: Better error #? */
 				goto out;
 			}
 
-			memcpy(tmp_rq, rq, sizeof(*rq) + rq->u_rq.data_size);
-			tmp_rq->pit_server = match->lowest_id;
-			dm_list_init(&tmp_rq->u.list);
-			dm_list_add(&match->startup_list, &tmp_rq->u.list);
+			memcpy(tmp_rq2, rq, sizeof(*rq) + rq->u_rq.data_size);
+			tmp_rq2->pit_server = match->lowest_id;
+			dm_list_init(&tmp_rq2->u.list);
+			dm_list_add(&match->startup_list, &tmp_rq2->u.list);
 			goto out;
 		}
 


