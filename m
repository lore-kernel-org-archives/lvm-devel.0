From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 12 Nov 2013 10:12:47 +0000 (UTC)
Subject: master - pvscan: retry VG refresh before autoactivation if it fails
Message-ID: <20131112101247.DE37C6116A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8085edf65006a50608edb821b3d30947abaa838
Commit:        d8085edf65006a50608edb821b3d30947abaa838
Parent:        7de533ad12972f5a9c5bf2d2b477d8320f7e4a8e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Nov 12 10:55:34 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Nov 12 11:09:45 2013 +0100

pvscan: retry VG refresh before autoactivation if it fails

There's a tiny race when suspending the device which is part
of the refresh because when suspend ioctl is performed, the
dm kernel driver executes (do_suspend and dm_suspend kernel fn):

  step 1: a check whether the dev is already suspended and
          if yes it returns success immediately as there's
          nothing to do
  step 2: it grabs the suspend lock
  step 3: another check whether the dev is already suspended
          and if found suspended, it exits with -EINVAL now

The race can occur in between step 1 and step 2. To prevent
premature autoactivation failure, we're using a simple retry
logic here before we fail completely. For a complete solution,
we need to fix the locking so there's no possibility for suspend
calls to interleave each other to cause this kind of race.

This is just a workaround. Remove it and replace it with proper
locking once we have that in!
---
 WHATS_NEW      |    1 +
 tools/pvscan.c |   34 +++++++++++++++++++++++++++++++++-
 2 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5eb4abe..af1a26a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104 -
 ===================================
+  Workaround VG refresh race during autoactivation by retrying the refresh.
   Handle failures in temporary mirror used when adding images to mirrors.
   Fix and improve logic for implicitely exclusive activations.
   Return success when LV cannot be activated because of volume_list filter.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index b6a07bd..ce8c446 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -91,10 +91,15 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 				display_size(cmd, (uint64_t) (pv_pe_count(pv) - pv_pe_alloc_count(pv)) * pv_pe_size(pv)));
 }
 
+#define REFRESH_BEFORE_AUTOACTIVATION_RETRIES 5
+#define REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY 100000
+
 static int _auto_activation_handler(struct cmd_context *cmd,
 				    const char *vgid, int partial,
 				    activation_change_t activate)
 {
+	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
+	int refresh_done = 0;
 	struct volume_group *vg;
 	int consistent = 0;
 	struct id vgid_raw;
@@ -115,7 +120,34 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 		r = 1; goto out;
 	}
 
-	if (!vg_refresh_visible(vg->cmd, vg)) {
+	/* FIXME: There's a tiny race when suspending the device which is part
+	 * of the refresh because when suspend ioctl is performed, the dm
+	 * kernel driver executes (do_suspend and dm_suspend kernel fn):
+	 *
+	 *          step 1: a check whether the dev is already suspended and
+	 *                  if yes it returns success immediately as there's
+	 *                  nothing to do
+	 *          step 2: it grabs the suspend lock
+	 *          step 3: another check whether the dev is already suspended
+	 *                  and if found suspended, it exits with -EINVAL now
+	 *
+	 * The race can occur in between step 1 and step 2. To prevent premature
+	 * autoactivation failure, we're using a simple retry logic here before
+	 * we fail completely. For a complete solution, we need to fix the
+	 * locking so there's no possibility for suspend calls to interleave
+	 * each other to cause this kind of race.
+	 *
+	 * Remove this workaround with "refresh_retries" once we have proper locking in!
+	 */
+	while (refresh_retries--) {
+		if (vg_refresh_visible(vg->cmd, vg)) {
+			refresh_done = 1;
+			break;
+		}
+		usleep(REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY);
+	}
+
+	if (!refresh_done) {
 		log_error("%s: refresh before autoactivation failed.", vg->name);
 		goto out;
 	}


