From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 17 Aug 2015 18:29:03 +0000 (UTC)
Subject: master - dmsetup: check timerfd reads for valid byte count (Coverity)
Message-ID: <20150817182904.017AB60F13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=12acf852c5661b771d8800a60dcf1ac799466289
Commit:        12acf852c5661b771d8800a60dcf1ac799466289
Parent:        074b5de7715b76ad63147f84edb5d9e1a05870e9
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 19:26:44 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 17 19:28:53 2015 +0100

dmsetup: check timerfd reads for valid byte count (Coverity)

The timerfd guarantees that it will return 8 bytes when a read(2)
is issued (a uint64_t giving the number of timer events during the
call). Check that it does so and log a non-fatal error if the byte
count is not 8.
---
 tools/dmsetup.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 7769fde..a937027 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -573,18 +573,25 @@ static int _start_timerfd_timer(void)
 static int _do_timerfd_wait(void)
 {
 	uint64_t expired;
+	ssize_t bytes;
 
 	if (_timer_fd < 0)
 		return 0;
 
 	/* read on timerfd returns a uint64_t in host byte order. */
-	if (read(_timer_fd, &expired, sizeof(expired)) < 0) {
+	bytes = read(_timer_fd, &expired, sizeof(expired));
+
+	if (bytes < 0) {
 		/* EBADF from invalid timerfd or EINVAL from too small buffer. */
 		log_error("Interval timer wait failed: %s",
 			  strerror(errno));
 		return 0;
 	}
 
+	/* read(2) on a timerfd descriptor is guaranteed to return 8 bytes. */
+	if (bytes != 8)
+		log_error("Unexepcted byte count on timerfd read: %d", bytes);
+
 	/* FIXME: attempt to rebase clock? */
 	if (expired > 1)
 		log_warn("WARNING: Try increasing --interval ("FMTu64


