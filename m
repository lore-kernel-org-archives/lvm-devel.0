From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:13 +0000 (UTC)
Subject: dev-mornfall-activate - clvmd: avoid logging in signal handler
Message-ID: <20130604192413.7733F6119A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5070ffbca7b16e4139b3da72bdff0c9add517351
Commit:        5070ffbca7b16e4139b3da72bdff0c9add517351
Parent:        61d0ae7019aa14d78678a36f1eeb43b29a113e80
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 17 23:16:30 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 22:56:59 2013 +0200

clvmd: avoid logging in signal handler

debuglog in the main thread.
---
 daemons/clvmd/clvmd.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index c649bbe..a64bd54 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -874,6 +874,7 @@ static void main_loop(int local_sock, int cmd_timeout)
 			int saved_errno = errno;
 
 			reread_config = 0;
+			DEBUGLOG("got SIGHUP\n");
 			if (clops->reread_config)
 				clops->reread_config();
 			errno = saved_errno;
@@ -982,6 +983,8 @@ static void main_loop(int local_sock, int cmd_timeout)
 
       closedown:
 	clops->cluster_closedown();
+	if (quit)
+		DEBUGLOG("SIGTERM received\n");
 }
 
 static __attribute__ ((noreturn)) void wait_for_child(int c_pipe, int timeout)
@@ -2253,14 +2256,12 @@ static void sigusr2_handler(int sig)
 
 static void sigterm_handler(int sig)
 {
-	DEBUGLOG("SIGTERM received\n");
 	quit = 1;
 	return;
 }
 
 static void sighup_handler(int sig)
 {
-        DEBUGLOG("got SIGHUP\n");
 	reread_config = 1;
 }
 


