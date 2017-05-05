From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 5 May 2017 06:54:08 -0400
Subject: master - dmfilemapd: clear filemap_monitor before calling _parse_args()
Message-ID: <201705051054.v45As8jU022116@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7fbeea30e5ce4dbb4877910877575ed6c37dfb8c
Commit:        7fbeea30e5ce4dbb4877910877575ed6c37dfb8c
Parent:        c56d8535a722b4b7d8303e7aede627d8b0246e23
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri May 5 11:48:54 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri May 5 11:53:44 2017 +0100

dmfilemapd: clear filemap_monitor before calling _parse_args()

If the wrong number of arguments are given, main() will attempt
to free the uninitialised pointer in fm.path.
---
 daemons/dmfilemapd/dmfilemapd.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 2dd069a..bbaabda 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -266,8 +266,6 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 		return 0;
 	}
 
-	memset(fm, 0, sizeof(*fm));
-
 	/*
 	 * We don't know the true nr_regions at daemon start time,
 	 * and it is not worth a dm_stats_list()/group walk to count:
@@ -801,6 +799,8 @@ int main(int argc, char **argv)
 {
 	struct filemap_monitor fm;
 
+	memset(&fm, 0, sizeof(fm));
+
 	if (!_parse_args(argc, argv, &fm)) {
 		dm_free(fm.path);
 		return 1;


