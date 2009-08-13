From: Milan Broz <mbroz@redhat.com>
Date: Thu, 13 Aug 2009 12:02:29 +0200
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <20090812225043.GR7033@agk-dp.fab.redhat.com>
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>	<20090812223551.GQ7033@agk-dp.fab.redhat.com>
	<20090812225043.GR7033@agk-dp.fab.redhat.com>
Message-ID: <4A83E4B5.4020808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

And I do not see reason why do aux lock name exercise when write priority is not used,
see patch (on top of Alasdair's change).
Milan


--- file_locking.c.old	2009-08-13 11:09:26.000000000 +0200
+++ file_locking.c	2009-08-13 11:54:37.000000000 +0200
@@ -170,15 +170,9 @@ static int _do_flock(const char *file, i
 	return_0; // AGK FIXME Note this bug fix in WHATS_NEW.
 }
 
-static int _lock_file(const char *file, uint32_t flags)
+static int _do_write_priority_flock(const char *file, int *fd, int operation, uint32_t nonblock)
 {
-	int operation;
-	int fd_aux = -1;
-	uint32_t nonblock = flags & LCK_NONBLOCK;
-	int r;
-
-	struct lock_list *ll;
-	char state;
+	int r, fd_aux = -1;
 	char *file_aux = alloca(strlen(file) + 5);
 
 	strcpy(file_aux, file);
@@ -187,6 +181,28 @@ static int _lock_file(const char *file, 
 	strcat(file_aux, "aux_");
 	strcat(file_aux, strrchr(file, '/') + 1);
 
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
+static int _lock_file(const char *file, uint32_t flags)
+{
+	int operation;
+	uint32_t nonblock = flags & LCK_NONBLOCK;
+	int r;
+
+	struct lock_list *ll;
+	char state;
+
 	switch (flags & LCK_TYPE_MASK) {
 	case LCK_READ:
 		operation = LOCK_SH;
@@ -216,21 +232,10 @@ static int _lock_file(const char *file, 
 	log_very_verbose("Locking %s %c%c", ll->res, state,
 			 nonblock ? ' ' : 'B');
 
-	if (!_prioritise_write_locks)
+	if (_prioritise_write_locks)
+		r = _do_write_priority_flock(file, &ll->lf, operation, nonblock);
+	else 
 		r = _do_flock(file, &ll->lf, operation, nonblock);
-	else {
-		if (flags & LCK_WRITE) {
-			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, 0))) {
-				r = _do_flock(file, &ll->lf, operation, nonblock);
-				_undo_flock(file_aux, fd_aux);
-			}
-		} else {
-			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, 0))) {
-				_undo_flock(file_aux, fd_aux);
-				r = _do_flock(file, &ll->lf, operation, nonblock);
-			}
-		}
-	}
 
 	if (r)
 		dm_list_add(&_lock_list, &ll->list);



