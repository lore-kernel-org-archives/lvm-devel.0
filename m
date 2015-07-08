From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 12:22:59 +0000 (UTC)
Subject: master - coverity: fix uninitialized values and other reported problems
Message-ID: <20150708122259.D40C0609C9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71f4fbfbde720795995abffa1bd8aeaa00706a6b
Commit:        71f4fbfbde720795995abffa1bd8aeaa00706a6b
Parent:        16e9b32c2f1a2d7e0f05a88981824ef0e7607965
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 14:19:51 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 14:19:51 2015 +0200

coverity: fix uninitialized values and other reported problems

daemons/lvmlockd/lvmlockd-core.c:5709: error[uninitStructMember]: Uninitialized struct member: ds.....
daemons/lvmlockd/lvmlockd-core.c:799: error[uninitstring]: Dangerous usage of 'version' (strncpy doesn't always null-terminate it)
daemons/lvmlockd/lvmlockd-core.c:646: error[memleakOnRealloc]: Common realloc mistake: 'pollfd' nulled but not freed upon failure
---
 daemons/lvmlockd/lvmlockd-core.c |   28 +++++++++++++++-------------
 1 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 9f3efac..b247bb5 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -624,6 +624,7 @@ fail:
 static int add_pollfd(int fd)
 {
 	int i, new_size;
+	struct pollfd *tmp_pollfd;
 
 	pthread_mutex_lock(&pollfd_mutex);
 	for (i = 0; i < pollfd_size; i++) {
@@ -643,11 +644,12 @@ static int add_pollfd(int fd)
 
 	new_size = pollfd_size + ADD_POLL_SIZE;
 
-	pollfd = realloc(pollfd, new_size * sizeof(struct pollfd));
-	if (!pollfd) {
+	tmp_pollfd = realloc(pollfd, new_size * sizeof(struct pollfd));
+	if (!tmp_pollfd) {
 		log_error("can't alloc new size %d for pollfd", new_size);
 		return -ENOMEM;
 	}
+	pollfd = tmp_pollfd;
 
 	for (i = pollfd_size; i < new_size; i++) {
 		pollfd[i].fd = POLL_FD_UNUSED;
@@ -790,7 +792,7 @@ int last_string_from_args(char *args_in, char *last)
 
 int version_from_args(char *args, unsigned int *major, unsigned int *minor, unsigned int *patch)
 {
-	char version[MAX_ARGS];
+	char version[MAX_ARGS+1];
 	char *major_str, *minor_str, *patch_str;
 	char *n, *d1, *d2;
 
@@ -5606,16 +5608,16 @@ static void usage(char *prog, FILE *file)
 
 int main(int argc, char *argv[])
 {
-	daemon_state ds;
-
-	ds.daemon_main = main_loop;
-	ds.daemon_init = NULL;
-	ds.daemon_fini = NULL;
-	ds.pidfile = getenv("LVM_LVMLOCKD_PIDFILE");
-	ds.socket_path = getenv("LVM_LVMLOCKD_SOCKET");
-	ds.protocol = lvmlockd_protocol;
-	ds.protocol_version = lvmlockd_protocol_version;
-	ds.name = "lvmlockd";
+	daemon_state ds = {
+		.daemon_main = main_loop,
+		.daemon_init = NULL,
+		.daemon_fini = NULL,
+		.pidfile = getenv("LVM_LVMLOCKD_PIDFILE"),
+		.socket_path = getenv("LVM_LVMLOCKD_SOCKET"),
+		.protocol = lvmlockd_protocol,
+		.protocol_version = lvmlockd_protocol_version,
+		.name = "lvmlockd",
+	};
 
 	static struct option long_options[] = {
 		{"help",            no_argument,       0, 'h' },


