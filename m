From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:07 +0000 (UTC)
Subject: dev-prajnoha-selout - locking: Separate out flock and signal code.
Message-ID: <20140509065607.CCF2360774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=29a3fbf067e1685ae7e202959a414e4b13f547c7
Commit:        29a3fbf067e1685ae7e202959a414e4b13f547c7
Parent:        239ba5bb04deccee83aa603efee11a9670f6f3fe
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 1 17:37:14 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 1 17:37:14 2014 +0100

locking: Separate out flock and signal code.

---
 include/.symlinks.in       |    6 +-
 lib/Makefile.in            |    2 +
 lib/locking/file_locking.c |  231 +------------------------------------------
 lib/misc/lvm-flock.c       |  223 ++++++++++++++++++++++++++++++++++++++++++
 lib/misc/lvm-flock.h       |   22 ++++
 lib/misc/lvm-signal.c      |   56 +++++++++++
 lib/misc/lvm-signal.h      |   20 ++++
 7 files changed, 333 insertions(+), 227 deletions(-)

diff --git a/include/.symlinks.in b/include/.symlinks.in
index 44076c8..ced2cb3 100644
--- a/include/.symlinks.in
+++ b/include/.symlinks.in
@@ -42,17 +42,19 @@
 @top_builddir@/lib/misc/configure.h
 @top_srcdir@/lib/misc/crc.h
 @top_srcdir@/lib/misc/intl.h
- at top_srcdir@/lib/misc/util.h
 @top_srcdir@/lib/misc/last-path-component.h
 @top_srcdir@/lib/misc/lib.h
 @top_srcdir@/lib/misc/lvm-exec.h
 @top_srcdir@/lib/misc/lvm-file.h
+ at top_srcdir@/lib/misc/lvm-flock.h
 @top_srcdir@/lib/misc/lvm-globals.h
+ at top_srcdir@/lib/misc/lvm-signal.h
 @top_srcdir@/lib/misc/lvm-string.h
 @top_builddir@/lib/misc/lvm-version.h
- at top_srcdir@/lib/misc/lvm-wrappers.h
 @top_srcdir@/lib/misc/lvm-percent.h
+ at top_srcdir@/lib/misc/lvm-wrappers.h
 @top_srcdir@/lib/misc/sharedlib.h
+ at top_srcdir@/lib/misc/util.h
 @top_srcdir@/lib/properties/prop_common.h
 @top_srcdir@/lib/report/properties.h
 @top_srcdir@/lib/report/report.h
diff --git a/lib/Makefile.in b/lib/Makefile.in
index c3d4598..9f101f3 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -106,7 +106,9 @@ SOURCES =\
 	misc/crc.c \
 	misc/lvm-exec.c \
 	misc/lvm-file.c \
+	misc/lvm-flock.c \
 	misc/lvm-globals.c \
+	misc/lvm-signal.c \
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
 	misc/lvm-percent.c \
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 734e0b4..2f6716d 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -21,6 +21,7 @@
 #include "defaults.h"
 #include "lvm-file.h"
 #include "lvm-string.h"
+#include "lvm-flock.h"
 #include "lvmcache.h"
 
 #include <limits.h>
@@ -30,237 +31,20 @@
 #include <fcntl.h>
 #include <signal.h>
 
-struct lock_list {
-	struct dm_list list;
-	int lf;
-	char *res;
-};
-
-static struct dm_list _lock_list;
 static char _lock_dir[PATH_MAX];
-static int _prioritise_write_locks;
 
 static sig_t _oldhandler;
 static sigset_t _fullsigset, _intsigset;
 static volatile sig_atomic_t _handler_installed;
 
