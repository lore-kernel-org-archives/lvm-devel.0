From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 26 Jun 2013 14:55:37 +0000 (UTC)
Subject: dev-peter-config-profiles - dmeventd: fix cleanup commit
Message-ID: <20130626145537.C820C60D8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9233e6d0bb5b3b21cc67fd0baae3fb4cb099bdcb
Commit:        9233e6d0bb5b3b21cc67fd0baae3fb4cb099bdcb
Parent:        939aeb7058e327686ff0e4f9e22b18893e0a7a3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 23:05:06 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 23:05:06 2013 +0200

dmeventd: fix cleanup commit

Fixing wrong rebase of cleanup commit.
Put back call to outth.
---
 daemons/dmeventd/dmeventd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index e9924f6..b912ead 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -988,7 +988,7 @@ static int _register_for_event(struct message_data *message_data)
 	   almost as good as dead already... */
 	if ((thread_new->events & DM_EVENT_TIMEOUT) &&
 	    (ret = -_register_for_timeout(thread_new)))
-		goto out;
+		goto outth;
 
 	if (!(thread = _lookup_thread_status(message_data))) {
 		_unlock_mutex();


