From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 12 Apr 2017 15:38:37 -0400
Subject: master - dmfilemapd: keep 1 byte for \0
Message-ID: <201704121938.v3CJcbl2012217@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dfc083d8d66cf3286908e9c7fc0c53bd1e5d4967
Commit:        dfc083d8d66cf3286908e9c7fc0c53bd1e5d4967
Parent:        6c342abb7f4fd13126467f6ab2cdf5013f074695
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Apr 1 12:05:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 12 21:33:47 2017 +0200

dmfilemapd: keep 1 byte for \0

Coverity noticed the buffer should have 1 byte for \0.
---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 88f8af2..d232a83 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -589,7 +589,7 @@ check_unlinked:
 		log_error("Could not format pid path.");
 		return 0;
 	}
-	if ((len = readlink(path_buf, link_buf, sizeof(link_buf))) < 0) {
+	if ((len = readlink(path_buf, link_buf, sizeof(link_buf) - 1)) < 0) {
 		log_error("readlink failed for " DEFAULT_PROC_DIR "/%d/fd/%d.",
 			  getpid(), fm->fd);
 		return 0;


