From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 30 Jun 2017 21:00:26 -0400
Subject: master - clvmd: add debuglog mutex
Message-ID: <201707010100.v6110Ql2029593@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17ed25409136162d091809d412596a45e0a30fd4
Commit:        17ed25409136162d091809d412596a45e0a30fd4
Parent:        006a9eaada2744ca39b05aed7b7bf152524580be
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jul 1 00:58:39 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jul 1 00:58:39 2017 +0100

clvmd: add debuglog mutex

Log messages issued by different threads occasionally got intertwined.
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c98f5e..3f496fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Protect clvmd debug log messages with mutex.
   Fix shellcheck reported issues for script files.
 
 Version 2.02.172 - 28th June 2017
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index dcc986b..0f96356 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -92,6 +92,7 @@ static const size_t STACK_SIZE = 128 * 1024;
 static pthread_attr_t stack_attr;
 static int lvm_thread_exit = 0;
 static pthread_mutex_t lvm_thread_mutex;
+static pthread_mutex_t _debuglog_mutex;
 static pthread_cond_t lvm_thread_cond;
 static pthread_barrier_t lvm_start_barrier;
 static struct dm_list lvm_cmd_head;
@@ -218,14 +219,17 @@ void debuglog(const char *fmt, ...)
 
 	switch (clvmd_get_debug()) {
 	case DEBUG_STDERR:
+		pthread_mutex_lock(&_debuglog_mutex);
 		va_start(ap,fmt);
 		time(&P);
 		fprintf(stderr, "CLVMD[%x]: %.15s ", (int)pthread_self(), ctime_r(&P, buf_ctime) + 4);
 		vfprintf(stderr, fmt, ap);
 		va_end(ap);
 		fflush(stderr);
+		pthread_mutex_unlock(&_debuglog_mutex);
 		break;
 	case DEBUG_SYSLOG:
+		pthread_mutex_lock(&_debuglog_mutex);
 		if (!syslog_init) {
 			openlog("clvmd", LOG_PID, LOG_DAEMON);
 			syslog_init = 1;
@@ -234,6 +238,7 @@ void debuglog(const char *fmt, ...)
 		va_start(ap,fmt);
 		vsyslog(LOG_DEBUG, fmt, ap);
 		va_end(ap);
+		pthread_mutex_unlock(&_debuglog_mutex);
 		break;
 	case DEBUG_OFF:
 		break;
@@ -522,6 +527,7 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 	pthread_mutex_init(&lvm_thread_mutex, NULL);
+	pthread_mutex_init(&_debuglog_mutex, NULL);
 	pthread_cond_init(&lvm_thread_cond, NULL);
 	pthread_barrier_init(&lvm_start_barrier, NULL, 2);
 	init_lvhash();


