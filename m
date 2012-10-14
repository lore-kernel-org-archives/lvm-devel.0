From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 14 Oct 2012 21:21:22 +0000 (UTC)
Subject: master - thin: add support to unmount volumes
Message-ID: <20121014212122.BA07D22FD@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3972bd98fbec1c2ab9453a33790636a632e7be65
Commit:        3972bd98fbec1c2ab9453a33790636a632e7be65
Parent:        c6f2821b9fb74bec2de29a878e71fc64a70d11bb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 22 18:29:38 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 14 23:19:20 2012 +0200

thin: add support to unmount volumes

Reset counter after thin pool resize failure.

If the pool goes above threshold, support unmounting
of all thin volumes if the lvextend fails to avoid
overfilling of the pool.
---
 WHATS_NEW_DM                                  |    1 +
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |  299 +++++++++++++++++++------
 test/shell/thin-autoumount-dmeventd.sh        |   70 ++++++
 3 files changed, 301 insertions(+), 69 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 22d4b01..342605f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.77 -
 =================================
+  Support unmount of thin volumes from pool above thin pool threshold.
   Update man page to reflect that dm UUIDs are being mangled as well.
   Apply 'dmsetup mangle' for dm UUIDs besides dm names.
   Add 'mangled_uuid' and 'unmangled_uuid' fields to dmsetup info -c -o.
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 5a408a8..a1af4c0 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -43,6 +43,152 @@ struct dso_state {
 	char cmd_str[1024];
 };
 
+
+/* TODO - move this mountinfo code into library to be reusable */
+#ifdef linux
+#  include "kdev_t.h"
+#else
+#  define MAJOR(x) major((x))
+#  define MINOR(x) minor((x))
+#  define MKDEV(x,y) makedev((x),(y))
+#endif
+
+/* Macros to make string defines */
+#define TO_STRING_EXP(A) #A
+#define TO_STRING(A) TO_STRING_EXP(A)
+
+static int _is_octal(int a)
+{
+	return (((a) & ~7) == '0');
+}
+
+/* Convert mangled mountinfo into normal ASCII string */
+static void _unmangle_mountinfo_string(const char *src, char *buf)
+{
+	if (!src)
+		return;
+
+	while (*src) {
+		if ((*src == '\\') &&
+		    _is_octal(src[1]) && _is_octal(src[2]) && _is_octal(src[3])) {
+			*buf++ = 64 * (src[1] & 7) + 8 * (src[2] & 7) + (src[3] & 7);
+			src += 4;
+		} else
+			*buf++ = *src++;
+	}
+	*buf = '\0';
+}
+
+/* Parse one line of mountinfo */
+static int _parse_mountinfo_line(const char *line, unsigned *maj, unsigned *min, char *buf)
+{
+	char root[PATH_MAX + 1];
+	char target[PATH_MAX + 1];
+
+	/* TODO: maybe detect availability of  %ms  glib support ? */
+	if (sscanf(line, "%*u %*u %u:%u %" TO_STRING(PATH_MAX)
+		   "s %" TO_STRING(PATH_MAX) "s",
+		   maj, min, root, target) < 4)
+		return 0;
+
+	_unmangle_mountinfo_string(target, buf);
+
+#if THIN_DEBUG
+	syslog(LOG_DEBUG, "Mounted  %u:%u  %s", *maj, *min, buf);
+#endif
+
+	return 1;
+}
+
+/* Get dependencies for device, and try to find matching device */
+static int _has_deps(const char *name, int tp_major, int tp_minor, int *dev_minor)
+{
+	struct dm_task *dmt;
+	const struct dm_deps *deps;
+	struct dm_info info;
+	int major, minor;
+	int r = 0;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_DEPS)))
+		return 0;
+
+	if (!dm_task_set_name(dmt, name))
+		goto out;
+
+	if (!dm_task_no_open_count(dmt))
+		goto out;
+
+	if (!dm_task_run(dmt))
+		goto out;
+
+	if (!dm_task_get_info(dmt, &info))
+		goto out;
+
+	if (!(deps = dm_task_get_deps(dmt)))
+		goto out;
+
+	if (!info.exists || deps->count != 1)
+		goto out;
+
+	major = (int) MAJOR(deps->device[0]);
+	minor = (int) MINOR(deps->device[0]);
+	if ((major != tp_major) || (minor != tp_minor))
+		goto out;
+
+	*dev_minor = info.minor;
+
+#if THIN_DEBUG
+	{
+		char dev_name[PATH_MAX];
+		if (dm_device_get_name(major, minor, 0, dev_name, sizeof(dev_name)))
+			syslog(LOG_DEBUG, "Found %s (%u:%u) depends on %s",
+			       name, major, *dev_minor, dev_name);
+	}
+#endif
+	r = 1;
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
+/* Get all active devices */
+static int _find_all_devs(dm_bitset_t bs, int tp_major, int tp_minor)
+{
+	struct dm_task *dmt;
+	struct dm_names *names;
+	unsigned next = 0;
+	int minor, r = 1;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_LIST)))
+		return 0;
+
+	if (!dm_task_run(dmt)) {
+		r = 0;
+		goto out;
+	}
+
+	if (!(names = dm_task_get_names(dmt))) {
+		r = 0;
+		goto out;
+	}
+
+	if (!names->dev)
+		goto out;
+
+	do {
+		names = (struct dm_names *)((char *) names + next);
+		if (_has_deps(names->name, tp_major, tp_minor, &minor))
+			dm_bit_set(bs, minor);
+		next = names->next;
+	} while (next);
+
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+
 static int _extend(struct dso_state *state)
 {
 #if THIN_DEBUG
@@ -51,87 +197,104 @@ static int _extend(struct dso_state *state)
 	return (dmeventd_lvm2_run(state->cmd_str) == ECMD_PROCESSED);
 }
 
