From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 18 Dec 2016 14:11:32 +0000 (UTC)
Subject: master - dmstats: fix TIMERFD _timer_running() test
Message-ID: <20161218141132.3934B60FCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e53adf7c0b83194a74a9fa75a7ebbf1c077de9a
Commit:        3e53adf7c0b83194a74a9fa75a7ebbf1c077de9a
Parent:        5a4750d76c9930a6e4a181ab664f0cac4d1a400b
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Dec 18 14:07:25 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sun Dec 18 14:07:25 2016 +0000

dmstats: fix TIMERFD _timer_running() test

---
 tools/dmsetup.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 06d609b..e5ac80a 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -652,10 +652,7 @@ static int _do_timer_wait(void)
 
 static int _timer_running(void)
 {
-	/*
-	 * Clock shutdown for exit - nothing to do.
-	 */
-	return ((_timer_fd == TIMER_STOPPED) && !_cycle_timestamp);
+	return ((_timer_fd != TIMER_STOPPED) || _cycle_timestamp);
 }
 
 #else /* !HAVE_SYS_TIMERFD_H */


