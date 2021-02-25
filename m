From: Leo Yan <leo.yan@linaro.org>
Date: Thu, 25 Feb 2021 19:04:51 +0800
Subject: [PATCH LVM2 v1 2/2] lvmlockctl: Automatically handle failure
In-Reply-To: <20210225110451.175956-1-leo.yan@linaro.org>
References: <20210225110451.175956-1-leo.yan@linaro.org>
Message-ID: <20210225110451.175956-2-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Zhang Huan <zhanghuan@huayun.com>

When the lock manager detects drive failure, it invokes command
"lvmlockctl" to handle the faiulre; in this case, lvmlockctl
automatically calls "blkdeactivate -l forcevg" to deactivate VG
and calls drop_vg() to cleanup the lockspace.

Signed-off-by: Zhang Huan <zhanghuan@huayun.com>
[Refactored the changes and commit log]
Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 configure                     |  3 +++
 configure.ac                  |  2 ++
 daemons/lvmlockd/lvmlockctl.c | 40 +++++++++++++++++++++++++++-------------
 include/configure.h.in        |  3 +++
 man/lvmlockctl.8_main         | 11 +++++------
 5 files changed, 40 insertions(+), 19 deletions(-)

diff --git a/configure b/configure
index 7d4f337..a6cd432 100755
--- a/configure
+++ b/configure
@@ -684,6 +684,7 @@ MANGLING
 LVM_RELEASE_DATE
 LVM_RELEASE
 LVM_PATH
+LVM_DIR
 LVM_PATCHLEVEL
 LVM_MINOR
 LVM_MAJOR
@@ -15298,9 +15299,11 @@ SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
 SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
+LVM_DIR="$SBINDIR/"
 
 cat >>confdefs.h <<_ACEOF
 #define LVM_PATH "$LVM_PATH"
+#define LVM_DIR "$LVM_DIR"
 _ACEOF
 
 
diff --git a/configure.ac b/configure.ac
index 99b7c88..11ffdb5 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1820,7 +1820,9 @@ SYSCONFDIR="$(eval echo $(eval echo $sysconfdir))"
 
 SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
+LVM_DIR="$SBINDIR/"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
+AC_DEFINE_UNQUOTED(LVM_DIR, ["$LVM_DIR"], [Path to lvm binary dir.])
 
 USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"
 CLVMD_PATH="$USRSBINDIR/clvmd"
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 436221d..35b409d 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -17,6 +17,7 @@
 #include <signal.h>
 #include <errno.h>
 #include <fcntl.h>
+#include <stdlib.h>
 #include <syslog.h>
 #include <sys/socket.h>
 #include <sys/un.h>
@@ -32,6 +33,7 @@ static int gl_enable = 0;
 static int gl_disable = 0;
 static int stop_lockspaces = 0;
 static char *arg_vg_name = NULL;
+static int do_drop(void);
 
 #define DUMP_SOCKET_NAME "lvmlockd-dump.sock"
 #define DUMP_BUF_SIZE (1024 * 1024)
@@ -53,6 +55,11 @@ do { \
 #define MAX_NAME 64
 #define MAX_ARGS 64
 
+#define BLKDEACTIVATE_CMD "blkdeactivate -l forcevg "
+/* The max string length for blkdeactivate command */
+#define MAX_BLKDEACTIVATE_CMD	(sizeof(LVM_DIR) + sizeof(BLKDEACTIVATE_CMD) + \
+				 MAX_NAME + 1)
+
 /*
  * lvmlockd dumps the client info before the lockspaces,
  * so we can look up client info when printing lockspace info.
@@ -506,11 +513,9 @@ static int do_kill(void)
 	daemon_reply reply;
 	int result;
 	int rv;
+	char deactivate_cmd[MAX_BLKDEACTIVATE_CMD+1] = { 0 };
 
 	syslog(LOG_EMERG, "Lost access to sanlock lease storage in VG %s.", arg_vg_name);
-	/* These two lines explain the manual alternative to the FIXME below. */
-	syslog(LOG_EMERG, "Immediately deactivate LVs in VG %s.", arg_vg_name);
-	syslog(LOG_EMERG, "Once VG is unused, run lvmlockctl --drop %s.", arg_vg_name);
 
 	/*
 	 * It may not be strictly necessary to notify lvmlockd of the kill, but
@@ -534,16 +539,25 @@ static int do_kill(void)
 
 	daemon_reply_destroy(reply);
 
-	/*
-	 * FIXME: here is where we should implement a strong form of
-	 * blkdeactivate, and if it completes successfully, automatically call
-	 * do_drop() afterward.  (The drop step may not always be necessary
-	 * if the lvm commands run while shutting things down release all the
-	 * leases.)
-	 *
-	 * run_strong_blkdeactivate();
-	 * do_drop();
-	 */
+	snprintf(deactivate_cmd, MAX_BLKDEACTIVATE_CMD, "%s%s%s",
+		 LVM_DIR, BLKDEACTIVATE_CMD, arg_vg_name);
+
+	syslog(LOG_EMERG, "Immediately deactivate LVs in VG %s.", arg_vg_name);
+	rv = system(deactivate_cmd);
+	if (rv) {
+		syslog(LOG_EMERG, "Deactivated LVs in VG %s failed.",
+		       arg_vg_name);
+		return rv;
+	} else {
+		syslog(LOG_EMERG, "Deactivated LVs in VG %s successfully.",
+		       arg_vg_name);
+	}
+
+	rv = do_drop();
+	if (rv)
+		syslog(LOG_EMERG, "lvmlockctl --drop %s failed.", arg_vg_name);
+	else
+		syslog(LOG_EMERG, "lvmlockctl --drop %s success.", arg_vg_name);
 
 	return rv;
 }
diff --git a/include/configure.h.in b/include/configure.h.in
index 812cacc..9e7b127 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -643,6 +643,9 @@
 /* Path to lvm binary. */
 #undef LVM_PATH
 
+/* Path to lvm binary dir. */
+#undef LVM_DIR
+
 /* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
    */
 #undef MAJOR_IN_MKDEV
diff --git a/man/lvmlockctl.8_main b/man/lvmlockctl.8_main
index b7ac0ec..99698bc 100644
--- a/man/lvmlockctl.8_main
+++ b/man/lvmlockctl.8_main
@@ -65,17 +65,16 @@ and prints it.
 .SS kill
 
 This is run by sanlock when it loses access to the storage holding leases
-for a VG.  It currently emits a syslog message stating that the VG must
-be immediately deactivated.  In the future it may automatically attempt to
-forcibly deactivate the VG.  For more, see
-.BR lvmlockd (8).
+for a VG.  It will call 'deactivate -l forcevg <vgname>' to forcibly
+deactivate the whole VG.  After successful deactivate, do 'drop vg' to
+clear the stale lockspace.  For more, see
+.BR lvmlockd (8), blkdeactivate (8).
 
 .SS drop
 
 This should only be run after a VG has been successfully deactivated
 following an lvmlockctl --kill command.  It clears the stale lockspace
-from lvmlockd.  In the future, this may become automatic along with an
-automatic handling of --kill.  For more, see
+from lvmlockd.  For more, see
 .BR lvmlockd (8).
 
 .SS gl-enable
-- 
1.8.3.1


