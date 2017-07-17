From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Jul 2017 07:40:13 -0400
Subject: master - clvmd: fix valgrind warning
Message-ID: <201707171140.v6HBeDNV022498@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7f92ea8ee71997027007088beaf342c625abb44
Commit:        d7f92ea8ee71997027007088beaf342c625abb44
Parent:        ea96a9d68eadd3505330db73856418c253080dba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 17 12:23:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 17 12:29:57 2017 +0200

clvmd: fix valgrind warning

Initialize mutex upfront any debugging and fix this report:

Mutex reinitialization: mutex 0x485d20, recursion count 0, owner 1.
   at 0x4C38480: pthread_mutex_init_intercept (drd_pthread_intercepts.c:821)
   by 0x4C38480: pthread_mutex_init (drd_pthread_intercepts.c:830)
   by 0x11F359: main (clvmd.c:562)
mutex 0x485d20 was first observed at:
   at 0x4C38F63: pthread_mutex_lock_intercept (drd_pthread_intercepts.c:885)
   by 0x4C38F63: pthread_mutex_lock (drd_pthread_intercepts.c:898)
   by 0x11E920: debuglog (clvmd.c:254)
   by 0x11F1D8: main (clvmd.c:527)
---
 WHATS_NEW             |    1 +
 daemons/clvmd/clvmd.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 818458c..477d4ea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.173 - 
 =================================
+  Initialize debugging mutex before any debug message in clvmd.
   Log error instad of warn when noticing connection problem with lvmetad.
   Fix memory leak in lvmetad when working with duplicates.
   Accept 'lvm -h' and 'lvm --help' as well as 'lvm help' for help.
diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 881a931..0832f4a 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -124,7 +124,7 @@ static const size_t STACK_SIZE = 128 * 1024;
 static pthread_attr_t stack_attr;
 static int lvm_thread_exit = 0;
 static pthread_mutex_t lvm_thread_mutex;
-static pthread_mutex_t _debuglog_mutex;
+static pthread_mutex_t _debuglog_mutex = PTHREAD_MUTEX_INITIALIZER;
 static pthread_cond_t lvm_thread_cond;
 static pthread_barrier_t lvm_start_barrier;
 static struct dm_list lvm_cmd_head;
@@ -559,7 +559,6 @@ int main(int argc, char *argv[])
 		exit(1);
 	}
 	pthread_mutex_init(&lvm_thread_mutex, NULL);
-	pthread_mutex_init(&_debuglog_mutex, NULL);
 	pthread_cond_init(&lvm_thread_cond, NULL);
 	pthread_barrier_init(&lvm_start_barrier, NULL, 2);
 	init_lvhash();


