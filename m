From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Aug 2015 13:52:55 +0000 (UTC)
Subject: master - dmsetup: fix usage of ifdefs
Message-ID: <20150817135255.D47A760D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94c56559ca485c32c0e5c7253d22159ab1bbc0ea
Commit:        94c56559ca485c32c0e5c7253d22159ab1bbc0ea
Parent:        427d0a5e925d86145df12313aa36d5c61ff59bd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 17 15:11:00 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 17 15:52:06 2015 +0200

dmsetup: fix usage of ifdefs

---
 tools/dmsetup.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 097f1fd..dc002b0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -48,11 +48,11 @@
 #  include <sys/ioctl.h>
 #endif
 
-#if HAVE_SYS_TIMERFD_H
+#ifdef HAVE_SYS_TIMERFD_H
 # include <sys/timerfd.h>
 #endif
 
-#if HAVE_TERMIOS_H
+#ifdef HAVE_TERMIOS_H
 #  include <termios.h>
 #endif
 
@@ -532,7 +532,7 @@ static uint64_t _interval_num(void)
 	return 1 + (uint64_t) _int_args[COUNT_ARG] - _count;
 }
 
-#if HAVE_SYS_TIMERFD_H
+#ifdef HAVE_SYS_TIMERFD_H
 static int _start_timerfd_timer(void)
 {
 	struct itimerspec interval_timer;


