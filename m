From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 29 Oct 2010 16:43:53 -0000
Subject: LVM2 daemons/dmeventd/plugins/snapshot/dmevent ...
Message-ID: <20101029164353.17649.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-29 16:43:52

Modified files:
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 
	test           : test-utils.sh 
Added files:
	test           : t-snapshot-autoumount-dmeventd.sh 

Log message:
	Add code to the dmeventd snapshot plugin to automatically unmount snapshots
	that have been invalidated.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-snapshot-autoumount-dmeventd.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/10/15 16:28:14	1.11
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/10/29 16:43:51	1.12
@@ -21,6 +21,7 @@
 
 #include "lvm-string.h"
 
+#include <sys/wait.h>
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 
@@ -31,6 +32,8 @@
 /* Do not bother checking snapshots less than 50% full. */
 #define CHECK_MINIMUM 50
 
+#define UMOUNT_COMMAND "/bin/umount"
+
 struct snap_status {
 	int invalid;
 	int used;
@@ -71,6 +74,47 @@
 	status->max = atoi(p);
 }
 
+static int _run(const char *cmd, ...)
+{
+        va_list ap;
+        int argc = 1; /* for argv[0], i.e. cmd */
+        int i = 0;
+        const char **argv;
+        pid_t pid = fork();
+        int status;
+
+        if (pid == 0) { /* child */
+                va_start(ap, cmd);
+                while (va_arg(ap, const char *))
+                        ++ argc;
+                va_end(ap);
+
+                /* + 1 for the terminating NULL */
+                argv = alloca(sizeof(const char *) * (argc + 1));
+
+                argv[0] = cmd;
+                va_start(ap, cmd);
+                while ((argv[++i] = va_arg(ap, const char *)));
+                va_end(ap);
+
+                execvp(cmd, (char **)argv);
+                syslog(LOG_ERR, "Failed to execute %s: %s.\n", cmd, strerror(errno));
+                exit(127);
+        }
+
+        if (pid > 0) { /* parent */
+                if (waitpid(pid, &status, 0) != pid)
+                        return 0; /* waitpid failed */
+                if (!WIFEXITED(status) || WEXITSTATUS(status))
+                        return 0; /* the child failed */
+        }
+
+        if (pid < 0)
+                return 0; /* fork failed */
+
+        return 1; /* all good */
+}
+
 static int _extend(const char *device)
 {
 	char *vg = NULL, *lv = NULL, *layer = NULL;
@@ -93,6 +137,41 @@
 	return r == ECMD_PROCESSED;
 }
 
+static void _umount(const char *device, int major, int minor)
+{
+	FILE *mounts;
+	char buffer[4096];
+	char *words[3];
+	struct stat st;
+
+	if (!(mounts = fopen("/proc/mounts", "r"))) {
+		syslog(LOG_ERR, "Could not read /proc/mounts. Not umounting %s.\n", device);
+		return;
+	}
+
+	while (!feof(mounts)) {
+		/* read a line of /proc/mounts */
+		if (!fgets(buffer, sizeof(buffer), mounts))
+			break; /* eof, likely */
+
+		/* words[0] is the mount point and words[1] is the device path */
+		dm_split_words(buffer, 3, 0, words);
+
+		/* find the major/minor of the device */
+		if (stat(words[0], &st))
+			continue; /* can't stat, skip this one */
+
+		if (S_ISBLK(st.st_mode) &&
+		    major(st.st_rdev) == major &&
+		    minor(st.st_rdev) == minor) {
+			syslog(LOG_ERR, "Unmounting invalid snapshot %s from %s.", device, words[1]);
+                        if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
+                                syslog(LOG_ERR, "Failed to umount snapshot %s from %s: %s.",
+                                       device, words[1], strerror(errno));
+		}
+	}
+}
+
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
 		   void **private)
@@ -117,6 +196,16 @@
 
 	_parse_snapshot_params(params, &status);
 
+	if (status.invalid) {
+		syslog(LOG_ERR, "Trying to umount invalid snapshot %s...\n", device);
+		struct dm_info info;
+		if (dm_task_get_info(dmt, &info)) {
+			dmeventd_lvm2_unlock();
+			_umount(device, info.major, info.minor);
+                        return;
+		} /* else; too bad, but this is best-effort thing... */
+	}
+
 	/*
 	 * If the snapshot has been invalidated or we failed to parse
 	 * the status string. Report the full status string to syslog.
/cvs/lvm2/LVM2/test/t-snapshot-autoumount-dmeventd.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-snapshot-autoumount-dmeventd.sh
+++ -	2010-10-29 16:43:52.931121000 +0000
@@ -0,0 +1,41 @@
+#!/bin/bash
+# Copyright (C) 2010 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# no automatic extensions please
+LVM_TEST_CONFIG_SNAPSHOT_AUTOEXTEND="
+    snapshot_autoextend_percent = 0
+    snapshot_autoextend_threshold = 100"
+
+. ./test-utils.sh
+
+which mkfs.ext2 || exit 200
+
+prepare_lvmconf
+
+aux prepare_vg 2
+aux prepare_dmeventd
+
+lvcreate -l 8 -n base $vg
+mkfs.ext2 $DM_DEV_DIR/$vg/base
+
+lvcreate -s -l 4 -n snap $vg/base
+lvchange --monitor y $vg/snap
+
+mkdir mnt
+mount $DM_DEV_DIR/$vg/snap mnt
+mount
+cat /proc/mounts | grep $vg-snap
+
+dd if=/dev/zero of=mnt/file$1 bs=1M count=17
+sync
+sleep 10 # dmeventd only checks every 10 seconds :(
+
+cat /proc/mounts | not grep $vg-snap
--- LVM2/test/test-utils.sh	2010/10/26 01:25:46	1.54
+++ LVM2/test/test-utils.sh	2010/10/29 16:43:52	1.55
@@ -121,6 +121,7 @@
 		init_udev_transaction
 		while dmsetup table | grep -q ^$PREFIX; do
 			for s in `dmsetup info -c -o name --noheading | grep ^$PREFIX`; do
+				umount -fl $DM_DEV_DIR/mapper/$s || true
 				dmsetup remove $s >& /dev/null || true
 			done
 		done
@@ -360,6 +361,11 @@
 	test -z "$filter" && \
 		filter='[ "a/dev\/mirror/", "a/dev\/mapper\/.*pv[0-9_]*$/", "r/.*/" ]'
         locktype=
+	if test -z "$LVM_TEST_CONFIG_SNAPSHOT_AUTOEXTEND"; then
+		LVM_TEST_CONFIG_SNAPSHOT_AUTOEXTEND="
+    snapshot_autoextend_percent = 50
+    snapshot_autoextend_threshold = 50"
+	fi
 	if test -n "$LVM_TEST_LOCKING"; then locktype="locking_type = $LVM_TEST_LOCKING"; fi
 	cat > $TESTDIR/etc/lvm.conf.new <<-EOF
   $LVM_TEST_CONFIG
@@ -395,8 +401,7 @@
     udev_sync = 1
     udev_rules = 1
     polling_interval = 0
-    snapshot_autoextend_percent = 50
-    snapshot_autoextend_threshold = 50
+    $LVM_TEST_CONFIG_SNAPSHOT_AUTOEXTEND
   }
 EOF
 	# FIXME remove this workaround after mmap & truncating file problems solved


