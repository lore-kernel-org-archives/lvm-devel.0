From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 14:05:09 +0000 (UTC)
Subject: master - cleanup: log_debug format matches args
Message-ID: <20150818140509.35C9E60DD1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef7264807ff44c029360e697dd391ab870bb4481
Commit:        ef7264807ff44c029360e697dd391ab870bb4481
Parent:        bc395067921fdd96c386e6d5b4ea613a39efea33
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 15:28:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 16:05:04 2015 +0200

cleanup: log_debug format matches args

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index b944402..45d4173 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -562,7 +562,7 @@ static int _start_timerfd_timer(void)
 	interval_timer.it_value.tv_sec = secs;
 	interval_timer.it_value.tv_nsec = nsecs;
 
-	log_debug("Setting interval timer to: "FMTu64"s "FMTu64"ns", secs, nsecs);
+	log_debug("Setting interval timer to: " FMTu64 "s %ldns", (uint64_t)secs, nsecs);
 	if (timerfd_settime(_timer_fd, 0, &interval_timer, NULL)) {
 		log_error("Could not set interval timer: %s", strerror(errno));
 		return 0;


