From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:34:06 +0000 (UTC)
Subject: master - dmeventd: debug signals
Message-ID: <20151022213406.C51D76057E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4284ba65ebe6401b2dbedc9abe850b650ed68f93
Commit:        4284ba65ebe6401b2dbedc9abe850b650ed68f93
Parent:        aeec62ad1987a5ec59b782f3377d6ae1693e1eab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 11:15:53 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:41:12 2015 +0200

dmeventd: debug signals

---
 daemons/dmeventd/dmeventd.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 2706ad6..a7c1c6e 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -789,6 +789,23 @@ static void _unregister_for_timeout(struct thread_status *thread)
 	pthread_mutex_unlock(&_timeout_mutex);
 }
 
+#ifdef DEBUG_SIGNALS
+/* Print list of signals within a signal set */
+static void _print_sigset(const char *prefix, const sigset_t *sigset)
+{
+	int sig, cnt = 0;
+
+	for (sig = 1; sig < NSIG; sig++)
+		if (!sigismember(sigset, sig)) {
+			cnt++;
+			log_debug("%s%d (%s)", prefix, sig, strsignal(sig));
+		}
+
+	if (!cnt)
+		log_debug("%s<empty signal set>", prefix);
+}
+#endif
+
 static sigset_t _unblock_sigalrm(void)
 {
 	sigset_t set, old;
@@ -844,6 +861,9 @@ static int _event_wait(struct thread_status *thread)
 
 	pthread_sigmask(SIG_SETMASK, &set, NULL);
 
+#ifdef DEBUG_SIGNALS
+	_print_sigset("dmeventd blocking ", &set);
+#endif
 	DEBUGLOG("Completed waitevent task for %s.", thread->device.name);
 
 	return ret;


