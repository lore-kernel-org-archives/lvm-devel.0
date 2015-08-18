From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Aug 2015 13:01:41 +0000 (UTC)
Subject: master - cleanup: add FMTssize_t
Message-ID: <20150818130141.4551160C4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58f8f29c41ea77678875e8784bd991fb480e3132
Commit:        58f8f29c41ea77678875e8784bd991fb480e3132
Parent:        3d08a49790c180e10e8a6d35cbd43d7eb214bf30
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 18 12:59:13 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 18 15:00:08 2015 +0200

cleanup: add FMTssize_t

Add define to print nicely ssize_t type.
---
 lib/misc/util.h |    2 ++
 tools/dmsetup.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/lib/misc/util.h b/lib/misc/util.h
index 113ca69..52d9f2b 100644
--- a/lib/misc/util.h
+++ b/lib/misc/util.h
@@ -37,11 +37,13 @@
 
 /* Define some portable printing types */
 #define PRIsize_t "zu"
+#define PRIssize_t "zd"
 #define PRIptrdiff_t "td"
 #define PRIpid_t PRId32
 
 /* For convenience */
 #define FMTsize_t "%" PRIsize_t
+#define FMTssize_t "%" PRIssize_t
 #define FMTptrdiff_t "%" PRIptrdiff_t
 #define FMTpid_t "%" PRIpid_t
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 8074395..b944402 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -590,7 +590,7 @@ static int _do_timerfd_wait(void)
 
 	/* read(2) on a timerfd descriptor is guaranteed to return 8 bytes. */
 	if (bytes != 8)
-		log_error("Unexepcted byte count on timerfd read: %d", bytes);
+		log_error("Unexpected byte count on timerfd read: " FMTssize_t, bytes);
 
 	/* FIXME: attempt to rebase clock? */
 	if (expired > 1)


