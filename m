From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 19 Aug 2015 17:18:26 +0000 (UTC)
Subject: master - lvmlockd: ignore cmd close if no locks were taken
Message-ID: <20150819171826.9342860528@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=62a87c84edc12788a088b3cc7dc5a35a18951f38
Commit:        62a87c84edc12788a088b3cc7dc5a35a18951f38
Parent:        ce2e60ab45a5e275adb40380e3a9886a1c1e4ce7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 19 12:16:04 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 19 12:16:04 2015 -0500

lvmlockd: ignore cmd close if no locks were taken

When a command closes its connection, don't waste
time looking for locks to purge if it did not make
any lock requests.
---
 daemons/lvmlockd/lvmlockd-core.c     |   10 ++++++++++
 daemons/lvmlockd/lvmlockd-internal.h |    1 +
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index dddae23..666f340 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3529,6 +3529,13 @@ static void client_purge(struct client *cl)
 	struct lockspace *ls;
 	struct action *act;
 
+	/*
+	 * If the client made no lock requests, there can be
+	 * no locks to release for it.
+	 */
+	if (!cl->lock_ops)
+		return;
+
 	pthread_mutex_lock(&lockspaces_mutex);
 	list_for_each_entry(ls, &lockspaces, list) {
 		if (!(act = alloc_action()))
@@ -4345,6 +4352,9 @@ static void client_recv_action(struct client *cl)
 		goto out;
 	}
 
+	if (act->op == LD_OP_LOCK && act->mode != LD_LK_UN)
+		cl->lock_ops = 1;
+
 	switch (act->op) {
 	case LD_OP_START:
 		rv = add_lockspace(act);
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index a1f74a7..8e0582b 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -85,6 +85,7 @@ struct client {
 	unsigned int recv : 1;
 	unsigned int dead : 1;
 	unsigned int poll_ignore : 1;
+	unsigned int lock_ops : 1;
 	char name[MAX_NAME+1];
 };
 


