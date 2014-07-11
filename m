From: Dongmao Zhang <dmzhang@suse.com>
Date: Fri, 11 Jul 2014 13:10:01 +0800
Subject: [PATCH] replace select with pselect in clvmd
Message-ID: <1405055401-18811-1-git-send-email-dmzhang@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch could enhance the SIGTERM respose of clvmd
the SIGINT and SIGTERM may lost when the signal is generated before select.
The SIGINT and SIGTERM are only unblocked during the pselect call after
this patch

reference:http://lwn.net/Articles/176911/

Signed-off-by: Dongmao Zhang <dmzhang@suse.com>
---
 daemons/clvmd/clvmd.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 9b865f6..e758658 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -839,9 +839,8 @@ static void main_loop(int cmd_timeout)
 	DEBUGLOG("Using timeout of %d seconds\n", cmd_timeout);
 
 	sigemptyset(&ss);
-	sigaddset(&ss, SIGINT);
-	sigaddset(&ss, SIGTERM);
-	pthread_sigmask(SIG_UNBLOCK, &ss, NULL);
+	/* SIGTERM and SIGINT should be always block unless in pselect */
+	sigaddset(&ss, SIGUSR2);
 	/* Main loop */
 	while (!quit) {
 		fd_set in;
@@ -863,7 +862,7 @@ static void main_loop(int cmd_timeout)
 				FD_SET(thisfd->fd, &in);
 		}
 
-		select_status = select(FD_SETSIZE, &in, NULL, NULL, &tv);
+		select_status = pselect(FD_SETSIZE, &in, NULL, NULL, &tv, &ss);
 
 		if (reread_config) {
 			int saved_errno = errno;
-- 
1.8.4.5