-/* Drop lock known to be shared with another file descriptor. */
-static void _drop_shared_flock(const char *file, int fd)
-{
-	log_debug_locking("_drop_shared_flock %s.", file);
-
-	if (close(fd) < 0)
-		log_sys_debug("close", file);
-}
-
-static void _undo_flock(const char *file, int fd)
-{
-	struct stat buf1, buf2;
-
-	log_debug_locking("_undo_flock %s", file);
-	if (!flock(fd, LOCK_NB | LOCK_EX) &&
-	    !stat(file, &buf1) &&
-	    !fstat(fd, &buf2) &&
-	    is_same_inode(buf1, buf2))
-		if (unlink(file))
-			log_sys_debug("unlink", file);
-
-	if (close(fd) < 0)
-		log_sys_debug("close", file);
-}
-
-static int _release_lock(const char *file, int unlock)
-{
-	struct lock_list *ll;
-	struct dm_list *llh, *llt;
-
-	dm_list_iterate_safe(llh, llt, &_lock_list) {
-		ll = dm_list_item(llh, struct lock_list);
-
-		if (!file || !strcmp(ll->res, file)) {
-			dm_list_del(llh);
-			if (unlock) {
-				log_very_verbose("Unlocking %s", ll->res);
-				if (flock(ll->lf, LOCK_NB | LOCK_UN))
-					log_sys_debug("flock", ll->res);
-				_undo_flock(ll->res, ll->lf);
-			} else
-				_drop_shared_flock(ll->res, ll->lf);
-
-			dm_free(ll->res);
-			dm_free(llh);
-
-			if (file)
-				return 1;
-		}
-	}
-
-	return 0;
-}
-
 static void _fin_file_locking(void)
 {
-	_release_lock(NULL, 1);
+	release_flocks(1);
 }
 
 static void _reset_file_locking(void)
 {
-	_release_lock(NULL, 0);
-}
-
-static void _remove_ctrl_c_handler(void)
-{
-	siginterrupt(SIGINT, 0);
-	if (!_handler_installed)
-		return;
-
-	_handler_installed = 0;
-
-	sigprocmask(SIG_SETMASK, &_fullsigset, NULL);
-	if (signal(SIGINT, _oldhandler) == SIG_ERR)
-		log_sys_error("signal", "_remove_ctrl_c_handler");
-}
-
-static void _trap_ctrl_c(int sig __attribute__((unused)))
-{
-	_remove_ctrl_c_handler();
-	log_error("CTRL-c detected: giving up waiting for lock");
-}
-
-static void _install_ctrl_c_handler(void)
-{
-	_handler_installed = 1;
-
-	if ((_oldhandler = signal(SIGINT, _trap_ctrl_c)) == SIG_ERR) {
-		_handler_installed = 0;
-		return;
-	}
-
-	sigprocmask(SIG_SETMASK, &_intsigset, NULL);
-	siginterrupt(SIGINT, 1);
-}
-
-static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock)
-{
-	int r = 1;
-	int old_errno;
-	struct stat buf1, buf2;
-
-	log_debug_locking("_do_flock %s %c%c", file,
-			  operation == LOCK_EX ? 'W' : 'R', nonblock ? ' ' : 'B');
-	do {
-		if ((*fd > -1) && close(*fd))
-			log_sys_debug("close", file);
-
-		if ((*fd = open(file, O_CREAT | O_APPEND | O_RDWR, 0777)) < 0) {
-			log_sys_error("open", file);
-			return 0;
-		}
-
-		if (nonblock)
-			operation |= LOCK_NB;
-		else
-			_install_ctrl_c_handler();
-
-		r = flock(*fd, operation);
-		old_errno = errno;
-		if (!nonblock)
-			_remove_ctrl_c_handler();
-
-		if (r) {
-			errno = old_errno;
-			log_sys_error("flock", file);
-			if (close(*fd))
-				log_sys_debug("close", file);
-			*fd = -1;
-			return 0;
-		}
-
-		if (!stat(file, &buf1) && !fstat(*fd, &buf2) &&
-		    is_same_inode(buf1, buf2))
-			return 1;
-	} while (!nonblock);
-
-	return_0;
-}
-
-#define AUX_LOCK_SUFFIX ":aux"
-
-static int _do_write_priority_flock(const char *file, int *fd, int operation, uint32_t nonblock)
-{
-	int r, fd_aux = -1;
-	char *file_aux = alloca(strlen(file) + sizeof(AUX_LOCK_SUFFIX));
-
-	strcpy(file_aux, file);
-	strcat(file_aux, AUX_LOCK_SUFFIX);
-
-	if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, 0))) {
-		if (operation == LOCK_EX) {
-			r = _do_flock(file, fd, operation, nonblock);
-			_undo_flock(file_aux, fd_aux);
-		} else {
-			_undo_flock(file_aux, fd_aux);
-			r = _do_flock(file, fd, operation, nonblock);
-		}
-	}
-
-	return r;
-}
-
-static int _lock_file(const char *file, uint32_t flags)
-{
-	int operation;
-	uint32_t nonblock = flags & LCK_NONBLOCK;
-	int r;
-
-	struct lock_list *ll;
-	char state;
-
-	switch (flags & LCK_TYPE_MASK) {
-	case LCK_READ:
-		operation = LOCK_SH;
-		state = 'R';
-		break;
-	case LCK_WRITE:
-		operation = LOCK_EX;
-		state = 'W';
-		break;
-	case LCK_UNLOCK:
-		return _release_lock(file, 1);
-	default:
-		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
-		return 0;
-	}
-
-	if (!(ll = dm_malloc(sizeof(struct lock_list))))
-		return_0;
-
-	if (!(ll->res = dm_strdup(file))) {
-		dm_free(ll);
-		return_0;
-	}
-
-	ll->lf = -1;
-
-	log_very_verbose("Locking %s %c%c", ll->res, state,
-			 nonblock ? ' ' : 'B');
-
-	(void) dm_prepare_selinux_context(file, S_IFREG);
-	if (_prioritise_write_locks)
-		r = _do_write_priority_flock(file, &ll->lf, operation, nonblock);
-	else 
-		r = _do_flock(file, &ll->lf, operation, nonblock);
-	(void) dm_prepare_selinux_context(NULL, 0);
-
-	if (r)
-		dm_list_add(&_lock_list, &ll->list);
-	else {
-		dm_free(ll->res);
-		dm_free(ll);
-		stack;
-	}
-
-	return r;
+	release_flocks(0);
 }
 
 static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
