From: David Teigland <teigland@sourceware.org>
Date: Wed, 23 Aug 2017 12:32:27 -0400
Subject: master - lvmlockd: fix mutex unlock
Message-ID: <201708231632.v7NGWR6F013055@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e71c3ff18719f240e92bb641b9b9a01b2619cc93
Commit:        e71c3ff18719f240e92bb641b9b9a01b2619cc93
Parent:        46ddd5520cd4d5415ee936b6cbdb6e1936bc7d26
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 23 11:30:55 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Aug 23 11:30:55 2017 -0500

lvmlockd: fix mutex unlock

Remove an unwanted pthread_mutex_unlock which would
lead to a double unlock.
---
 daemons/lvmlockd/lvmlockd-core.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index da17b71..36d84e2 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3842,8 +3842,9 @@ static int add_lock_action(struct action *act)
 	pthread_mutex_lock(&lockspaces_mutex);
 	if (ls_name[0])
 		ls = find_lockspace_name(ls_name);
-	pthread_mutex_unlock(&lockspaces_mutex);
 	if (!ls) {
+		pthread_mutex_unlock(&lockspaces_mutex);
+
 		if (act->op == LD_OP_UPDATE && act->rt == LD_RT_VG) {
 			log_debug("lockspace \"%s\" not found ignored for vg update", ls_name);
 			return -ENOLS;


