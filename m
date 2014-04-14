From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Apr 2014 11:06:20 +0000 (UTC)
Subject: master - clvmd: use thread-safe ctime_r when debugging
Message-ID: <20140414110620.3F35060CDC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eccc50d86199921e8f2e0cf349db96e517b2625d
Commit:        eccc50d86199921e8f2e0cf349db96e517b2625d
Parent:        639983b6b7ac3257fc305624f22325fd3f6f0261
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 9 07:51:36 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 14 13:02:25 2014 +0200

clvmd: use thread-safe ctime_r when debugging

Use thread friendly version of ctime
TODO:should be probably replaced with strftime()
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index efc296d..61723e5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Use thread-safe ctime_r() for clvmd debug logging.
   Skip adding replies to already finished reply thread.
   Use mutex to check number of replies in request_timed_out() in clvmd.
   Drop usage of extra reply_mutex for localsock in clvmd.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index ee6e301..b1fe396 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -212,12 +212,13 @@ void debuglog(const char *fmt, ...)
 	time_t P;
 	va_list ap;
 	static int syslog_init = 0;
+	char buf_ctime[64];
 
 	switch (clvmd_get_debug()) {
 	case DEBUG_STDERR:
 		va_start(ap,fmt);
 		time(&P);
-		fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime(&P)+4 );
+		fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime_r(&P, buf_ctime) + 4);
 		vfprintf(stderr, fmt, ap);
 		va_end(ap);
 		break;


