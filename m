From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 13 Aug 2009 13:23:52 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/file_locking.c
Message-ID: <20090813132352.4800.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-08-13 13:23:52

Modified files:
	.              : WHATS_NEW 
	lib/locking    : file_locking.c 

Log message:
	Refactor file locking, lifting the flock wrapper code into separate
	functions. Also fixes a bug, where a nonblocking lock could, in certain race
	situations, succeed without actually obtaining the lock.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1237&r2=1.1238
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2009/08/13 12:19:30	1.1237
+++ LVM2/WHATS_NEW	2009/08/13 13:23:51	1.1238
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Fix bug where non-blocking file locks could be granted in error.
   Make lvm2app pv_t, lv_t, vg_t handle definitions consistent with lvm_t.
   Fix vgextend error path - if ORPHAN lock fails, unlock / release vg (2.02.49).
   Fix compile warning in clvmd.
--- LVM2/lib/locking/file_locking.c	2008/11/12 09:30:52	1.41
+++ LVM2/lib/locking/file_locking.c	2009/08/13 13:23:52	1.42
@@ -43,13 +43,26 @@
 static sigset_t _fullsigset, _intsigset;
 static volatile sig_atomic_t _handler_installed;
 
+static void _undo_flock(const char *file, int fd)
+{
+	struct stat buf1, buf2;
+
+	if (!flock(fd, LOCK_NB | LOCK_EX) &&
+	    !stat(file, &buf1) &&
+	    !fstat(fd, &buf2) &&
+	    is_same_inode(buf1, buf2))
+		if (unlink(file))
+			log_sys_error("unlink", file);
+
+	if (close(fd) < 0)
+		log_sys_error("close", file);
+}
+
 static int _release_lock(const char *file, int unlock)
 {
 	struct lock_list *ll;
 	struct dm_list *llh, *llt;
 
-	struct stat buf1, buf2;
-
 	dm_list_iterate_safe(llh, llt, &_lock_list) {
 		ll = dm_list_item(llh, struct lock_list);
 
@@ -61,15 +74,7 @@
 					log_sys_error("flock", ll->res);
 			}
 
-			if (!flock(ll->lf, LOCK_NB | LOCK_EX) &&
-			    !stat(ll->res, &buf1) &&
-			    !fstat(ll->lf, &buf2) &&
-			    is_same_inode(buf1, buf2))
-				if (unlink(ll->res))
-					log_sys_error("unlink", ll->res);
-
-			if (close(ll->lf) < 0)
-				log_sys_error("close", ll->res);
+			_undo_flock(ll->res, ll->lf);
 
 			dm_free(ll->res);
 			dm_free(llh);
@@ -124,14 +129,53 @@
 	siginterrupt(SIGINT, 1);
 }
 
-static int _lock_file(const char *file, uint32_t flags)
+static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock)
 {
-	int operation;
 	int r = 1;
 	int old_errno;
+	struct stat buf1, buf2;
+
+	do {
+		if ((*fd > -1) && close(*fd))
+			log_sys_error("close", file);
+
+		if ((*fd = open(file, O_CREAT | O_APPEND | O_RDWR, 0777)) < 0) {
+			log_sys_error("open", file);
+			return 0;
+		}
+
+		if (nonblock)
+			operation |= LOCK_NB;
+		else
+			_install_ctrl_c_handler();
+
+		r = flock(*fd, operation);
+		old_errno = errno;
+		if (!nonblock)
+			_remove_ctrl_c_handler();
+
+		if (r) {
+			errno = old_errno;
+			log_sys_error("flock", file);
+			close(*fd);
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
+static int _lock_file(const char *file, uint32_t flags)
+{
+	int operation;
+	uint32_t nonblock = flags & LCK_NONBLOCK;
+	int r;
 
 	struct lock_list *ll;
-	struct stat buf1, buf2;
 	char state;
 
 	switch (flags & LCK_TYPE_MASK) {
@@ -151,56 +195,28 @@
 	}
 
 	if (!(ll = dm_malloc(sizeof(struct lock_list))))
-		return 0;
+		return_0;
 
 	if (!(ll->res = dm_strdup(file))) {
 		dm_free(ll);
-		return 0;
+		return_0;
 	}
 
 	ll->lf = -1;
 
 	log_very_verbose("Locking %s %c%c", ll->res, state,
-			 flags & LCK_NONBLOCK ? ' ' : 'B');
-	do {
-		if ((ll->lf > -1) && close(ll->lf))
-			log_sys_error("close", file);
-
-		if ((ll->lf = open(file, O_CREAT | O_APPEND | O_RDWR, 0777))
-		    < 0) {
-			log_sys_error("open", file);
-			goto err;
-		}
+			 nonblock ? ' ' : 'B');
 
-		if ((flags & LCK_NONBLOCK))
-			operation |= LOCK_NB;
-		else
-			_install_ctrl_c_handler();
-
-		r = flock(ll->lf, operation);
-		old_errno = errno;
-		if (!(flags & LCK_NONBLOCK))
-			_remove_ctrl_c_handler();
-
-		if (r) {
-			errno = old_errno;
-			log_sys_error("flock", ll->res);
-			close(ll->lf);
-			goto err;
-		}
-
-		if (!stat(ll->res, &buf1) && !fstat(ll->lf, &buf2) &&
-		    is_same_inode(buf1, buf2))
-			break;
-	} while (!(flags & LCK_NONBLOCK));
-
-	dm_list_add(&_lock_list, &ll->list);
-	return 1;
+	r = _do_flock(file, &ll->lf, operation, nonblock);
+	if (r)
+		dm_list_add(&_lock_list, &ll->list);
+	else {
+		dm_free(ll->res);
+		dm_free(ll);
+		stack;
+	}
 
-      err:
-	dm_free(ll->res);
-	dm_free(ll);
-	return 0;
+	return r;
 }
 
 static int _file_lock_resource(struct cmd_context *cmd, const char *resource,


