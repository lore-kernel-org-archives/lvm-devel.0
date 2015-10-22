From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:58 +0000 (UTC)
Subject: master - cleanup: use enums
Message-ID: <20151022213358.580B36057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=466a1c72b7f24be4c932b503b3f8a3fb50a2eda5
Commit:        466a1c72b7f24be4c932b503b3f8a3fb50a2eda5
Parent:        81e9ab3156badecc6a64447708c4ae4886e3c244
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 21 20:56:20 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:36:00 2015 +0200

cleanup: use enums

---
 daemons/dmeventd/dmeventd.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index cde4f93..8267dc4 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -102,7 +102,7 @@ static pthread_mutex_t _global_mutex;
 #define DM_THREAD_SHUTDOWN 1
 #define DM_THREAD_DONE     2
 
-#define THREAD_STACK_SIZE (300*1024)
+static const size_t THREAD_STACK_SIZE = 300 * 1024;
 
 static int _debug_level = 0;
 static int _use_syslog = 1;
@@ -774,9 +774,11 @@ static sigset_t _unblock_sigalrm(void)
 	return old;
 }
 
-#define DM_WAIT_RETRY 0
-#define DM_WAIT_INTR 1
-#define DM_WAIT_FATAL 2
+enum {
+	DM_WAIT_RETRY,
+	DM_WAIT_INTR,
+	DM_WAIT_FATAL
+};
 
 /* Wait on a device until an event occurs. */
 static int _event_wait(struct thread_status *thread, struct dm_task **task)


