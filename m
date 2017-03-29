From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:10 -0400
Subject: master - dmfilemapd: use *argv[0] when testing for absolute path (coverity)
Message-ID: <201703292016.v2TKGAsS000748@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43fdbb8aeb78f9ada5dc135fa421c344c8e998d3
Commit:        43fdbb8aeb78f9ada5dc135fa421c344c8e998d3
Parent:        b5252a51a5d041a94e712d804a506e94c9a68893
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:03:20 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:33:42 2017 +0100

dmfilemapd: use *argv[0] when testing for absolute path (coverity)

The path argument check in dmfilemapd incorrectly tests for:

  if (argv[0] == '/')

Rather than testing the 1st character in the string pointed to by
argv[0].
---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index fae6a10..0cb0ad7 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -305,7 +305,7 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 		return 0;
 	}
 
-	if (argv[0] != '/') {
+	if (*argv[0] != '/') {
 		_early_log("Path argument must specify an absolute path.");
 		return 0;
 	}


