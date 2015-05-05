From: okozina <okozina@fedoraproject.org>
Date: Tue,  5 May 2015 18:54:13 +0000 (UTC)
Subject: master - polldaemon: optimise out waiting after polling
Message-ID: <20150505185413.6295760ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bda26acf70e92232b1ed644dba6b44ecbff2a058
Commit:        bda26acf70e92232b1ed644dba6b44ecbff2a058
Parent:        22ae43a11ef9bea5ae3a9c6127bb1ed07f93d103
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 5 16:09:53 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 5 20:51:45 2015 +0200

polldaemon: optimise out waiting after polling

Waiting even after _check_lv_status returned success and
'finished' flag was set to true doesn't make much sense.

Note that while we skip the wait() we also skip the
init_full_scan_done(0) inside the routine. This should
have no impact as long as the code after _wait_for_single_lv
doesn't presume anything about the state of the cache.
---
 tools/polldaemon.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 259ea47..4a4983a 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -209,7 +209,7 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 		 * polldaemon(s) are polling.  These other polldaemon(s) can then
 		 * continue polling an LV that doesn't have a "status".
 		 */
-		if (!parms->wait_before_testing)
+		if (!parms->wait_before_testing && !finished)
 			_sleep_and_rescan_devices(parms);
 	}
 