@@ -298,7 +82,7 @@ static int _file_lock_resource(struct cmd_context *cmd, const char *resource,
 				return 0;
 			}
 
-		if (!_lock_file(lockfile, flags))
+		if (!lock_file(lockfile, flags))
 			return_0;
 		break;
 	case LCK_LV:
@@ -352,6 +136,8 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	int r;
 	const char *locking_dir;
 
+	init_flock(cmd);
+
 	locking->lock_resource = _file_lock_resource;
 	locking->reset_locking = _reset_file_locking;
 	locking->fin_locking = _fin_file_locking;
@@ -366,9 +152,6 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 
 	strcpy(_lock_dir, locking_dir);
 
-	_prioritise_write_locks =
-	    find_config_tree_bool(cmd, global_prioritise_write_locks_CFG, NULL);
-
 	(void) dm_prepare_selinux_context(_lock_dir, S_IFDIR);
 	r = dm_create_dir(_lock_dir);
 	(void) dm_prepare_selinux_context(NULL, 0);
@@ -380,8 +163,6 @@ int init_file_locking(struct locking_type *locking, struct cmd_context *cmd,
 	if ((access(_lock_dir, R_OK | W_OK | X_OK) == -1) && (errno == EROFS))
 		return 0;
 
-	dm_list_init(&_lock_list);
-
 	if (sigfillset(&_intsigset) || sigfillset(&_fullsigset)) {
 		log_sys_error_suppress(suppress_messages, "sigfillset",
 				       "init_file_locking");
diff --git a/lib/misc/lvm-flock.c b/lib/misc/lvm-flock.c
new file mode 100644
index 0000000..ca05e1c
--- /dev/null
+++ b/lib/misc/lvm-flock.c
@@ -0,0 +1,223 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "config.h"
+#include "lvm-file.h"
+#include "lvm-flock.h"
+#include "lvm-signal.h"
+#include "locking.h"
+
+#include <sys/file.h>
+#include <fcntl.h>
+
+struct lock_list {
+	struct dm_list list;
+	int lf;
+	char *res;
+};
+
+static struct dm_list _lock_list;
+static int _prioritise_write_locks;
+
+/* Drop lock known to be shared with another file descriptor. */
+static void _drop_shared_flock(const char *file, int fd)
+{
+	log_debug_locking("_drop_shared_flock %s.", file);
+
+	if (close(fd) < 0)
+		log_sys_debug("close", file);
+}
+
+static void _undo_flock(const char *file, int fd)
+{
+	struct stat buf1, buf2;
+
+	log_debug_locking("_undo_flock %s", file);
+	if (!flock(fd, LOCK_NB | LOCK_EX) &&
+	    !stat(file, &buf1) &&
+	    !fstat(fd, &buf2) &&
+	    is_same_inode(buf1, buf2))
+		if (unlink(file))
+			log_sys_debug("unlink", file);
+
+	if (close(fd) < 0)
+		log_sys_debug("close", file);
+}
+
+static int _release_lock(const char *file, int unlock)
+{
+	struct lock_list *ll;
+	struct dm_list *llh, *llt;
+
+	dm_list_iterate_safe(llh, llt, &_lock_list) {
+		ll = dm_list_item(llh, struct lock_list);
+
+		if (!file || !strcmp(ll->res, file)) {
+			dm_list_del(llh);
+			if (unlock) {
+				log_very_verbose("Unlocking %s", ll->res);
+				if (flock(ll->lf, LOCK_NB | LOCK_UN))
+					log_sys_debug("flock", ll->res);
+				_undo_flock(ll->res, ll->lf);
+			} else
+				_drop_shared_flock(ll->res, ll->lf);
+
+			dm_free(ll->res);
+			dm_free(llh);
+
+			if (file)
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+void release_flocks(int unlock)
+{
+	_release_lock(NULL, unlock);
+}
+
+static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock)
+{
+	int r = 1;
+	int old_errno;
+	struct stat buf1, buf2;
+
+	log_debug_locking("_do_flock %s %c%c", file,
+			  operation == LOCK_EX ? 'W' : 'R', nonblock ? ' ' : 'B');
+	do {
+		if ((*fd > -1) && close(*fd))
+			log_sys_debug("close", file);
+
+		if ((*fd = open(file, O_CREAT | O_APPEND | O_RDWR, 0777)) < 0) {
+			log_sys_error("open", file);
+			return 0;
+		}
+
+		if (nonblock)
+			operation |= LOCK_NB;
+		else
+			install_ctrl_c_handler();
+
+		r = flock(*fd, operation);
+		old_errno = errno;
+		if (!nonblock)
+			remove_ctrl_c_handler();
+
+		if (r) {
+			errno = old_errno;
+			log_sys_error("flock", file);
+			if (close(*fd))
+				log_sys_debug("close", file);
+			*fd = -1;
+			return 0;
+		}
+
+		if (!stat(file, &buf1) && !fstat(*fd, &buf2) &&
+		    is_same_inode(buf1, buf2))
+			return 1;
+	} while (!nonblock);
+
+	return_0;
+}
+
+#define AUX_LOCK_SUFFIX ":aux"
+
+static int _do_write_priority_flock(const char *file, int *fd, int operation, uint32_t nonblock)
+{
+	int r, fd_aux = -1;
+	char *file_aux = alloca(strlen(file) + sizeof(AUX_LOCK_SUFFIX));
+
+	strcpy(file_aux, file);
+	strcat(file_aux, AUX_LOCK_SUFFIX);
+
+	if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, 0))) {
+		if (operation == LOCK_EX) {
+			r = _do_flock(file, fd, operation, nonblock);
+			_undo_flock(file_aux, fd_aux);
+		} else {
+			_undo_flock(file_aux, fd_aux);
+			r = _do_flock(file, fd, operation, nonblock);
+		}
+	}
+
+	return r;
+}
+
+int lock_file(const char *file, uint32_t flags)
+{
+	int operation;
+	uint32_t nonblock = flags & LCK_NONBLOCK;
+	int r;
+
+	struct lock_list *ll;
+	char state;
+
+	switch (flags & LCK_TYPE_MASK) {
+	case LCK_READ:
+		operation = LOCK_SH;
+		state = 'R';
+		break;
+	case LCK_WRITE:
+		operation = LOCK_EX;
+		state = 'W';
+		break;
+	case LCK_UNLOCK:
+		return _release_lock(file, 1);
+	default:
+		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
+		return 0;
+	}
+
+	if (!(ll = dm_malloc(sizeof(struct lock_list))))
+		return_0;
+
+	if (!(ll->res = dm_strdup(file))) {
+		dm_free(ll);
+		return_0;
+	}
+
+	ll->lf = -1;
+
+	log_very_verbose("Locking %s %c%c", ll->res, state,
+			 nonblock ? ' ' : 'B');
+
+	(void) dm_prepare_selinux_context(file, S_IFREG);
+	if (_prioritise_write_locks)
+		r = _do_write_priority_flock(file, &ll->lf, operation, nonblock);
+	else 
+		r = _do_flock(file, &ll->lf, operation, nonblock);
+	(void) dm_prepare_selinux_context(NULL, 0);
+
+	if (r)
+		dm_list_add(&_lock_list, &ll->list);
+	else {
+		dm_free(ll->res);
+		dm_free(ll);
+		stack;
+	}
+
+	return r;
+}
+
+void init_flock(struct cmd_context *cmd)
+{
+	dm_list_init(&_lock_list);
+
+	_prioritise_write_locks =
+	    find_config_tree_bool(cmd, global_prioritise_write_locks_CFG, NULL);
+}
diff --git a/lib/misc/lvm-flock.h b/lib/misc/lvm-flock.h
new file mode 100644
index 0000000..5e8aefd
--- /dev/null
+++ b/lib/misc/lvm-flock.h
@@ -0,0 +1,22 @@
+/*
+ * Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_SIGNAL_H
+#  define _LVM_SIGNAL_H
+
+void init_flock(struct cmd_context *cmd);
+int lock_file(const char *file, uint32_t flags);
+void release_flocks(int unlock);
+
+#endif /* _LVM_SIGNAL_H */
diff --git a/lib/misc/lvm-signal.c b/lib/misc/lvm-signal.c
new file mode 100644
index 0000000..927e839
--- /dev/null
+++ b/lib/misc/lvm-signal.c
@@ -0,0 +1,56 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "lib.h"
+#include "lvm-signal.h"
+
+#include <signal.h>
+
+static sig_t _oldhandler;
+static sigset_t _fullsigset, _intsigset;
+static volatile sig_atomic_t _handler_installed;
+
+void remove_ctrl_c_handler(void)
+{
+	siginterrupt(SIGINT, 0);
+	if (!_handler_installed)
+		return;
+
+	_handler_installed = 0;
+
+	sigprocmask(SIG_SETMASK, &_fullsigset, NULL);
+	if (signal(SIGINT, _oldhandler) == SIG_ERR)
+		log_sys_error("signal", "_remove_ctrl_c_handler");
+}
+
+static void _trap_ctrl_c(int sig __attribute__((unused)))
+{
+	remove_ctrl_c_handler();
+
+	log_error("CTRL-c detected: giving up waiting for lock");
+}
+
+void install_ctrl_c_handler(void)
+{
+	_handler_installed = 1;
+
+	if ((_oldhandler = signal(SIGINT, _trap_ctrl_c)) == SIG_ERR) {
+		_handler_installed = 0;
+		return;
+	}
+
+	sigprocmask(SIG_SETMASK, &_intsigset, NULL);
+	siginterrupt(SIGINT, 1);
+}
diff --git a/lib/misc/lvm-signal.h b/lib/misc/lvm-signal.h
new file mode 100644
index 0000000..ce9d2e9
--- /dev/null
+++ b/lib/misc/lvm-signal.h
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2014 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_SIGNAL_H
+#  define _LVM_SIGNAL_H
+void remove_ctrl_c_handler(void);
+void install_ctrl_c_handler(void);
+#endif


