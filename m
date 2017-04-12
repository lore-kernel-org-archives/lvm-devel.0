From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:38:43 -0400
Subject: master - dmfilemapd: free path
Message-ID: <201704121938.v3CJch0t012228@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e3f2a53eaa5979d2c32b231f528e7b99c55675e
Commit:        3e3f2a53eaa5979d2c32b231f528e7b99c55675e
Parent:        dfc083d8d66cf3286908e9c7fc0c53bd1e5d4967
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 1 12:11:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:33:47 2017 +0200

dmfilemapd: free path

Cleanup resources before exit.
---
 daemons/dmfilemapd/dmfilemapd.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index d232a83..2dd069a 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -533,6 +533,7 @@ static void _filemap_monitor_destroy(struct filemap_monitor *fm)
 		_filemap_monitor_close_fd(fm);
 	}
 	dm_free((void *) fm->program_id);
+	dm_free(fm->path);
 }
 
 static int _filemap_monitor_check_same_file(int fd1, int fd2)
@@ -800,8 +801,10 @@ int main(int argc, char **argv)
 {
 	struct filemap_monitor fm;
 
-	if (!_parse_args(argc, argv, &fm))
+	if (!_parse_args(argc, argv, &fm)) {
+		dm_free(fm.path);
 		return 1;
+	}
 
 	_setup_logging();
 


