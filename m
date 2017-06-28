From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Jun 2017 08:46:06 -0400
Subject: master - coverity: checked_return of close
Message-ID: <201706281246.v5SCk68B013776@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a533892cd3bcb6abd0d0ee3f35f059850e540238
Commit:        a533892cd3bcb6abd0d0ee3f35f059850e540238
Parent:        b90014addca59b3a40a686fd73b27f7a40511660
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 14:40:35 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 28 14:42:11 2017 +0200

coverity: checked_return of close

Check (or make quiet) close() ret code.
NOTE: there is another duplicated code of daemonize function which
should be converted to libdaemon.
---
 daemons/dmfilemapd/dmfilemapd.c |    4 ++--
 tools/command.c                 |    3 ++-
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index a1293dc..a51187a 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -662,11 +662,11 @@ static int _daemonise(struct filemap_monitor *fm)
 			return 0;
 		}
 	}
-
+	/* TODO: Use libdaemon/server/daemon-server.c _daemonise() */
 	for (fd = (int) sysconf(_SC_OPEN_MAX) - 1; fd > STDERR_FILENO; fd--) {
 		if (fd == fm->fd)
 			continue;
-		close(fd);
+		(void) close(fd);
 	}
 
 	return 1;
diff --git a/tools/command.c b/tools/command.c
index 5c2ec26..e2e60a3 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3304,7 +3304,8 @@ static int include_description_file(char *name, char *des_file)
 out_free:
 	dm_free(buf);
 out_close:
-	close(fd);
+	if (close(fd))
+		log_sys_debug("close", des_file);
 
 	return r;
 }


