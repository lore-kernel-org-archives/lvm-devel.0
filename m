From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  4 Jul 2016 11:17:18 +0000 (UTC)
Subject: master - dmsetup: fix timestamp leak
Message-ID: <20160704111718.8EC656072E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=52be93c54bfedf16bb86472c03b6833d2be0efd1
Commit:        52be93c54bfedf16bb86472c03b6833d2be0efd1
Parent:        62dce13c7a00a71c73926340e05053b7ebee48e9
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jun 29 10:14:57 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 4 12:16:51 2016 +0100

dmsetup: fix timestamp leak

With a single report (--count=1) no timerfd is set up and the cycle
and current timestamps should be freed during the single call to
_update_interval_times().
---
 tools/dmsetup.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 03e2519..8ba12dd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -703,13 +703,16 @@ static int _update_interval_times(void)
 {
 	static struct dm_timestamp *this_timestamp = NULL;
 	uint64_t delta_t, interval_num = _interval_num();
-	int r = 0;
+	int r = 1;
 
 	/*
 	 * Clock shutdown for exit - nothing to do.
 	 */
-	if (_timer_fd == TIMER_STOPPED && !_cycle_timestamp)
-		return 1;
+	if ((_timer_fd == TIMER_STOPPED) && !_cycle_timestamp)
+		goto out;
+
+	/* clock is running */
+	r = 0;
 
 	/*
          * Current timestamp. If _new_interval is set this is used as
@@ -780,7 +783,8 @@ static int _update_interval_times(void)
 	r = 1;
 
 out:
-	if (!r || _timer_fd == TIMER_STOPPED) {
+	/* timer stopped or never started */
+	if (!r || _timer_fd < 0) {
 		/* The _cycle_timestamp has not yet been allocated if we
 		 * fail to obtain this_timestamp on the first interval.
 		 */


