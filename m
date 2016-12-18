From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 14:11:34 +0000 (UTC)
Subject: master - dmstats: don't declare _start_timestamp if HAVE_SYS_TIMERFD_H
Message-ID: <20161218141134.4F053605F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a15f0d181ca2fb44c9c854dfba425d372a8756c6
Commit:        a15f0d181ca2fb44c9c854dfba425d372a8756c6
Parent:        3e53adf7c0b83194a74a9fa75a7ebbf1c077de9a
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 14:08:11 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 14:08:11 2016 +0000

dmstats: don't declare _start_timestamp if HAVE_SYS_TIMERFD_H

The _start_timestamp is not used by the TIMERFD clock.
---
 tools/dmsetup.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index e5ac80a..3f2c619 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -282,13 +282,15 @@ const char *_stats_types[] = {
 
 /* report timekeeping */
 static struct dm_timestamp *_cycle_timestamp = NULL;
+#ifndef HAVE_SYS_TIMERFD_H
 static struct dm_timestamp *_start_timestamp = NULL;
+#else /* HAVE_SYS_TIMERFD_H */
+static int _timer_fd = -1; /* timerfd file descriptor. */
+#endif /* !HAVE_SYS_TIMERFD_H */
+
 static uint64_t _interval = 0; /* configured interval in nsecs */
 static uint64_t _new_interval = 0; /* flag top-of-interval */
 static uint64_t _last_interval = 0; /* approx. measured interval in nsecs */
-#ifdef HAVE_SYS_TIMERFD_H
-static int _timer_fd = -1; /* timerfd file descriptor. */
-#endif /* HAVE_SYS_TIMERFD_H */
 
 /* Invalid fd value used to signal end-of-reporting. */
 #define TIMER_STOPPED -2


