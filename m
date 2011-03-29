From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 20:30:10 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c daemons ...
Message-ID: <20110329203010.17350.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 20:30:09

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c lvm-functions.c 
	daemons/dmeventd: dmeventd.c 
	lib/activate   : dev_manager.c 
	lib/misc       : lvm-globals.c 

Log message:
	Fix -Wold-style-definition gcc warnings

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1958&r2=1.1959
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.77&r2=1.78
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.215&r2=1.216
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/WHATS_NEW	2011/03/24 16:03:32	1.1958
+++ LVM2/WHATS_NEW	2011/03/29 20:30:05	1.1959
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix -Wold-style-definition gcc warnings.
   Fixes for lvconvert (including --repair) of temporary mirror stacks.
   Mitigate annoying error warning from device is usable check if run as non-root.
   Add missing \0 for grown debug object in _bitset_with_random_bits().
--- LVM2/daemons/clvmd/clvmd.c	2011/03/08 22:48:50	1.100
+++ LVM2/daemons/clvmd/clvmd.c	2011/03/29 20:30:06	1.101
@@ -609,7 +609,7 @@
 
 /* Called when the GuLM cluster layer has completed initialisation.
    We send the version message */
-void clvmd_cluster_init_completed()
+void clvmd_cluster_init_completed(void)
 {
 	send_version_message();
 }
@@ -802,9 +802,10 @@
 /* This is where the real work happens */
 static void main_loop(int local_sock, int cmd_timeout)
 {
+	sigset_t ss;
+
 	DEBUGLOG("Using timeout of %d seconds\n", cmd_timeout);
 
-	sigset_t ss;
 	sigemptyset(&ss);
 	sigaddset(&ss, SIGINT);
 	sigaddset(&ss, SIGTERM);
@@ -1826,7 +1827,7 @@
 }
 
 /* Send our version number to the cluster */
-static void send_version_message()
+static void send_version_message(void)
 {
 	char message[sizeof(struct clvm_header) + sizeof(int) * 3];
 	struct clvm_header *msg = (struct clvm_header *) message;
@@ -2056,7 +2057,7 @@
 }
 
 /* Open the local socket, that's the one we talk to libclvm down */
-static int open_local_sock()
+static int open_local_sock(void)
 {
 	int local_socket = -1;
 	struct sockaddr_un sockaddr;
@@ -2218,7 +2219,7 @@
  * only called if the command-line option is not present, and if it fails
  * we still try the interfaces in order.
  */
-static if_type_t get_cluster_type()
+static if_type_t get_cluster_type(void)
 {
 #ifdef HAVE_COROSYNC_CONFDB_H
 	confdb_handle_t handle;
--- LVM2/daemons/clvmd/lvm-functions.c	2011/03/02 23:38:22	1.114
+++ LVM2/daemons/clvmd/lvm-functions.c	2011/03/29 20:30:06	1.115
@@ -147,7 +147,7 @@
 	return buf;
 }
 
-char *get_last_lvm_error()
+char *get_last_lvm_error(void)
 {
 	return last_error;
 }
@@ -194,7 +194,7 @@
 }
 
 
-void init_lvhash()
+void init_lvhash(void)
 {
 	/* Create hash table for keeping LV locks & status */
 	lv_hash = dm_hash_create(1024);
@@ -203,7 +203,7 @@
 }
 
 /* Called at shutdown to tidy the lockspace */
-void destroy_lvhash()
+void destroy_lvhash(void)
 {
 	struct dm_hash_node *v;
 	struct lv_info *lvi;
@@ -621,7 +621,7 @@
 	return status == 1 ? 0 : EBUSY;
 }
 
-int do_refresh_cache()
+int do_refresh_cache(void)
 {
 	DEBUGLOG("Refreshing context\n");
 	log_notice("Refreshing context");
--- LVM2/daemons/dmeventd/dmeventd.c	2011/03/02 14:20:48	1.77
+++ LVM2/daemons/dmeventd/dmeventd.c	2011/03/29 20:30:06	1.78
@@ -1225,6 +1225,7 @@
 static int _open_fifos(struct dm_event_fifos *fifos)
 {
 	int orig_errno;
+	struct stat st;
 
 	/* Create client fifo. */
 	(void) dm_prepare_selinux_context(fifos->client_path, S_IFIFO);
@@ -1248,8 +1249,6 @@
 
 	(void) dm_prepare_selinux_context(NULL, 0);
 
-	struct stat st;
-
 	/* Warn about wrong permissions if applicable */
 	if ((!stat(fifos->client_path, &st)) && (st.st_mode & 0777) != 0600)
 		syslog(LOG_WARNING, "Fixing wrong permissions on %s",
--- LVM2/lib/activate/dev_manager.c	2011/03/18 12:17:58	1.215
+++ LVM2/lib/activate/dev_manager.c	2011/03/29 20:30:08	1.216
@@ -1104,7 +1104,7 @@
 	char errid[32];
 	struct dm_tree_node *node;
 	struct lv_segment *seg_i;
-	int segno = -1, i = 0;;
+	int segno = -1, i = 0;
 	uint64_t size = seg->len * seg->lv->vg->extent_size;
 
 	dm_list_iterate_items(seg_i, &seg->lv->segments) {
--- LVM2/lib/misc/lvm-globals.c	2011/02/18 14:11:23	1.9
+++ LVM2/lib/misc/lvm-globals.c	2011/03/29 20:30:08	1.10
@@ -147,7 +147,7 @@
 	_sysfs_dir_path[sizeof(_sysfs_dir_path) - 1] = '\0';
 }
 
-const char *log_command_name()
+const char *log_command_name(void)
 {
 	if (!_log_cmd_name)
 		return "";
@@ -165,42 +165,42 @@
 	return _error_message_produced;
 }
 
-int test_mode()
+int test_mode(void)
 {
 	return _test;
 }
 
-int md_filtering()
+int md_filtering(void)
 {
 	return _md_filtering;
 }
 
-int pvmove_mode()
+int pvmove_mode(void)
 {
 	return _pvmove;
 }
 
-int full_scan_done()
+int full_scan_done(void)
 {
 	return _full_scan_done;
 }
 
-int trust_cache()
+int trust_cache(void)
 {
 	return _trust_cache;
 }
 
-int background_polling()
+int background_polling(void)
 {
 	return _background_polling;
 }
 
-int ignorelockingfailure()
+int ignorelockingfailure(void)
 {
 	return _ignorelockingfailure;
 }
 
-int security_level()
+int security_level(void)
 {
 	return _security_level;
 }
@@ -225,12 +225,12 @@
 	_debug_level = level;
 }
 
-int verbose_level()
+int verbose_level(void)
 {
 	return _verbose_level;
 }
 
-int debug_level()
+int debug_level(void)
 {
 	return _debug_level;
 }
@@ -245,7 +245,7 @@
 	return _udev_checking;
 }
 
-const char *sysfs_dir_path()
+const char *sysfs_dir_path(void)
 {
 	return _sysfs_dir_path;
 }


