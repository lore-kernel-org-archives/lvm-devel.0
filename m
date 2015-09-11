From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 11 Sep 2015 18:24:55 +0000 (UTC)
Subject: master - lvmlockd: remove shortcut for lockspace thread cleanup
Message-ID: <20150911182455.EEA306017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=854a559a494e81228905f6739de9150853ce2ea7
Commit:        854a559a494e81228905f6739de9150853ce2ea7
Parent:        18dfbbb150e04026e4c11822e5f80f79da691d08
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Sep 10 10:33:45 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 11 13:20:20 2015 -0500

lvmlockd: remove shortcut for lockspace thread cleanup

This shortcut was added for an odd case that I do not
believe is relevant any more.  Having an alternate
path for lockspace thread cleanup is a complication
that could lead to problems.
---
 daemons/lvmlockd/lvmlockd-core.c |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 8f89181..ffeef5c 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3760,17 +3760,6 @@ static int add_lock_action(struct action *act)
 	}
 
 	pthread_mutex_lock(&ls->mutex);
-	if (ls->thread_stop && ls->thread_done) {
-		log_debug("lockspace is done finish cleanup %s", ls_name);
-		pthread_join(ls->thread, NULL);
-		list_del(&ls->list);
-		pthread_mutex_unlock(&ls->mutex);
-		free_ls_resources(ls);
-		free(ls);
-		pthread_mutex_unlock(&lockspaces_mutex);
-		goto retry;
-	}
-
 	if (ls->thread_stop) {
 		pthread_mutex_unlock(&ls->mutex);
 		pthread_mutex_unlock(&lockspaces_mutex);


