From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed, 12 Aug 2015 18:17:59 +0000 (UTC)
Subject: master - dmsetup: only free resources once in the final interval
Message-ID: <20150812181759.209576109C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e96041e18fa5f8f0ccb50d31ee0b1c9fb6c5db21
Commit:        e96041e18fa5f8f0ccb50d31ee0b1c9fb6c5db21
Parent:        0f45aa7f313e60e10aec6779e86f2179b8ac8865
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Aug 12 19:16:05 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Aug 12 19:16:05 2015 +0100

dmsetup: only free resources once in the final interval

The _update_interval_times() function is called once per reported
object: when shutting down at the end of a run only the first call
should free timestamps. Clear the timestamp pointers after free
and use this to signal to other callers that the clock is already
shut down.
---
 tools/dmsetup.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 9876bd2..459639b 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -638,6 +638,12 @@ static int _update_interval_times(void)
 	int r = 0;
 
 	/*
+	 * Clock shutdown for exit - nothing to do.
+	 */
+	if (_timer_fd == TIMER_STOPPED && !_cycle_timestamp)
+		return 1;
+
+	/*
          * Current timestamp. If _new_interval is set this is used as
          * the new cycle start timestamp.
 	 */
@@ -717,6 +723,9 @@ out:
 		if (_cycle_timestamp)
 			dm_timestamp_destroy(_cycle_timestamp);
 		dm_timestamp_destroy(this_timestamp);
+
+		/* Clear timestamp pointers to signal shutdown. */
+		_cycle_timestamp = this_timestamp = NULL;
 	}
 	return r;
 }


