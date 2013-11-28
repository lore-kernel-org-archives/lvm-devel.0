From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 28 Nov 2013 11:49:03 +0000 (UTC)
Subject: master - cleanup: convert log_sys_error to log_sys_debug
Message-ID: <20131128114903.86F9B61159@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5bdbaf4ed7a0f8b8e032d4f8d76bb63f8ec071b8
Commit:        5bdbaf4ed7a0f8b8e032d4f8d76bb63f8ec071b8
Parent:        6c787d9b6ed9c9ef2964431881884dd3879f4dc1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 25 13:46:34 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 28 12:48:01 2013 +0100

cleanup: convert log_sys_error to log_sys_debug

Use debug for those error reports which do not lead to error return
call.
---
 daemons/dmeventd/libdevmapper-event.c |    8 ++++----
 lib/locking/file_locking.c            |   10 +++++-----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 9e8911e..1b5273d 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -425,7 +425,7 @@ static int _start_daemon(char *dmeventd_path, struct dm_event_fifos *fifos)
 	if (fifos->client >= 0) {
 		/* server is running and listening */
 		if (close(fifos->client))
-			log_sys_error("close", fifos->client_path);
+			log_sys_debug("close", fifos->client_path);
 		return 1;
 	} else if (errno != ENXIO) {
 		/* problem */
@@ -507,14 +507,14 @@ static int _init_client(char *dmeventd_path, struct dm_event_fifos *fifos)
 void fini_fifos(struct dm_event_fifos *fifos)
 {
 	if (fifos->client >= 0 && close(fifos->client))
-		log_sys_error("close", fifos->client_path);
+		log_sys_debug("close", fifos->client_path);
 
 	if (fifos->server >= 0) {
 		if (flock(fifos->server, LOCK_UN))
-			log_sys_error("flock unlock", fifos->server_path);
+			log_sys_debug("flock unlock", fifos->server_path);
 
 		if (close(fifos->server))
-			log_sys_error("close", fifos->server_path);
+			log_sys_debug("close", fifos->server_path);
 	}
 }
 
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index 3fa0a2d..1fa23b3 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -54,10 +54,10 @@ static void _undo_flock(const char *file, int fd)
 	    !fstat(fd, &buf2) &&
 	    is_same_inode(buf1, buf2))
 		if (unlink(file))
-			log_sys_error("unlink", file);
+			log_sys_debug("unlink", file);
 
 	if (close(fd) < 0)
-		log_sys_error("close", file);
+		log_sys_debug("close", file);
 }
 
 static int _release_lock(const char *file, int unlock)
@@ -73,7 +73,7 @@ static int _release_lock(const char *file, int unlock)
 			if (unlock) {
 				log_very_verbose("Unlocking %s", ll->res);
 				if (flock(ll->lf, LOCK_NB | LOCK_UN))
-					log_sys_error("flock", ll->res);
+					log_sys_debug("flock", ll->res);
 			}
 
 			_undo_flock(ll->res, ll->lf);
@@ -141,7 +141,7 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 			  operation == LOCK_EX ? 'W' : 'R', nonblock ? ' ' : 'B');
 	do {
 		if ((*fd > -1) && close(*fd))
-			log_sys_error("close", file);
+			log_sys_debug("close", file);
 
 		if ((*fd = open(file, O_CREAT | O_APPEND | O_RDWR, 0777)) < 0) {
 			log_sys_error("open", file);
@@ -162,7 +162,7 @@ static int _do_flock(const char *file, int *fd, int operation, uint32_t nonblock
 			errno = old_errno;
 			log_sys_error("flock", file);
 			if (close(*fd))
-				log_sys_error("close", file);
+				log_sys_debug("close", file);
 			*fd = -1;
 			return 0;
 		}


