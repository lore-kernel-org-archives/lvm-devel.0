From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Apr 2016 22:35:52 +0000 (UTC)
Subject: master - tests: still show systems stas when command has not produced debug.log file
Message-ID: <20160420223552.03F0C608FD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=545b58542cec657af5125d16125732b424274982
Commit:        545b58542cec657af5125d16125732b424274982
Parent:        22a71e1119823be5ec76abff151f852ee366a00c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 20 23:19:33 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 21 00:34:01 2016 +0200

tests: still show systems stas when command has not produced debug.log file

When no debug.log* file is present whole stacktracking was skipped.
Add extra test the file exists to catch this case.
---
 test/lib/utils.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 861c931..a3b5e2e 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -147,11 +147,12 @@ STACKTRACE() {
 		local name
 		local idx
 		for i in debug.log* ; do
+			test -f "$i" || break  # nothing is found (expands to debug.log*)
 			name=${i##debug.log_}
 			name=${name%%_*}
 			test "$name" = "DEBUG" && { name="$name$idx" ; idx=$(($idx + 1)) ; }
 			echo "<======== Debug log $i ========>"
-			sed -e "s,^,## $name: ," $i
+			sed -e "s,^,## $name: ," "$i"
 		done
 		if test -e strace.log ; then
 			echo "<======== Strace debug log ========>"


