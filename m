From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:14 +0000 (GMT)
Subject: main - pooldaemon: increase min polling interval
Message-ID: <20210315101414.E36E43857C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1a451207b8ddbd15519ff9556c59287023ab50fa
Commit:        1a451207b8ddbd15519ff9556c59287023ab50fa
Parent:        5edb353062b26bbe93002717d77aa5d1707f1f70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 22:00:42 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

pooldaemon: increase min polling interval

Although we support '0' interval - it's highly inefficent to
do so many scans in busy-loop.

So ATM raise minimal rescan time to 100ms.

TODO: revisit whole timing logic here as it does have some sideeffect
hiddent impact and can considerably eat CPU in some cases.
---
 tools/polldaemon.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index d4e0be13e..32733b8ea 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -21,7 +21,7 @@
 
 #include <time.h>
 
-#define WAIT_AT_LEAST_NANOSECS 100000
+#define WAIT_AT_LEAST_NANOSECS 100000000
 
 progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
@@ -127,7 +127,7 @@ static void _nanosleep(unsigned secs, unsigned allow_zero_time)
 
 static void _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_parms *parms)
 {
-	if (parms->interval && !parms->aborting) {
+	if (!parms->aborting) {
 		/*
 		 * FIXME: do we really need to drop everything and then rescan
 		 * everything between each iteration?  What change exactly does
@@ -136,7 +136,7 @@ static void _sleep_and_rescan_devices(struct cmd_context *cmd, struct daemon_par
 		 */
 		lvmcache_destroy(cmd, 1, 0);
 		label_scan_destroy(cmd);
-		_nanosleep(parms->interval, 1);
+		_nanosleep(parms->interval, 0);
 		lvmcache_label_scan(cmd);
 	}
 }


