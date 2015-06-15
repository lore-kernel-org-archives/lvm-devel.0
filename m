From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Jun 2015 12:48:33 +0000 (UTC)
Subject: master - dmeventd: drop pthread_cancel
Message-ID: <20150615124833.37FA560FB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9da07f1d3ef40c982d463a97cf6aaf65f813ebc8
Commit:        9da07f1d3ef40c982d463a97cf6aaf65f813ebc8
Parent:        f715fefe314288a3200d60afd71991e86f3a098f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 15 14:39:17 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 15 14:46:44 2015 +0200

dmeventd: drop pthread_cancel

Drop unused pthread canceling as well as DEBUG printing in signal
handler.
---
 daemons/dmeventd/dmeventd.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index ad27060..d452f84 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1706,8 +1706,7 @@ static void _cleanup_unused_threads(void)
 
 static void _sig_alarm(int signum __attribute__((unused)))
 {
-	DEBUGLOG("Received SIGALRM.");
-	pthread_testcancel();
+	/* empty SIG_IGN */;
 }
 
 /* Init thread signal handling. */


