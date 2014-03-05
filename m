From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  5 Mar 2014 16:44:32 +0000 (UTC)
Subject: master - cmirrord: Clean-up stray warning message
Message-ID: <20140305164432.DFEBB60F2A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52aa3dbcabe85b38b51c68c27fb2397eb0fb1efd
Commit:        52aa3dbcabe85b38b51c68c27fb2397eb0fb1efd
Parent:        2c42f608904a853328341eac3cfd3c48033a3238
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Mar 5 10:44:20 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Mar 5 10:44:20 2014 -0600

cmirrord:  Clean-up stray warning message

cmirrord polls for messages on the kernel and cluster interfaces.
Sometimes it is possible for messages to be received on the cluster
interface and be waiting for processing while the node is in the
process of leaving the cluster group.  When this happens, the
messages received on the cluster interface are attempted to be
dispatched, but an error is returned because the connection is no
longer valid.  It is a harmless situation.  So, if we get the
specific error (CS_ERR_BAD_HANDLE) and we know that we have left
the group, then simply don't print the message.
---
 daemons/cmirrord/cluster.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/daemons/cmirrord/cluster.c b/daemons/cmirrord/cluster.c
index fea739a..67391f1 100644
--- a/daemons/cmirrord/cluster.c
+++ b/daemons/cmirrord/cluster.c
@@ -984,9 +984,16 @@ static int do_cluster_work(void *data __attribute__((unused)))
 
 	dm_list_iterate_items_safe(entry, tmp, &clog_cpg_list) {
 		r = cpg_dispatch(entry->handle, CS_DISPATCH_ALL);
-		if (r != CS_OK)
-			LOG_ERROR("cpg_dispatch failed: %s",
-				  str_ais_error(r));
+		if (r != CS_OK) {
+			if ((entry->cpg_state == INVALID) &&
+			    (entry->state == LEAVING) &&
+			    (r == CS_ERR_BAD_HANDLE))
+				/* It's ok if we've left the cluster */
+				r = CS_OK;
+			else
+				LOG_ERROR("cpg_dispatch failed: %s",
+					  str_ais_error(r));
+		}
 
 		if (entry->free_me) {
 			free(entry);


