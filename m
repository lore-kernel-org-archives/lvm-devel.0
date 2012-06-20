From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Jun 2012 12:49:17 +0000 (UTC)
Subject: master - cmirrord: add missing checks for kernel_send
Message-ID: <20120620124917.B37A5168A@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=461eb1ac6adbf8e1938bd6e726dd4048c341cb49
Commit:        461eb1ac6adbf8e1938bd6e726dd4048c341cb49
Parent:        ac8a931889d796cf1e74b7c38ee6fb201ae2963b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 19 23:28:59 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 20 14:48:26 2012 +0200

cmirrord: add missing checks for kernel_send

Log errors if kernel_send fails.
---
 WHATS_NEW                  |    1 +
 daemons/cmirrord/cluster.c |    9 ++++++---
 daemons/cmirrord/local.c   |    4 +++-
 3 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 34da256..97bd680 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add tests for kernel_send() errors in cmirrod.
   Print clean_bits in pull_state, fix cut&paste typo in cmirrord.
   Add tests for errors from closedir(), close() in cmirrord.
   Fix missing sync of filesystem when creating thin volume snapshot.
diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 3a6bb03..9fbf800 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -910,8 +910,9 @@ static int resend_requests(struct clog_cpg *entry)
 				   rq->u_rq.seq);
 
 			rq->u_rq.data_size = 0;
-			kernel_send(&rq->u_rq);
-
+			if (kernel_send(&rq->u_rq))
+				LOG_ERROR("Failed to respond to kernel [%s]",
+					  RQ_TYPE(rq->u_rq.request_type));
 			break;
 
 		default:
@@ -1346,7 +1347,9 @@ static void cpg_leave_callback(struct clog_cpg *match,
 			dm_list_del(&rq->u.list);
 
 			if (rq->u_rq.request_type == DM_ULOG_POSTSUSPEND)
-				kernel_send(&rq->u_rq);
+				if (kernel_send(&rq->u_rq))
+					LOG_ERROR("Failed to respond to kernel [%s]",
+						  RQ_TYPE(rq->u_rq.request_type));
 			free(rq);
 		}
 
diff --git a/daemons/cmirrord/local.c b/daemons/cmirrord/local.c
index 50711a1..500f6dc 100644
--- a/daemons/cmirrord/local.c
+++ b/daemons/cmirrord/local.c
@@ -279,7 +279,9 @@ static int do_local_work(void *data __attribute__((unused)))
 		if (r) {
 			u_rq->data_size = 0;
 			u_rq->error = r;
-			kernel_send(u_rq);
+			if (kernel_send(u_rq))
+				LOG_ERROR("Failed to respond to kernel [%s]",
+					  RQ_TYPE(u_rq->request_type));
 		}
 
 		break;


