From: Milan Broz <mbroz@redhat.com>
Date: Mon, 17 Jan 2011 20:33:55 +0100
Subject: [PATCH] Remove DEBUGLOG from dmeventd
In-Reply-To: <1295292835-7181-1-git-send-email-mbroz@redhat.com>
References: <1295292835-7181-1-git-send-email-mbroz@redhat.com>
Message-ID: <1295292835-7181-2-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

DEBUGLOG is used only on one line, remove it completely.
---
 daemons/dmeventd/dmeventd.c |   22 +---------------------
 1 files changed, 1 insertions(+), 21 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 2b454f9..4ac5e25 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -95,8 +95,6 @@ static pthread_mutex_t _global_mutex;
 
 #define THREAD_STACK_SIZE (300*1024)
 
-#define DEBUGLOG(fmt, args...) _debuglog(fmt, ## args)
-
 int dmeventd_debug = 0;
 static int _foreground = 0;
 static int _restart = 0;
@@ -203,24 +201,6 @@ static DM_LIST_INIT(_timeout_registry);
 static pthread_mutex_t _timeout_mutex = PTHREAD_MUTEX_INITIALIZER;
 static pthread_cond_t _timeout_cond = PTHREAD_COND_INITIALIZER;
 
-static void _debuglog(const char *fmt, ...)
-{
-        time_t P;
-        va_list ap;
- 
-        if (!_foreground)
-                return;
- 
-        va_start(ap,fmt);
-
-        time(&P);
-        fprintf(stderr, "dmeventd[%p]: %.15s ", (void *) pthread_self(), ctime(&P)+4 );
-        vfprintf(stderr, fmt, ap);
-	fprintf(stderr, "\n");
-
-        va_end(ap);
-}
-
 /* Allocate/free the status structure for a monitoring thread. */
 static struct thread_status *_alloc_thread_status(struct message_data *data,
 						  struct dso_data *dso_data)
@@ -1621,7 +1601,7 @@ static int _set_oom_adj(int val)
 
 	if (stat(OOM_ADJ_FILE, &st) == -1) {
 		if (errno == ENOENT)
-			DEBUGLOG(OOM_ADJ_FILE " not found");
+			perror(OOM_ADJ_FILE " not found");
 		else
 			perror(OOM_ADJ_FILE ": stat failed");
 		return 1;
-- 
1.7.2.3