-#if 0
 static int _run(const char *cmd, ...)
 {
-        va_list ap;
-        int argc = 1; /* for argv[0], i.e. cmd */
-        int i = 0;
-        const char **argv;
-        pid_t pid = fork();
-        int status;
-
-        if (pid == 0) { /* child */
-                va_start(ap, cmd);
-                while (va_arg(ap, const char *))
-                        ++argc;
-                va_end(ap);
-
-                /* + 1 for the terminating NULL */
-                argv = alloca(sizeof(const char *) * (argc + 1));
-
-                argv[0] = cmd;
+	va_list ap;
+	int argc = 1; /* for argv[0], i.e. cmd */
+	int i = 0;
+	const char **argv;
+	pid_t pid = fork();
+	int status;
+
+	if (pid == 0) { /* child */
+		va_start(ap, cmd);
+		while (va_arg(ap, const char *))
+			++argc;
+		va_end(ap);
+
+		/* + 1 for the terminating NULL */
+		argv = alloca(sizeof(const char *) * (argc + 1));
+
+		argv[0] = cmd;
                 va_start(ap, cmd);
-                while ((argv[++i] = va_arg(ap, const char *)));
-                va_end(ap);
+		while ((argv[++i] = va_arg(ap, const char *)));
+		va_end(ap);
 
-                execvp(cmd, (char **)argv);
-                syslog(LOG_ERR, "Failed to execute %s: %s.\n", cmd, strerror(errno));
-                exit(127);
-        }
+		execvp(cmd, (char **)argv);
+		syslog(LOG_ERR, "Failed to execute %s: %s.\n", cmd, strerror(errno));
+		exit(127);
+	}
 
-        if (pid > 0) { /* parent */
-                if (waitpid(pid, &status, 0) != pid)
-                        return 0; /* waitpid failed */
-                if (!WIFEXITED(status) || WEXITSTATUS(status))
-                        return 0; /* the child failed */
-        }
+	if (pid > 0) { /* parent */
+		if (waitpid(pid, &status, 0) != pid)
+			return 0; /* waitpid failed */
+		if (!WIFEXITED(status) || WEXITSTATUS(status))
+			return 0; /* the child failed */
+	}
 
-        if (pid < 0)
-                return 0; /* fork failed */
+	if (pid < 0)
+		return 0; /* fork failed */
 
-        return 1; /* all good */
+	return 1; /* all good */
 }
 
