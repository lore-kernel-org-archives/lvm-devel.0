From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:53:39 -0400
Subject: master - lvmpolld: update to use new scanning correctly
Message-ID: <201804231353.w3NDrd5Y001240@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b0a8f47be7df13aab0552599aa2dc2233cc223c
Commit:        7b0a8f47be7df13aab0552599aa2dc2233cc223c
Parent:        aa833bdd8aa6a3e3557b19fa3877b0eee806df63
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 13 14:40:00 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

lvmpolld: update to use new scanning correctly

---
 tools/polldaemon.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index cf7a947..83f0424 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -126,6 +126,14 @@ static void _nanosleep(unsigned secs, unsigned allow_zero_time)
 static void _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_parms *parms)
 {
 	if (parms->interval && !parms->aborting) {
+		/*
+		 * FIXME: do we really need to drop everything and then rescan
+		 * everything between each iteration?  What change exactly does
+		 * each iteration check for, and does seeing that require
+		 * rescanning everything?
+		 */
+		lvmcache_destroy(cmd, 1, 0);
+		label_scan_destroy(cmd);
 		dev_close_all();
 		_nanosleep(parms->interval, 1);
 		lvmcache_label_scan(cmd);
@@ -141,6 +149,9 @@ int wait_for_single_lv(struct cmd_context *cmd, struct poll_operation_id *id,
 	uint32_t lockd_state = 0;
 	int ret;
 
+	if (!parms->wait_before_testing)
+		lvmcache_label_scan(cmd);
+
 	/* Poll for completion */
 	while (!finished) {
 		if (parms->wait_before_testing)


