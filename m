From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Jun 2012 20:53:47 +0000 (UTC)
Subject: master - dmeventd: Improve comment about repeated DIE msgs
Message-ID: <20120608205347.0DBE72262@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f01f1453cef74b4198c1ef1ada3625f49c444a9
Commit:        9f01f1453cef74b4198c1ef1ada3625f49c444a9
Parent:        a35e45a79e1553b0d9c0c6825bbe151a61aefe90
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 8 21:52:02 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 8 21:52:02 2012 +0100

dmeventd: Improve comment about repeated DIE msgs

---
 daemons/dmeventd/dmeventd.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 801c984..91ef690 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1893,7 +1893,10 @@ static void restart(void)
 		exit(EXIT_FAILURE);
 	}
 
-	/* Let's wait a bit till deamon dies - spaming him with messages meanwhile */
+	/*
+	 * Wait for daemon to die, detected by sending further DIE messages
+	 * until one fails.
+	 */
 	for (i = 0; i < 10; ++i) {
 		if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0))
 			break; /* yep, it's dead probably */


