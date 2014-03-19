From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 19 Mar 2014 19:44:17 +0000 (UTC)
Subject: master - cmirrord: Clean-up stray warning message (attempt #2)
Message-ID: <20140319194417.E173C6092C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bdd7baeab39f7ef61817b2c48008852aefdbcdb0
Commit:        bdd7baeab39f7ef61817b2c48008852aefdbcdb0
Parent:        f12ee43f2eaba5d38b1925a5a34b1746c1d66985
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Mar 19 14:43:00 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Mar 19 14:43:00 2014 -0500

cmirrord: Clean-up stray warning message (attempt #2)

There are two types of CPG communications in a corosync cluster:
messages and state transitions.  Cmirrord processes the state
transitions first.

When a cluster mirror issues a POSTSUSPEND, it signals the end of
cluster communication with the rest of the nodes in the cluster.
The POSTSUSPEND marks the last communication of the 'message'
type that will go around the cluster.  The node then calls
cpg_leave which causes a final 'state transition' communication to
all of the nodes.  Once the out-going node receives its own state
transition notice from the cluster, it finalizes the leave.  At this
point, the state of the log is 'INVALID'; but it is possible that
there remains some cluster trafic that was queued up behind the
state transition that still wants to be processed.  It is harmless
to attempt to dispatch any remaining messages - they won't be
delivered because the node is no longer in the cluster.  However,
there was a warning message that was being printed in this case
that is now removed by this patch.  The failure of the dispatch
created a false positive condition that triggered the message.
---
 daemons/cmirrord/cluster.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index 67391f1..3fd5d23 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -985,9 +985,9 @@ static int do_cluster_work(void *data __attribute__((unused)))
 	dm_list_iterate_items_safe(entry, tmp, &clog_cpg_list) {
 		r = cpg_dispatch(entry->handle, CS_DISPATCH_ALL);
 		if (r != CS_OK) {
-			if ((entry->cpg_state == INVALID) &&
-			    (entry->state == LEAVING) &&
-			    (r == CS_ERR_BAD_HANDLE))
+			if ((r == CS_ERR_BAD_HANDLE) &&
+			    ((entry->state == INVALID) ||
+			     (entry->state == LEAVING)))
 				/* It's ok if we've left the cluster */
 				r = CS_OK;
 			else


