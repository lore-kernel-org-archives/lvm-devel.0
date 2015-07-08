From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  8 Jul 2015 11:58:04 +0000 (UTC)
Subject: master - coverity: fix resource leaks
Message-ID: <20150708115804.1A07B6113D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=16e9b32c2f1a2d7e0f05a88981824ef0e7607965
Commit:        16e9b32c2f1a2d7e0f05a88981824ef0e7607965
Parent:        3b6840e0997dd4df0ea711c2036871e3cc2fe40a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 8 13:56:06 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 8 13:56:06 2015 +0200

coverity: fix resource leaks

lib/log/log.c:115: leaked_storage: Variable "st" going out of scope leaks the storage it points to
daemons/lvmpolld/lvmpolld-core.c:573: leaked_storage: Variable "cmdargv" going out of scope leaks the storage it points to
daemons/lvmlockd/lvmlockd-core.c:5341: leaked_handle: Handle variable "fd" going out of scope leaks the handle
daemons/lvmlockd/lvmlockctl.c:575: overwrite_var: Overwriting "able_vg_name" in "able_vg_name = strdup(optarg)" leaks the storage that "able_vg_name" points to
daemons/lvmlockd/lvmlockctl.c:571: overwrite_var: Overwriting "able_vg_name" in "able_vg_name = strdup(optarg)" leaks the storage that "able_vg_name" points to
daemons/lvmlockd/lvmlockctl.c:385: leaked_handle: Handle variable "s" going out of scope leaks the handle
---
 daemons/lvmlockd/lvmlockctl.c    |   23 +++++++++++++----------
 daemons/lvmlockd/lvmlockd-core.c |    5 ++++-
 lib/log/log.c                    |    6 +++---
 3 files changed, 20 insertions(+), 14 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockctl.c b/daemons/lvmlockd/lvmlockctl.c
index 5a4f3f5..51b5734 100644
--- a/daemons/lvmlockd/lvmlockctl.c
+++ b/daemons/lvmlockd/lvmlockctl.c
@@ -21,15 +21,15 @@
 #include <sys/socket.h>
 #include <sys/un.h>
 
-static int quit;
-static int info;
-static int dump;
-static int wait_opt;
-static int force_opt;
-static int gl_enable;
-static int gl_disable;
-static int stop_lockspaces;
-static char *able_vg_name;
+static int quit = 0;
+static int info = 0;
+static int dump = 0;
+static int wait_opt = 0;
+static int force_opt = 0;
+static int gl_enable = 0;
+static int gl_disable = 0;
+static int stop_lockspaces = 0;
+static char *able_vg_name = NULL;
 
 #define DUMP_SOCKET_NAME "lvmlockd-dump.sock"
 #define DUMP_BUF_SIZE (1024 * 1024)
@@ -381,8 +381,11 @@ static int setup_dump_socket(void)
 	dump_addrlen = sizeof(sa_family_t) + strlen(dump_addr.sun_path+1) + 1;
 
 	rv = bind(s, (struct sockaddr *) &dump_addr, dump_addrlen);
-	if (rv < 0)
+	if (rv < 0) {
+		if (!close(s))
+			log_error("failed to close dump socket");
 		return rv;
+	}
 
 	return s;
 }
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 649c9aa..9f3efac 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -5337,8 +5337,11 @@ static void process_listener(int poll_fd)
 	if (fd < 0)
 		return;
 
-	if (!(cl = alloc_client()))
+	if (!(cl = alloc_client())) {
+		if (!close(fd))
+			log_error("failed to close lockd poll fd");
 		return;
+	}
 
 	pi = add_pollfd(fd);
 	if (pi < 0) {
diff --git a/lib/log/log.c b/lib/log/log.c
index 20ca293..e3570d4 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -92,9 +92,6 @@ void init_log_file(const char *log_file, int append)
 			   "%llu", &pid, &starttime) != 2) {
 			log_warn("WARNING: Cannot parse content of %s.", statfile);
 		} else {
-			if (fclose(st))
-				log_sys_debug("fclose", statfile);
-
 			if (dm_snprintf(_log_file_path, sizeof(_log_file_path),
 					"%s_%s_%d_%lld", log_file, env, pid, starttime) < 0) {
 				log_warn("WARNING: Debug log file path is too long for epoch.");
@@ -105,6 +102,9 @@ void init_log_file(const char *log_file, int append)
 			}
 		}
 	}
+
+	if (st && fclose(st))
+		log_sys_debug("fclose", statfile);
 no_epoch:
 	if (!(_log_file = fopen(log_file, append ? "a" : "w"))) {
 		log_sys_error("fopen", log_file);


