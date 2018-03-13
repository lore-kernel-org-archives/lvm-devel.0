From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:05:21 -0400
Subject: master - dmsetup: report close as debug
Message-ID: <201803131205.w2DC5LML002770@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49a8c786d5fdbf79ac60f2720d4e1433146d14f4
Commit:        49a8c786d5fdbf79ac60f2720d4e1433146d14f4
Parent:        06c1f71897273558b5ffe607ceaee6d51576b861
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 12 23:01:52 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: report close as debug

Since close() failures are not causing command errors,
issue error via debug log stream only.
---
 tools/dmsetup.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index c866cd6..0d5b713 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5437,7 +5437,7 @@ static int _stats_create_file(CMD_ARGS)
 	}
 
 	if (close(fd))
-		log_error("Error closing %s.", abspath);
+		log_sys_debug("close", abspath);
 
 	fd = -1;
 
@@ -5466,7 +5466,7 @@ bad:
 	dm_free(bounds);
 
 	if ((fd > -1) && close(fd))
-		log_error("Error closing %s", path);
+		log_sys_debug("close", path);
 
 	if (dms)
 		dm_stats_destroy(dms);
@@ -6065,7 +6065,7 @@ static int _stats_update_file(CMD_ARGS)
 
 out:
 	if (close(fd))
-		log_error("Error closing %s", abspath);
+		log_sys_debug("close", abspath);
 
 	dm_free(regions);
 	dm_free(abspath);
@@ -6076,7 +6076,7 @@ bad:
 	dm_free(abspath);
 
 	if ((fd > -1) && close(fd))
-		log_error("Error closing %s", path);
+		log_sys_debug("close", path);
 
 	dm_stats_destroy(dms);
 
@@ -6614,7 +6614,7 @@ bad:
 	if (fd > -1 && close(fd))
 		log_sys_error("close", file);
 
-	return_0;
+	return 0;
 }
 
 static int _process_losetup_switches(const char *base, int *argcp, char ***argvp,


