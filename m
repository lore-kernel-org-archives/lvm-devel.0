From: Zhang Huan <zhanghuan@huayun.com>
Date: Thu, 14 Sep 2017 15:38:59 +0800
Subject: [patch review 1/1] lvmlockctl kill automatically do force deactivate and drop locks
Message-ID: <9F664087-26C0-46BA-9AF0-CF4FA6A2FD92@huayun.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi all,

commit 98f06cabfea03a828baaf318ce7b74a4f949a2e6
Author: Huan Zhang <zhanghuan@chinac.com>
Date:   Mon Aug 28 14:59:45 2017 +0800

    lvmlockctl kill automatically do force deactivate and drop locks
    
    'lvmlockctl kill' call 'blkdeactivate -l forcevg' after send kill_vg,
    if success, do drop_vg to relase the stale lockspace.
    
    Signed-off-by: Zhang Huan <zhanghuan@huayun.com>

diff --git a/configure b/configure
index 2afbe6e..be33a8b 100755
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
@@ -15416,9 +15417,11 @@ lvm_exec_prefix=$exec_prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
 LVM_PATH="$lvm_exec_prefix/sbin/lvm"
+LVM_DIR="$lvm_exec_prefix/sbin/"
 
 cat >>confdefs.h <<_ACEOF
 #define LVM_PATH "$LVM_PATH"
+#define LVM_DIR "$LVM_DIR"
 _ACEOF
 
 
diff --git a/configure.in b/configure.in
index 43e8652..54d1054 100644
--- a/configure.in
+++ b/configure.in
@@ -1890,7 +1890,9 @@ lvm_exec_prefix=$exec_prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$prefix
 test "$lvm_exec_prefix" = NONE && lvm_exec_prefix=$ac_default_prefix
 LVM_PATH="$lvm_exec_prefix/sbin/lvm"
+LVM_DIR="$lvm_exec_prefix/sbin/"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
+AC_DEFINE_UNQUOTED(LVM_DIR, ["$LVM_DIR"], [Path to lvm binary dir.])
 
 clvmd_prefix=$ac_default_prefix
 test "$prefix" != NONE && clvmd_prefix=$prefix
diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 7d4e072..33841d5 100644
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
@@ -53,6 +55,8 @@ do { \
 #define MAX_NAME 64
 #define MAX_ARGS 64
 
+#define BLKDEACTIVATE_CMD "blkdeactivate -l forcevg "
+#define MAX_BLKDEACTIVATE_CMD MAX_NAME+sizeof(LVM_DIR)+sizeof(BLKDEACTIVATE_CMD)
 /*
  * lvmlockd dumps the client info before the lockspaces,
  * so we can look up client info when printing lockspace info.
@@ -506,11 +510,9 @@ static int do_kill(void)
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
@@ -534,16 +536,21 @@ static int do_kill(void)
 
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
+	syslog(LOG_EMERG, "Immediately deactivate LVs in VG %s.", arg_vg_name);
+	rv = system(deactivate_cmd);
+	if (!rv) {
+		syslog(LOG_EMERG, "Deactivated LVs in VG %s successfully.", arg_vg_name);
+		syslog(LOG_EMERG, "Runing lvmlockctl --drop %s.", arg_vg_name);
+		rv = do_drop();
+		if (rv)
+			syslog(LOG_EMERG, "lvmlockctl --drop %s failed.", arg_vg_name);
+		else
+			syslog(LOG_EMERG, "lvmlockctl --drop %s success.", arg_vg_name);
+	}
+	else
+		syslog(LOG_EMERG, "Deactivated LVs in VG %s failed.", arg_vg_name);
 
 	return rv;
 }
diff --git a/include/configure.h.in b/include/configure.h.in
index 5172650..cbdbb72 100644
--- a/include/configure.h.in
+++ b/include/configure.h.in
@@ -638,6 +638,9 @@
 /* Path to lvm binary. */
 #undef LVM_PATH
 
+/* Path to lvm binary dir. */
+#undef LVM_DIR
+
 /* Define to 1 if `major', `minor', and `makedev' are declared in <mkdev.h>.
    */
 #undef MAJOR_IN_MKDEV
diff --git a/man/lvmlockctl.8_main b/man/lvmlockctl.8_main
index b7ac0ec..3c86abc 100644
--- a/man/lvmlockctl.8_main
+++ b/man/lvmlockctl.8_main
@@ -65,18 +65,18 @@ and prints it.
 .SS kill
 
 This is run by sanlock when it loses access to the storage holding leases
-for a VG.  It currently emits a syslog message stating that the VG must
-be immediately deactivated.  In the future it may automatically attempt to
-forcibly deactivate the VG.  For more, see
-.BR lvmlockd (8).
+for a VG. It will call 'deactivate -l forcevg <vgname>' to forcibly
+deactivate the whole VG. After successful deactivate, do 'drop vg' to clear
+the stale lockspace. For more, see
+.BR lvmlockd (8), blkdeactivate (8).
 
 .SS drop
 
 This should only be run after a VG has been successfully deactivated
 following an lvmlockctl --kill command.  It clears the stale lockspace
-from lvmlockd.  In the future, this may become automatic along with an
+from lvmlockd.  It has becomed automatic along with an
 automatic handling of --kill.  For more, see
-.BR lvmlockd (8).
+.BR lvmlockd (8), blkdeactivate (8).
 
 .SS gl-enable
 