-/* FIXME: all thin pool users needs to be here */
-static void _umount(const char *device, int major, int minor)
+/*
+ * Find all thin pool users and try to umount them.
+ * TODO: work with read-only thin pool support
+ */
+static void _umount(struct dm_task *dmt, const char *device)
 {
-	FILE *mounts;
+	static const char mountinfo[] = "/proc/self/mountinfo";
+	static const size_t MINORS = 4096;
+	FILE *minfo;
 	char buffer[4096];
-	char *words[3];
-	struct stat st;
+	char target[PATH_MAX];
+	struct dm_info info;
+	unsigned maj, min;
+	dm_bitset_t minors; /* Bitset for active thin pool minors */
 
-	if (!(mounts = fopen("/proc/mounts", "r"))) {
-		syslog(LOG_ERR, "Could not read /proc/mounts. Not umounting %s.\n", device);
+	if (!dm_task_get_info(dmt, &info))
 		return;
+
+	dmeventd_lvm2_unlock();
+
+	if (!(minors = dm_bitset_create(NULL, MINORS))) {
+		syslog(LOG_ERR, "Failed to allocate bitset. Not unmounting %s.\n", device);
+		goto out;
 	}
 
-	while (!feof(mounts)) {
-		/* read a line of /proc/mounts */
-		if (!fgets(buffer, sizeof(buffer), mounts))
-			break; /* eof, likely */
+	if (!(minfo = fopen(mountinfo, "r"))) {
+		syslog(LOG_ERR, "Could not read %s. Not umounting %s.\n", mountinfo, device);
+		goto out;
+	}
 
-		/* words[0] is the mount point and words[1] is the device path */
-		dm_split_words(buffer, 3, 0, words);
+	if (!_find_all_devs(minors, info.major, info.minor)) {
+		syslog(LOG_ERR, "Failed to detect mounted volumes for %s.\n", device);
+		goto out;
+	}
 
-		/* find the major/minor of the device */
-		if (stat(words[0], &st))
-			continue; /* can't stat, skip this one */
+	while (!feof(minfo)) {
+		/* read mountinfo line */
+		if (!fgets(buffer, sizeof(buffer), minfo))
+			break; /* eof, likely */
 
-		if (S_ISBLK(st.st_mode) &&
-		    (int) major(st.st_rdev) == major &&
-		    (int) minor(st.st_rdev) == minor) {
-			syslog(LOG_ERR, "Unmounting invalid thin %s from %s.\n", device, words[1]);
-			if (!_run(UMOUNT_COMMAND, "-fl", words[1], NULL))
+		if (_parse_mountinfo_line(buffer, &maj, &min, target) &&
+		    (maj == info.major) && dm_bit(minors, min)) {
+			syslog(LOG_INFO, "Unmounting thin volume %s from %s.\n",
+			       device, target);
+			if (!_run(UMOUNT_COMMAND, "-fl", target, NULL))
 				syslog(LOG_ERR, "Failed to umount thin %s from %s: %s.\n",
-				       device, words[1], strerror(errno));
+				       device, target, strerror(errno));
 		}
 	}
 
-	if (fclose(mounts))
-		syslog(LOG_ERR, "Failed to close /proc/mounts.\n");
+	if (fclose(minfo))
+		syslog(LOG_ERR, "Failed to close %s\n", mountinfo);
+
+	dm_bitset_destroy(minors);
+out:
+	dmeventd_lvm2_lock();
 }
-#endif
 
 void process_event(struct dm_task *dmt,
 		   enum dm_event_mask event __attribute__((unused)),
@@ -162,14 +325,7 @@ void process_event(struct dm_task *dmt,
 
 	if (!dm_get_status_thin_pool(state->mem, params, &tps)) {
 		syslog(LOG_ERR, "Failed to parse status.\n");
-#if 0
-		/* FIXME hmm what we should do? */
-		struct dm_info info;
-		if (dm_task_get_info(dmt, &info)) {
-			dmeventd_lvm2_unlock();
-			_umount(device, info.major, info.minor);
-		} /* else; too bad, but this is best-effort thing... */
-#endif
+		_umount(dmt, device);
 		goto out;
 	}
 
@@ -204,9 +360,11 @@ void process_event(struct dm_task *dmt,
 			syslog(LOG_WARNING, "Thin metadata %s is now %i%% full.\n",
 			       device, percent);
 		 /* Try to extend the metadata, in accord with user-set policies */
-		if (!_extend(state))
+		if (!_extend(state)) {
 			syslog(LOG_ERR, "Failed to extend thin metadata %s.\n",
 			       device);
+			_umount(dmt, device);
+		}
 		/* FIXME: hmm READ-ONLY switch should happen in error path */
 	}
 
@@ -221,8 +379,11 @@ void process_event(struct dm_task *dmt,
 		if (percent >= WARNING_THRESH) /* Print a warning to syslog. */
 			syslog(LOG_WARNING, "Thin %s is now %i%% full.\n", device, percent);
 		/* Try to extend the thin data, in accord with user-set policies */
-		if (!_extend(state))
+		if (!_extend(state)) {
 			syslog(LOG_ERR, "Failed to extend thin %s.\n", device);
+			state->data_percent_check = 0;
+			_umount(dmt, device);
+		}
 		/* FIXME: hmm READ-ONLY switch should happen in error path */
 	}
 out:
diff --git a/test/shell/thin-autoumount-dmeventd.sh b/test/shell/thin-autoumount-dmeventd.sh
new file mode 100644
index 0000000..bbffe8a
--- /dev/null
+++ b/test/shell/thin-autoumount-dmeventd.sh
@@ -0,0 +1,70 @@
+#!/bin/bash
+# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# no automatic extensions, just umount
+
+is_dir_mounted_()
+{
+	cat /proc/mounts | sed 's:\\040: :g' | grep "$1"
+}
+
+. lib/test
+
+#
+# Main
+#
+which mkfs.ext2 || skip
+
+aux have_thin 1 0 0 || skip
+
+aux prepare_dmeventd
+
+aux lvmconf "activation/thin_pool_autoextend_percent = 0" \
+            "activation/thin_pool_autoextend_threshold = 70"
+
+aux prepare_vg 2
+
+mntdir="${PREFIX}mnt with space"
+mntusedir="${PREFIX}mntuse"
+
+lvcreate -L8M -V8M -n $lv1 -T $vg/pool
+lvcreate -V8M -n $lv2 -T $vg/pool
+
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv1"
+mkfs.ext2 "$DM_DEV_DIR/$vg/$lv2"
+
+lvchange --monitor y $vg/pool
+
+mkdir "$mntdir" "$mntusedir"
+mount "$DM_DEV_DIR/mapper/$vg-$lv1" "$mntdir"
+mount "$DM_DEV_DIR/mapper/$vg-$lv2" "$mntusedir"
+
+is_dir_mounted_ "$mntdir"
+
+# fill above 70%
+dd if=/dev/zero of="$mntdir/file$$" bs=1M count=6
+touch "$mntusedir/file$$"
+tail -f "$mntusedir/file$$" &
+PID_TAIL=$!
+sync
+lvs -a $vg
+sleep 12 # dmeventd only checks every 10 seconds :(
+
+lvs -a $vg
+# both dirs should be unmounted
+not is_dir_mounted "$mntdir"
+not is_dir_mounted "$mntusedir"
+
+# running tail keeps the block device still in use
+kill $PID_TAIL
+lvs -a $vg
+
+vgremove -f $vg


