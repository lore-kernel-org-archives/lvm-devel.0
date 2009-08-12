From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 12 Aug 2009 23:50:43 +0100
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <20090812223551.GQ7033@agk-dp.fab.redhat.com>
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
	<20090812223551.GQ7033@agk-dp.fab.redhat.com>
Message-ID: <20090812225043.GR7033@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Updated version of the second patch.
Handing back over to you for further cleanup, review & testing.

Alasdair

-------------- next part --------------
--- file_locking_cleanup.c	2009-08-12 21:14:10.000000000 +0100
+++ file_locking_new_edited.c	2009-08-12 23:43:51.000000000 +0100
@@ -38,6 +38,7 @@ struct lock_list {
 
 static struct dm_list _lock_list;
 static char _lock_dir[NAME_LEN];
+static int _prioritise_write_locks;
 
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
+	if (!_prioritise_write_locks)
+		r = _do_flock(file, &ll->lf, operation, nonblock);
+	else {
+		if (flags & LCK_WRITE) {
+			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, 0))) {
+				r = _do_flock(file, &ll->lf, operation, nonblock);
+				_undo_flock(file_aux, fd_aux);
+			}
+		} else {
+			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, 0))) {
+				_undo_flock(file_aux, fd_aux);
+				r = _do_flock(file, &ll->lf, operation, nonblock);
+			}
+		}
+	}
+
 	if (r)
 		dm_list_add(&_lock_list, &ll->list);
 	else {
@@ -299,6 +323,10 @@ int init_file_locking(struct locking_typ
 						DEFAULT_LOCK_DIR),
 		sizeof(_lock_dir));
 
+	_prioritise_write_locks =
+	    find_config_tree_bool(cmd, "global/prioritise_write_locks",
+				  DEFAULT_PRIORITISE_WRITE_LOCKS);
+
 	if (!dm_create_dir(_lock_dir))
 		return 0;
 
