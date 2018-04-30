From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Apr 2018 14:12:34 -0400
Subject: master - tests: fix THIN built-in check
Message-ID: <201804301812.w3UICYo2028143@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c365d7de4f49a0b175772548c92961143c078921
Commit:        c365d7de4f49a0b175772548c92961143c078921
Parent:        89935ace29bd2097467201546e9211ebed23c4bc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 30 13:10:52 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 30 13:12:17 2018 -0500

tests: fix THIN built-in check

---
 test/lib/aux.sh |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index fa6309c..e44116f 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1472,10 +1472,6 @@ driver_at_least() {
 }
 
 have_thin() {
-	test "$THIN" = shared -o "$THIN" = internal || {
-		echo "Thin is not built-in." >&2
-		return 1;
-	}
 	target_at_least dm-thin-pool "$@"
 
 	declare -a CONF=()


