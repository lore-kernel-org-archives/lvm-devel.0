From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 10 Sep 2015 14:50:28 +0000 (UTC)
Subject: master - lvmlockd: flag for internal actions
Message-ID: <20150910145028.D9741610F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f11d690967c9d352cb19076a99de81661ee43343
Commit:        f11d690967c9d352cb19076a99de81661ee43343
Parent:        15ae237d2c029116395e5436826f896a5a00d6c4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 9 13:33:10 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Sep 10 09:47:26 2015 -0500

lvmlockd: flag for internal actions

When an action is created by lvmlockd for itself,
there is no client to send the result to.  Add
the NO_CLIENT flag to the action to skip sending
the result to a client.
---
 daemons/lvmlockd/lvmlockd-core.c     |    7 +++++++
 daemons/lvmlockd/lvmlockd-internal.h |    2 +-
 2 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 9b79131..8b78af3 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -959,6 +959,13 @@ static int lm_find_free_lock(struct lockspace *ls, uint64_t *free_offset)
 
 static void add_client_result(struct action *act)
 {
+	if (act->flags & LD_AF_NO_CLIENT) {
+		log_debug("internal action done op %s mode %s result %d vg %s",
+			  op_str(act->op), mode_str(act->mode), act->result, act->vg_name);
+		free_action(act);
+		return;
+	}
+
 	pthread_mutex_lock(&client_mutex);
 	if (act->flags & LD_AF_ADOPT)
 		list_add_tail(&act->list, &adopt_results);
diff --git a/daemons/lvmlockd/lvmlockd-internal.h b/daemons/lvmlockd/lvmlockd-internal.h
index 68dcd9d..a58976f 100644
--- a/daemons/lvmlockd/lvmlockd-internal.h
+++ b/daemons/lvmlockd/lvmlockd-internal.h
@@ -89,7 +89,7 @@ struct client {
 };
 
 #define LD_AF_PERSISTENT           0x00000001
-#define LD_AF_UNUSED               0x00000002 /* use me */
+#define LD_AF_NO_CLIENT            0x00000002
 #define LD_AF_UNLOCK_CANCEL        0x00000004
 #define LD_AF_NEXT_VERSION         0x00000008
 #define LD_AF_WAIT                 0x00000010


