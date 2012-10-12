From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Oct 2012 13:51:24 +0000 (UTC)
Subject: master - blkdeactivate: fix long form of options
Message-ID: <20121012135124.D5FF6A2BC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d7a4554f40f990b9cb43a5a6039251eec3b94c3
Commit:        4d7a4554f40f990b9cb43a5a6039251eec3b94c3
Parent:        2679c68689628e71749ebcfc8b2969e32ed6cb3c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 12 15:42:24 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 12 15:42:24 2012 +0200

blkdeactivate: fix long form of options

Actually, long form for -d and -l option is --dmoption and --lvmoption respectively.
---
 scripts/blkdeactivate.sh.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 031f5f6..740bac5 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -302,8 +302,8 @@ while test $# -ne 0; do
 	case "$1" in
 		"") ;;
 		"-h"|"--help") usage ;;
-		"-d"|"--dmopts") get_dmopts "$2" ; shift ;;
-		"-l"|"--lvmopts") get_lvmopts "$2" ; shift ;;
+		"-d"|"--dmoption ") get_dmopts "$2" ; shift ;;
+		"-l"|"--lvmoption ") get_lvmopts "$2" ; shift ;;
 		"-u"|"--umount") DO_UMOUNT=1 ;;
 		*) break ;;
 	esac


