From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 28 Mar 2011 13:59:14 +0200
Subject: [PATCH 3/6] Add void and few more warning
In-Reply-To: <cover.1301313391.git.zkabelac@redhat.com>
References: <cover.1301313391.git.zkabelac@redhat.com>
Message-ID: <b92778496a8274a8c002623d55a5337c50fe1c9a.1301313392.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix -Wold-style-definition  warning

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/clvmd/clvmd.c         |   11 ++++++-----
 daemons/clvmd/lvm-functions.c |    8 ++++----
 daemons/dmeventd/dmeventd.c   |    3 +--
 lib/activate/dev_manager.c    |    2 +-
 lib/misc/lvm-globals.c        |   24 ++++++++++++------------
 5 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/daemons/clvmd/clvmd.c b/daemons/clvmd/clvmd.c
index 361fc62..fb3cc4f 100644
--- a/daemons/clvmd/clvmd.c
+++ b/daemons/clvmd/clvmd.c
@@ -609,7 +609,7 @@ int main(int argc, char *argv[])
 
 /* Called when the GuLM cluster layer has completed initialisation.
    We send the version message */
-void clvmd_cluster_init_completed()
+void clvmd_cluster_init_completed(void)
 {
 	send_version_message();
 }
@@ -802,9 +802,10 @@ static void request_timed_out(struct local_client *client)
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
@@ -1826,7 +1827,7 @@ static void free_reply(struct local_client *client)
 }
 
 /* Send our version number to the cluster */
-static void send_version_message()
+static void send_version_message(void)
 {
 	char message[sizeof(struct clvm_header) + sizeof(int) * 3];
 	struct clvm_header *msg = (struct clvm_header *) message;
@@ -2056,7 +2057,7 @@ static void close_local_sock(int local_socket)
 }
 
 /* Open the local socket, that's the one we talk to libclvm down */
-static int open_local_sock()
+static int open_local_sock(void)
 {
 	int local_socket = -1;
 	struct sockaddr_un sockaddr;
@@ -2218,7 +2219,7 @@ static if_type_t parse_cluster_interface(char *ifname)
  * only called if the command-line option is not present, and if it fails
  * we still try the interfaces in order.
  */
-static if_type_t get_cluster_type()
+static if_type_t get_cluster_type(void)
 {
 #ifdef HAVE_COROSYNC_CONFDB_H
 	confdb_handle_t handle;
diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 3cf7c50..166cd7f 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -147,7 +147,7 @@ static const char *decode_flags(unsigned char flags)
 	return buf;
 }
 
-char *get_last_lvm_error()
+char *get_last_lvm_error(void)
 {
 	return last_error;
 }
@@ -194,7 +194,7 @@ static int get_current_lock(char *resource)
 }
 
 
-void init_lvhash()
+void init_lvhash(void)
 {
 	/* Create hash table for keeping LV locks & status */
 	lv_hash = dm_hash_create(1024);
@@ -203,7 +203,7 @@ void init_lvhash()
 }
 
 /* Called at shutdown to tidy the lockspace */
-void destroy_lvhash()
+void destroy_lvhash(void)
 {
 	struct dm_hash_node *v;
 	struct lv_info *lvi;
@@ -621,7 +621,7 @@ int do_check_lvm1(const char *vgname)
 	return status == 1 ? 0 : EBUSY;
 }
 
-int do_refresh_cache()
+int do_refresh_cache(void)
 {
 	DEBUGLOG("Refreshing context\n");
 	log_notice("Refreshing context");
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index b30c204..a64295f 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -1225,6 +1225,7 @@ static void _init_fifos(struct dm_event_fifos *fifos)
 static int _open_fifos(struct dm_event_fifos *fifos)
 {
 	int orig_errno;
+	struct stat st;
 
 	/* Create client fifo. */
 	(void) dm_prepare_selinux_context(fifos->client_path, S_IFIFO);
@@ -1248,8 +1249,6 @@ static int _open_fifos(struct dm_event_fifos *fifos)
 
 	(void) dm_prepare_selinux_context(NULL, 0);
 
-	struct stat st;
-
 	/* Warn about wrong permissions if applicable */
 	if ((!stat(fifos->client_path, &st)) && (st.st_mode & 0777) != 0600)
 		syslog(LOG_WARNING, "Fixing wrong permissions on %s",
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index cb041c6..9f4b2da 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1104,7 +1104,7 @@ static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
 	char errid[32];
 	struct dm_tree_node *node;
 	struct lv_segment *seg_i;
-	int segno = -1, i = 0;;
+	int segno = -1, i = 0;
 	uint64_t size = seg->len * seg->lv->vg->extent_size;
 
 	dm_list_iterate_items(seg_i, &seg->lv->segments) {
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index 7adb5e3..8325dec 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -147,7 +147,7 @@ void set_sysfs_dir_path(const char *path)
 	_sysfs_dir_path[sizeof(_sysfs_dir_path) - 1] = '\0';
 }
 
-const char *log_command_name()
+const char *log_command_name(void)
 {
 	if (!_log_cmd_name)
 		return "";
@@ -165,42 +165,42 @@ int error_message_produced(void)
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
@@ -225,12 +225,12 @@ void init_debug(int level)
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
@@ -245,7 +245,7 @@ int udev_checking(void)
 	return _udev_checking;
 }
 
-const char *sysfs_dir_path()
+const char *sysfs_dir_path(void)
 {
 	return _sysfs_dir_path;
 }
-- 
1.7.4.1


