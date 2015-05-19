From: okozina <okozina@fedoraproject.org>
Date: Tue, 19 May 2015 19:02:49 +0000 (UTC)
Subject: master - polldaemon: move dev_close_all out of poll_get_copy_vg
Message-ID: <20150519190249.2FD2260976@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e5e0e220223edf0789d38a0a98341d745cf95b15
Commit:        e5e0e220223edf0789d38a0a98341d745cf95b15
Parent:        e27182249a2cef2518fbbab1037810ed5c9a6d37
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue May 19 11:37:39 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 19 20:55:22 2015 +0200

polldaemon: move dev_close_all out of poll_get_copy_vg

let's call dev_close_all() only before we're about to 'sleep'
for at least one second during the polling.

(it's questionable whether to call dev_close_all() at all in
polldaemon code. Natural extension would be to drop it completely)
---
 tools/polldaemon.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 83497b0..7f25887 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -59,8 +59,6 @@ struct volume_group *poll_get_copy_vg(struct cmd_context *cmd,
 				      const char *uuid __attribute__((unused)),
 				      uint32_t flags)
 {
-	dev_close_all();
-
 	if (name && !strchr(name, '/'))
 		return vg_read(cmd, name, NULL, flags);
 
@@ -153,6 +151,7 @@ static void _nanosleep(unsigned secs, unsigned allow_zero_time)
 static void _sleep_and_rescan_devices(struct daemon_parms *parms)
 {
 	if (parms->interval && !parms->aborting) {
+		dev_close_all();
 		_nanosleep(parms->interval, 1);
 		/* Devices might have changed while we slept */
 		init_full_scan_done(0);
@@ -362,6 +361,8 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
+		if (parms->interval)
+			dev_close_all();
 		_nanosleep(parms->interval, 1);
 	}
 }
@@ -487,6 +488,9 @@ static void _lvmpolld_poll_for_all_vgs(struct cmd_context *cmd,
 				report_progress(cmd, idl->id, lpdp.parms);
 		}
 
+		if (lpdp.parms->interval)
+			dev_close_all();
+
 		_nanosleep(lpdp.parms->interval, 0);
 	}
 
@@ -513,6 +517,9 @@ static int _lvmpoll_daemon(struct cmd_context *cmd, struct poll_operation_id *id
 				    (!parms->aborting && !(r = report_progress(cmd, id, parms))))
 					break;
 
+				if (parms->interval)
+					dev_close_all();
+
 				_nanosleep(parms->interval, 0);
 			}
 		}


