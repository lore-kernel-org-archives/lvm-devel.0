From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  1 May 2014 19:32:25 +0000 (UTC)
Subject: master - signals: Add init_signals.
Message-ID: <20140501193225.B50C360F93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=09064cc2db00a5da593aa9be61572aa643e4b035
Commit:        09064cc2db00a5da593aa9be61572aa643e4b035
Parent:        2eed136f0f5d9eaa65d421b2b93b6405fd7c6f08
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 1 20:31:19 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 1 20:31:19 2014 +0100

signals: Add init_signals.

---
 lib/locking/file_locking.c |   17 ++---------------
 lib/misc/lvm-signal.c      |   17 +++++++++++++++++
 lib/misc/lvm-signal.h      |    1 +
 3 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 2f6716d..37fa0eb 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -33,10 +33,6 @@
 
 static char _lock_dir[PATH_MAX];
 
-static sig_t _oldhandler;
-static sigset_t _fullsigset, _intsigset;
-static volatile sig_atomic_t _handler_installed;
-
 static void _fin_file_locking(void)
 {
 	release_flocks(1);
@@ -163,17 +159,8 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS))
 		return 0;
 
-	if (sigfillset(&_intsigset) || sigfillset(&_fullsigset)) {
-		log_sys_error_suppress(suppress_messages, "sigfillset",
-				       "init_file_locking");
-		return 0;
-	}
-
-	if (sigdelset(&_intsigset, SIGINT)) {
-		log_sys_error_suppress(suppress_messages, "sigdelset",
-				       "init_file_locking");
-		return 0;
-	}
+	if (!init_signals(suppress_messages))
+		return_0;
 
 	return 1;
 }
diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
index f2d6d3b..690733b 100644
--- a/lib/misc/lvm-signal.c
+++ b/lib/misc/lvm-signal.c
@@ -62,6 +62,23 @@ void install_ctrl_c_handler(void)
 	siginterrupt(SIGINT, 1);
 }
 
+int init_signals(int suppress_messages)
+{
+	if (sigfillset(&_intsigset) || sigfillset(&_fullsigset)) {
+		log_sys_error_suppress(suppress_messages, "sigfillset",
+				       "init_signals");
+		return 0;
+	}
+
+	if (sigdelset(&_intsigset, SIGINT)) {
+		log_sys_error_suppress(suppress_messages, "sigdelset",
+				       "init_signals");
+		return 0;
+	}
+
+	return 1;
+}
+
 static void _catch_sigint(int unused __attribute__((unused)))
 {
 	_sigint_caught = 1;
diff --git a/lib/misc/lvm-signal.h b/lib/misc/lvm-signal.h
index f2e6141..3fb55f3 100644
--- a/lib/misc/lvm-signal.h
+++ b/lib/misc/lvm-signal.h
@@ -18,6 +18,7 @@
 
 void remove_ctrl_c_handler(void);
 void install_ctrl_c_handler(void);
+int init_signals(int suppress_messages);
 
 void sigint_allow(void);
 int sigint_caught(void);


