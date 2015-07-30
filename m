From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 30 Jul 2015 15:50:55 +0000 (UTC)
Subject: master - lvmlockd: small fixes and cleanup for lvmlockctl
Message-ID: <20150730155055.C202560DD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78135c24b419d070a238f1660408c843707c7cbb
Commit:        78135c24b419d070a238f1660408c843707c7cbb
Parent:        d9c67a9b21583e6665ba7c13a3fa2d0151082f5b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 30 10:47:41 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 30 10:50:22 2015 -0500

lvmlockd: small fixes and cleanup for lvmlockctl

. clean up the info output for readability
. remove some internal debug output
. fix the daemon quit option
---
 daemons/lvmlockd/lvmlockctl.c    |   35 +++++++++++++----------------------
 daemons/lvmlockd/lvmlockd-core.c |    9 ++++-----
 2 files changed, 17 insertions(+), 27 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 4b27a57..cb67296 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -40,11 +40,6 @@ static socklen_t dump_addrlen;
 
 daemon_handle _lvmlockd;
 
-#define log_debug(fmt, args...) \
-do { \
-	printf(fmt "\n", ##args); \
-} while (0)
-
 #define log_error(fmt, args...) \
 do { \
 	printf(fmt "\n", ##args); \
@@ -102,6 +97,8 @@ static void find_client_info(uint32_t client_id, uint32_t *pid, char *cl_name)
 	}
 }
 
+static int first_ls = 1;
+
 static void format_info_ls(char *line)
 {
 	char ls_name[MAX_NAME+1] = { 0 };
@@ -114,7 +111,9 @@ static void format_info_ls(char *line)
 	sscanf(line, "info=ls ls_name=%s vg_name=%s vg_uuid=%s vg_sysid=%s vg_args=%s lm_type=%s",
 	       ls_name, vg_name, vg_uuid, vg_sysid, lock_args, lock_type);
 
-	printf("\n");
+	if (!first_ls)
+		printf("\n");
+	first_ls = 0;
 
 	printf("VG %s lock_type=%s %s\n", vg_name, lock_type, vg_uuid);
 
@@ -160,10 +159,10 @@ static void format_info_r(char *line, char *r_name_out, char *r_type_out)
 	/* when mode is un, there will be no lk lines, so print now */
 
 	if (!strcmp(r_type, "gl")) {
-		printf("LK GL un ver %4u\n", ver);
+		printf("LK GL un ver %u\n", ver);
 
 	} else if (!strcmp(r_type, "vg")) {
-		printf("LK VG un ver %4u\n", ver);
+		printf("LK VG un ver %u\n", ver);
 
 	} else if (!strcmp(r_type, "lv")) {
 		printf("LK LV un %s\n", r_name);
@@ -191,10 +190,10 @@ static void format_info_lk(char *line, char *r_name, char *r_type)
 	find_client_info(client_id, &pid, cl_name);
 
 	if (!strcmp(r_type, "gl")) {
-		printf("LK GL %s ver %4u pid %u (%s)\n", mode, ver, pid, cl_name);
+		printf("LK GL %s ver %u pid %u (%s)\n", mode, ver, pid, cl_name);
 
 	} else if (!strcmp(r_type, "vg")) {
-		printf("LK VG %s ver %4u pid %u (%s)\n", mode, ver, pid, cl_name);
+		printf("LK VG %s ver %u pid %u (%s)\n", mode, ver, pid, cl_name);
 
 	} else if (!strcmp(r_type, "lv")) {
 		printf("LK LV %s %s\n", mode, r_name);
@@ -232,10 +231,10 @@ static void format_info_r_action(char *line, char *r_name, char *r_type)
 	}
 
 	if (!strcmp(r_type, "gl")) {
-		printf("LW GL %s ver %4u pid %u (%s)\n", mode, 0, pid, cl_name);
+		printf("LW GL %s ver %u pid %u (%s)\n", mode, 0, pid, cl_name);
 
 	} else if (!strcmp(r_type, "vg")) {
-		printf("LW VG %s ver %4u pid %u (%s)\n", mode, 0, pid, cl_name);
+		printf("LW VG %s ver %u pid %u (%s)\n", mode, 0, pid, cl_name);
 
 	} else if (!strcmp(r_type, "lv")) {
 		printf("LW LV %s %s\n", mode, r_name);
@@ -245,7 +244,7 @@ static void format_info_r_action(char *line, char *r_name, char *r_type)
 static void format_info_line(char *line, char *r_name, char *r_type)
 {
 	if (!strncmp(line, "info=structs ", strlen("info=structs "))) {
-		printf("%s", line);
+		/* only print this in the raw info dump */
 
 	} else if (!strncmp(line, "info=client ", strlen("info=client "))) {
 		save_client_info(line);
@@ -325,8 +324,6 @@ static daemon_reply _lvmlockd_send(const char *req_name, ...)
 static int _lvmlockd_result(daemon_reply reply, int *result)
 {
 	int reply_result;
-	const char *reply_flags;
-	const char *lock_type;
 
 	if (reply.error) {
 		log_error("lvmlockd_result reply error %d", reply.error);
@@ -344,14 +341,8 @@ static int _lvmlockd_result(daemon_reply reply, int *result)
 		return 0;
 	}
 
-	/* The lock_type that lvmlockd used for locking. */
-	lock_type = daemon_reply_str(reply, "lock_type", "none");
-
 	*result = reply_result;
 
-	reply_flags = daemon_reply_str(reply, "result_flags", NULL);
-
-	log_debug("lvmlockd_result %d %s lm %s", reply_result, reply_flags, lock_type);
 	return 1;
 }
 
@@ -606,7 +597,7 @@ int main(int argc, char **argv)
 	_lvmlockd = lvmlockd_open(NULL);
 
 	if (_lvmlockd.socket_fd < 0 || _lvmlockd.error) {
-		log_error("lvmlockd open error %d", _lvmlockd.error);
+		log_error("Cannot connect to lvmlockd.");
 		return -1;
 	}
 
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index dc0d3e7..b299050 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -3886,7 +3886,7 @@ static int print_lockspace(struct lockspace *ls, const char *prefix, int pos, in
 			"thread_work=%d "
 			"thread_stop=%d "
 			"thread_done=%d "
-			"sanlock_gl_enabled=%d",
+			"sanlock_gl_enabled=%d\n",
 			prefix,
 			ls->name,
 			ls->vg_name,
@@ -4127,11 +4127,10 @@ static void client_recv_action(struct client *cl)
 		if (op == LD_OP_QUIT) {
 			log_debug("op quit");
 			pthread_mutex_lock(&lockspaces_mutex);
-		       	if (list_empty(&lockspaces)) {
+		       	if (list_empty(&lockspaces))
 				daemon_quit = 1;
-			} else {
+			else
 				result = -EBUSY;
-			}
 			pthread_mutex_unlock(&lockspaces_mutex);
 		}
 
@@ -5511,7 +5510,7 @@ static int main_loop(daemon_state *ds_arg)
 
 	while (1) {
 		rv = poll(pollfd, pollfd_maxi + 1, -1);
-		if (rv == -1 && errno == EINTR) {
+		if ((rv == -1 && errno == EINTR) || daemon_quit) {
 			if (daemon_quit) {
 				int count;
 				/* first sigterm would trigger stops, and


