From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:29:28 -0400
Subject: master - tests: utils.sh separately assign
Message-ID: <201706292029.v5TKTSDO026962@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d7b381522352c684c5c55657125963533fe98132
Commit:        d7b381522352c684c5c55657125963533fe98132
Parent:        cf4b671acd4d7ff87dea3ffa88ff99377d093c50
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 21:22:52 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: utils.sh separately assign

Declare and assign separately to avoid masking return values.
---
 test/lib/utils.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index bfa98de..4f3e460 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -188,7 +188,8 @@ STACKTRACE() {
 
 init_udev_transaction() {
 	if test "$DM_UDEV_SYNCHRONISATION" = 1; then
-		local cookie=$(dmsetup udevcreatecookie)
+		local cookie
+		cookie=$(dmsetup udevcreatecookie)
 		# Cookie is not generated if udev is not running!
 		test -z "$cookie" || export DM_UDEV_COOKIE=$cookie
 	fi


