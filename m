From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 2 Sep 2009 14:47:41 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/config/d ...
Message-ID: <20090902144741.24550.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-09-02 14:47:40

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/config     : defaults.h 
	lib/locking    : file_locking.c 

Log message:
	Implement write lock prioritisation for file locking and make it default.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1251&r2=1.1252
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43

--- LVM2/WHATS_NEW	2009/09/02 11:49:03	1.1251
+++ LVM2/WHATS_NEW	2009/09/02 14:47:39	1.1252
@@ -1,5 +1,6 @@
 Version 2.02.52 -
 =================================
+  Implement write lock prioritisation for file locking and make it default.
   Fix clogd build direcory.
   Drop unrequired clogd Makefile.
   Fix clvmd autodetection check and cleanup related configure messages.
--- LVM2/doc/example.conf	2009/08/04 15:36:14	1.45
+++ LVM2/doc/example.conf	2009/09/02 14:47:40	1.46
@@ -288,6 +288,13 @@
     # in progress.  A directory like /tmp that may get wiped on reboot is OK.
     locking_dir = "/var/lock/lvm"
 
+    # Whenever a read-only and read-write access compete on a single volume
+    # group, ensure that the write lock gets priority over the read lock.
+    # Without this setting, write access may be stalled by high volume of
+    # read-only traffic on LVM metadata. NB. This option only affects
+    # locking_type = 1, i.e. local file-based locking.
+    prioritise_write_locks = 1
+
     # Other entries can go here to allow you to load shared libraries
     # e.g. if support for LVM1 metadata was compiled as a shared library use
     #   format_libraries = "liblvm2format1.so" 
--- LVM2/lib/config/defaults.h	2009/08/04 15:36:14	1.50
+++ LVM2/lib/config/defaults.h	2009/09/02 14:47:40	1.51
@@ -42,6 +42,7 @@
 #define DEFAULT_FALLBACK_TO_LOCAL_LOCKING 1
 #define DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING 1
 #define DEFAULT_WAIT_FOR_LOCKS 1
+#define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
--- LVM2/lib/locking/file_locking.c	2009/08/13 13:23:52	1.42
+++ LVM2/lib/locking/file_locking.c	2009/09/02 14:47:40	1.43
@@ -38,6 +38,7 @@
 
 static struct dm_list _lock_list;
 static char _lock_dir[NAME_LEN];
+static int _prioritise_write_locks;
 
 static sig_t _oldhandler;
 static sigset_t _fullsigset, _intsigset;
@@ -47,6 +48,7 @@
 {
 	struct stat buf1, buf2;
 
+	log_debug("_undo_flock %s", file);
 	if (!flock(fd, LOCK_NB | LOCK_EX) &&
 	    !stat(file, &buf1) &&
 	    !fstat(fd, &buf2) &&
@@ -135,6 +137,8 @@
 	int old_errno;
 	struct stat buf1, buf2;
 
+	log_debug("_do_flock %s %c%c",
+		  file, operation == LOCK_EX ? 'W' : 'R', nonblock ? ' ' : 'B');
 	do {
 		if ((*fd > -1) && close(*fd))
 			log_sys_error("close", file);
@@ -169,6 +173,29 @@
 	return_0;
 }
 
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
 static int _lock_file(const char *file, uint32_t flags)
 {
 	int operation;
@@ -207,7 +234,11 @@
 	log_very_verbose("Locking %s %c%c", ll->res, state,
 			 nonblock ? ' ' : 'B');
 
-	r = _do_flock(file, &ll->lf, operation, nonblock);
+	if (_prioritise_write_locks)
+		r = _do_write_priority_flock(file, &ll->lf, operation, nonblock);
+	else 
+		r = _do_flock(file, &ll->lf, operation, nonblock);
+
 	if (r)
 		dm_list_add(&_lock_list, &ll->list);
 	else {
@@ -299,6 +330,10 @@
 						DEFAULT_LOCK_DIR),
 		sizeof(_lock_dir));
 
+	_prioritise_write_locks =
+	    find_config_tree_bool(cmd, "global/prioritise_write_locks",
+				  DEFAULT_PRIORITISE_WRITE_LOCKS);
+
 	if (!dm_create_dir(_lock_dir))
 		return 0;
 


