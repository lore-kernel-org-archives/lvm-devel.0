From: okozina <okozina@fedoraproject.org>
Date: Tue,  5 May 2015 18:54:17 +0000 (UTC)
Subject: master - polldaemon: introduce _nanosleep function
Message-ID: <20150505185417.9EE8260ED3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=81c038934c61f4c2afe159460b04dbccdda2a721
Commit:        81c038934c61f4c2afe159460b04dbccdda2a721
Parent:        76a0dffe6f4869de9ca457119c9d7ced837d4e0b
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Apr 10 16:31:28 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 5 20:52:17 2015 +0200

polldaemon: introduce _nanosleep function

querying future lvmpolld with zero wait time is highly undesirable
and can cause serious performance drop of the future daemon. The new
wrapper function may avoid immediate return from syscal by
introducing minimal wait time on demand.
---
 tools/polldaemon.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 4c010f5..a311e24 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -13,10 +13,14 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include <time.h>
+
 #include "tools.h"
 #include "polldaemon.h"
 #include "lvm2cmdline.h"
 
+#define WAIT_AT_LEAST_NANOSECS 100000
+
 progress_t poll_mirror_progress(struct cmd_context *cmd,
 				struct logical_volume *lv, const char *name,
 				struct daemon_parms *parms)
@@ -133,11 +137,22 @@ static int _check_lv_status(struct cmd_context *cmd,
 	return 1;
 }
 
+static void _nanosleep(unsigned secs, unsigned allow_zero_time)
+{
+	struct timespec wtime = {
+		.tv_sec = secs,
+	};
+
+	if (!secs && !allow_zero_time)
+		wtime.tv_nsec = WAIT_AT_LEAST_NANOSECS;
+
+	while (!nanosleep(&wtime, &wtime) && errno == EINTR) {}
+}
+
 static void _sleep_and_rescan_devices(struct daemon_parms *parms)
 {
-	/* FIXME Use alarm for regular intervals instead */
 	if (parms->interval && !parms->aborting) {
-		sleep(parms->interval);
+		_nanosleep(parms->interval, 1);
 		/* Devices might have changed while we slept */
 		init_full_scan_done(0);
 	}
@@ -346,7 +361,7 @@ static void _poll_for_all_vgs(struct cmd_context *cmd,
 		process_each_vg(cmd, 0, NULL, READ_FOR_UPDATE, handle, _poll_vg);
 		if (!parms->outstanding_count)
 			break;
-		sleep(parms->interval);
+		_nanosleep(parms->interval, 1);
 	}
 }
 


