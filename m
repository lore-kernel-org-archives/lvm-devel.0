From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:34:26 -0400
Subject: master - tests: fix possible misspelling
Message-ID: <201707101234.v6ACYQQh022942@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eba96a9720add0120b029a34fe8641297cd1e904
Commit:        eba96a9720add0120b029a34fe8641297cd1e904
Parent:        d4345220cc85a803b8c029adb472fc4d9f580659
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 6 20:08:53 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: fix possible misspelling

Possible misspelling: FAILED_MIXED_STR may not be assigned, but FAIL_MIXED_STR is.
Possible misspelling: FAILED_MULTI_STR may not be assigned, but FAIL_MULTI_STR is.
Possible misspelling: FAILED_BLACK_STR may not be assigned, but FAIL_BLACK_STR is.
---
 test/shell/name-mangling.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/name-mangling.sh b/test/shell/name-mangling.sh
index 80e7b6c..3e67587 100644
--- a/test/shell/name-mangling.sh
+++ b/test/shell/name-mangling.sh
@@ -76,13 +76,13 @@ function check_create_and_remove()
 
 	if [ "$dm_name" = "FAIL_MIXED" ]; then
 		r=0
-		grep "$FAILED_MIXED_STR" err || r=1
+		grep "$FAIL_MIXED_STR" err || r=1
 	elif [ "$dm_name" = "FAIL_MULTI" ]; then
 		r=0
-		grep "$FAILED_MULTI_STR" err || r=1
+		grep "$FAIL_MULTI_STR" err || r=1
 	elif [ "$dm_name" = "FAIL_BLACK" ]; then
 		r=0
-		grep "$FAILED_BLACK_STR" err || r=1
+		grep "$FAIL_BLACK_STR" err || r=1
 	fi
 
 	return $r


