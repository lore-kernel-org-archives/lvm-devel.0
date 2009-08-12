From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 12 Aug 2009 21:29:43 +0100
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <87skfxtr89.fsf@twilight.int.mornfall.net.>
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
Message-ID: <20090812202943.GP7033@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Aug 12, 2009 at 09:40:22AM +0200, Peter Rockai wrote:
> I am attaching a draft version of the write lock priority patch. Other than
> running the testsuite, it is completely untested. I am running away for about
> an hour now, I'll read it through again when I'm back and see what can be done
> about testing, too.
 
I have split the changes to file_locking.c into two patches to aid reviewability
and attached them (out of tree context, sorry).

The first does the refactoring (reviewed).

The second adds the new functionality (not reviewed yet, but now only 60-odd lines).

Changes I made include:
  Using _do_flock() and _undo_flock().  (Underscore plus existing library fn
name is not a good idea.)
  Dropping the implicit cast from uint32_t to int for nonblock.
  Adding some stacks (missing from existing code).
  
> +		if (!stat(file, &buf1) && !fstat(*fd, &buf2) &&
> +		    is_same_inode(buf1, buf2))
> +			return 1;
> +	} while (!nonblock);
> +	return 0;

That 'return 0' looks like a bug fix - previously I think it did the equivalent
of 'return 1' which seems wrong.

Please revalidate the first patch after my changes and commit it if it seems
OK (minus my FIXME line).

Alasdair

-------------- next part --------------
--- file_locking_orig.c	2009-08-12 19:47:46.000000000 +0100
+++ file_locking.c	2009-08-12 21:14:10.000000000 +0100
@@ -43,13 +43,26 @@ static sig_t _oldhandler;
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
 
@@ -61,15 +74,7 @@ static int _release_lock(const char *fil
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
@@ -124,14 +129,53 @@ static void _install_ctrl_c_handler()
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
+	return_0; // AGK FIXME Note this bug fix in WHATS_NEW.
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
@@ -151,56 +195,28 @@ static int _lock_file(const char *file, 
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
-------------- next part --------------
--- file_locking.c	2009-08-12 21:14:10.000000000 +0100
+++ file_locking_new_edited.c	2009-08-12 21:14:05.000000000 +0100
@@ -38,6 +38,7 @@ struct lock_list {
 
 static struct dm_list _lock_list;
 static char _lock_dir[NAME_LEN];
+static int _write_priority;
 
 static sig_t _oldhandler;
 static sigset_t _fullsigset, _intsigset;
@@ -172,11 +173,19 @@ static int _do_flock(const char *file, i
 static int _lock_file(const char *file, uint32_t flags)
 {
 	int operation;
+	int fd_aux = -1;
 	uint32_t nonblock = flags & LCK_NONBLOCK;
 	int r;
 
 	struct lock_list *ll;
 	char state;
+	char *file_aux = alloca(strlen(file) + 5);
+
+	strcpy(file_aux, file);
+	/* There is always a slash before the basename part of the filename. */
+	*(strrchr(file_aux, '/') + 1) = 0;
+	strcat(file_aux, "aux_");
+	strcat(file_aux, strrchr(file, '/') + 1);
 
 	switch (flags & LCK_TYPE_MASK) {
 	case LCK_READ:
@@ -207,7 +216,22 @@ static int _lock_file(const char *file, 
 	log_very_verbose("Locking %s %c%c", ll->res, state,
 			 nonblock ? ' ' : 'B');
 
-	r = _do_flock(file, &ll->lf, operation, nonblock);
+	if (!_write_priority) {
+		r = _do_flock(file, &ll->lf, operation, nonblock);
+	else {
+		if (flags & LCK_WRITE) {
+			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, nonblock))) {
+				r = _do_flock(file, &ll->lf, operation, nonblock);
+				_unflock(file_aux, fd_aux);
+			}
+		} else {
+			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, nonblock))) {
+				_unflock(file_aux, fd_aux);
+				r = _do_flock(file, &ll->lf, operation, nonblock);
+			}
+		}
+	}
+
 	if (r)
 		dm_list_add(&_lock_list, &ll->list);
 	else {
@@ -299,6 +323,9 @@ int init_file_locking(struct locking_typ
 						DEFAULT_LOCK_DIR),
 		sizeof(_lock_dir));
 
+	_write_priority = find_config_tree_bool(cmd, "global/write_lock_priority",
+						DEFAULT_WRITE_LOCK_PRIORITY);
+
 	if (!dm_create_dir(_lock_dir))
 		return 0;
 
