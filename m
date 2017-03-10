From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 11:44:56 -0500
Subject: master - dmsetup: always initialise 'dms' in _stats_update_file()
Message-ID: <201703101644.v2AGiuGY012294@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c71374531414081aa2aad71317dac55fc024a0d5
Commit:        c71374531414081aa2aad71317dac55fc024a0d5
Parent:        d28a50ec76c62c48a3be695569fe5e752b9ae684
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 16:44:08 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 16:44:08 2017 +0000

dmsetup: always initialise 'dms' in _stats_update_file()

---
 tools/dmsetup.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 945557f..1e22cf1 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5650,8 +5650,8 @@ static int _stats_update_file(CMD_ARGS)
 	int foreground = _switches[FOREGROUND_ARG];
 	int verbose = _switches[VERBOSE_ARG];
 	char *path, *abspath = NULL;
+	struct dm_stats *dms = NULL;
 	dm_filemapd_mode_t mode;
-	struct dm_stats *dms;
 	int fd = -1;
 
 
@@ -5764,8 +5764,7 @@ bad:
 	if ((fd > -1) && close(fd))
 		log_error("Error closing %s", path);
 
-	if (dms)
-		dm_stats_destroy(dms);
+	dm_stats_destroy(dms);
 
 	return 0;
 }


