From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:09 +0000 (UTC)
Subject: master - dmsetup: check for NULL from dm_task_get_ioctl_timestamp
Message-ID: <20151109092809.9962360B27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e90c5d206043af53e868c785707dabf070fa5747
Commit:        e90c5d206043af53e868c785707dabf070fa5747
Parent:        9df3069083cd49f75e0ec54fc1e699b057129934
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 8 19:27:22 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:19 2015 +0100

dmsetup: check for NULL from dm_task_get_ioctl_timestamp

Coverity: ensure NULL is not passed to dm_timestamp_delta().
---
 tools/dmsetup.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 036f58c..a5cbef5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -401,15 +401,18 @@ static int _task_run(struct dm_task *dmt)
 {
 	int r;
 	uint64_t delta;
+	struct dm_timestamp *ts;
 
 	if (_initial_timestamp)
 		dm_task_set_record_timestamp(dmt);
 
 	r = dm_task_run(dmt);
 
-	if (_initial_timestamp) {
-		delta = dm_timestamp_delta(dm_task_get_ioctl_timestamp(dmt), _initial_timestamp);
-		log_debug("Timestamp: %7" PRIu64 ".%09" PRIu64 " seconds", delta / NSEC_PER_SEC, delta % NSEC_PER_SEC);
+	if (_initial_timestamp &&
+	    (ts = dm_task_get_ioctl_timestamp(dmt))) {
+		delta = dm_timestamp_delta(ts, _initial_timestamp);
+		log_debug("Timestamp: %7" PRIu64 ".%09" PRIu64 " seconds",
+			  delta / NSEC_PER_SEC, delta % NSEC_PER_SEC);
 	}
 
 	return r;


