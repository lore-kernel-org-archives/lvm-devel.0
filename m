From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Apr 2016 12:16:23 +0000 (UTC)
Subject: master - coverity: check for sys error in clock call
Message-ID: <20160422121623.04AAD6207B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a88828c8455823da52f6dbb0b5c77e2cc8b550e1
Commit:        a88828c8455823da52f6dbb0b5c77e2cc8b550e1
Parent:        bc239f15eb935f7962def5b8fde22b64b0b86b4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 22 14:06:58 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 14:15:36 2016 +0200

coverity: check for sys error in clock call

---
 daemons/lvmlockd/lvmlockd-core.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 9283568..f92ca01 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -306,7 +306,13 @@ static const char *_syslog_num_to_name(int num)
 static uint64_t monotime(void)
 {
 	struct timespec ts;
-	clock_gettime(CLOCK_MONOTONIC, &ts);
+
+	if (clock_gettime(CLOCK_MONOTONIC, &ts)) {
+		log_error("clock_gettime failed to get timestamp %s.",
+			  strerror(errno));
+		ts.tv_sec = 0;
+	}
+
 	return ts.tv_sec;
 }
 
@@ -3340,7 +3346,10 @@ static void *worker_thread_main(void *arg_in)
 
 	while (1) {
 		pthread_mutex_lock(&worker_mutex);
-		clock_gettime(CLOCK_REALTIME, &ts);
+		if (clock_gettime(CLOCK_REALTIME, &ts)) {
+			log_error("clock_gettime failed.");
+			ts.tv_sec = ts.tv_nsec = 0;
+		}
 		ts.tv_sec += delay_sec;
 		rv = 0;
 		act = NULL;


