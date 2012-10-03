From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  3 Oct 2012 13:14:38 +0000 (UTC)
Subject: master - liblvm2cmd: add return code for _close_stray_fds
Message-ID: <20121003131438.37E662319@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1f30e048bd8b387e25baad4f82223b63dc516cf5
Commit:        1f30e048bd8b387e25baad4f82223b63dc516cf5
Parent:        98bcfdca837c8b56cc355e74672c932c1e8ed735
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 15 01:18:23 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 3 15:01:23 2012 +0200

liblvm2cmd: add return code for _close_stray_fds

Close fds via /proc/self/fd parsing
Return error code if _close_stray_fds fails and quit application
if system is in some nonstandard state.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |   47 ++++++++++++++++++++++++++++++++++++-----------
 2 files changed, 37 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1868f99..5f82424 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Use /proc/self/fd for closing openned descriptors.
   Add missing pkg init with --enable-testing in configure.in (2.02.71).
   Fix inability to create, extend or convert to a large (> 1TiB) RAID LV.
   Add (p)artial attribute to lvs.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c5341df..e015a12 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -25,6 +25,7 @@
 #include <sys/stat.h>
 #include <time.h>
 #include <sys/resource.h>
+#include <dirent.h>
 
 #ifdef HAVE_GETOPTLONG
 #  include <getopt.h>
@@ -1252,26 +1253,49 @@ static void _close_descriptor(int fd, unsigned suppress_warnings,
 	fprintf(stderr, " Parent PID %" PRIpid_t ": %s\n", ppid, parent_cmdline);
 }
 
-static void _close_stray_fds(const char *command)
+static int _close_stray_fds(const char *command)
 {
 	struct rlimit rlim;
 	int fd;
 	unsigned suppress_warnings = 0;
 	pid_t ppid = getppid();
 	const char *parent_cmdline = _get_cmdline(ppid);
-
-	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0) {
-		fprintf(stderr, "getrlimit(RLIMIT_NOFILE) failed: %s\n",
-			strerror(errno));
-		return;
-	}
+	static const char _fd_dir[] = DEFAULT_PROC_DIR "/self/fd";
+	struct dirent *dirent;
+	DIR *d;
 
 	if (getenv("LVM_SUPPRESS_FD_WARNINGS"))
 		suppress_warnings = 1;
 
-	for (fd = 3; fd < (int)rlim.rlim_cur; fd++)
-		_close_descriptor(fd, suppress_warnings, command, ppid,
-				  parent_cmdline);
+	if (!(d = opendir(_fd_dir))) {
+		if (errno != ENOENT) {
+			log_sys_error("opendir", _fd_dir);
+			return 0; /* broken system */
+		}
+
+		/* Path does not exist, use the old way */
+		if (getrlimit(RLIMIT_NOFILE, &rlim) < 0) {
+			log_sys_error("getrlimit", "RLIMIT_NOFILE");
+			return 1;
+		}
+
+		for (fd = 3; fd < (int)rlim.rlim_cur; fd++)
+			_close_descriptor(fd, suppress_warnings, command, ppid,
+					  parent_cmdline);
+		return 1;
+	}
+
+	while ((dirent = readdir(d))) {
+		fd = atoi(dirent->d_name);
+		if (fd > 2 && fd != dirfd(d))
+			_close_descriptor(fd, suppress_warnings,
+					  command, ppid, parent_cmdline);
+	}
+
+	if (closedir(d))
+		log_sys_error("closedir", _fd_dir);
+
+	return 1;
 }
 
 struct cmd_context *init_lvm(void)
@@ -1426,7 +1450,8 @@ int lvm2_main(int argc, char **argv)
 	    strcmp(base, "initrd-lvm"))
 		alias = 1;
 
-	_close_stray_fds(base);
+	if (!_close_stray_fds(base))
+		return -1;
 
 	if (is_static() && strcmp(base, "lvm.static") &&
 	    path_exists(LVM_SHARED_PATH) &&


