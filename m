From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 08:15:32 +0000 (UTC)
Subject: master - libdm: test for zero interval_ns in _utilization() (Coverity)
Message-ID: <20160706081532.574B661CF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03e03e9c11f5731c225d6cb99a1f36d4d8b699f6
Commit:        03e03e9c11f5731c225d6cb99a1f36d4d8b699f6
Parent:        5d3b136d38db40a6d26b8a09e7a4b504fa2f85d1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 09:12:51 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 09:14:43 2016 +0100

libdm: test for zero interval_ns in _utilization() (Coverity)

It's possible for interval_ns to be zero if the interval is not
set or the clock is misconfigured. Test for this before using the
value as the divisor in the utilisation calculation.
---
 libdm/libdm-stats.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 057bbcc..c0ef38f 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -2656,10 +2656,19 @@ static int _utilization(const struct dm_stats *dms, double *util,
 	 * for the last interval; do not allow a value > 100% utilization
 	 * to be passed to a dm_make_percent() call. We expect to see these
 	 * at startup if counters have not been cleared before the first read.
+	 *
+	 * A zero interval_ns is also an error since metrics cannot be
+	 * calculated without a defined interval - return zero and emit a
+	 * backtrace in this case.
 	 */
 	io_nsecs = dm_stats_get_counter(dms, DM_STATS_IO_NSECS,
 					region_id, area_id);
 
+	if (!interval_ns) {
+		*util = 0.0;
+		return_0;
+	}
+
 	io_nsecs = ((io_nsecs < interval_ns) ? io_nsecs : interval_ns);
 
 	*util = (double) io_nsecs / (double) interval_ns;


