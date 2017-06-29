From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:25:47 -0400
Subject: master - blkdeactivate: more readable if-then-else-fi
Message-ID: <201706292025.v5TKPlFt025716@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5fc0d73e551ed36c752e89b6f409935511f2ba4
Commit:        b5fc0d73e551ed36c752e89b6f409935511f2ba4
Parent:        dc50f2f4a03dd50c5e2411a258095484555421e9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 28 16:55:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

blkdeactivate: more readable if-then-else-fi

---
 scripts/blkdeactivate.sh.in |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index b963a10..a3528e5 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -353,7 +353,11 @@ deactivate_all() {
 			# top-level device could not be deactivated anyway
 			test "$skip" -eq 1 && {
 				# reset 'skip' on top level device
-				is_top_level_device && skip=0 || continue
+				if is_top_level_device ; then
+					skip=0
+				else
+					continue
+				fi
 			}
 
 			# check if the device is not on the skip list already


