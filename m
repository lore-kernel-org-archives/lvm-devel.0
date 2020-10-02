From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:28:03 +0000 (GMT)
Subject: master - tests: rename shown debug trace
Message-ID: <20201002202803.9F529398E493@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d9b4c624f5738035ef9a7af19cb85b6960ca080
Commit:        8d9b4c624f5738035ef9a7af19cb85b6960ca080
Parent:        73a3a0d3476bd55358348bb95ddcdfe9ff1e809e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:17:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 22:27:00 2020 +0200

tests: rename shown debug trace

As there could be few invokes of stacktrace, avoid
repeatedly display logs from commands.
So after first display rename  debug.log* -> debug_log
so the file still can remain for reading in test dir.
---
 test/lib/utils.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 3bf73bb4c..88de1a0e2 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -171,6 +171,7 @@ STACKTRACE() {
 			test "$name" = "DEBUG" && { name="$name$idx" ; idx=$(( idx + 1 )) ; }
 			echo "<======== Debug log $i ========>"
 			sed -e "s,^,## $name: ," "$i"
+			mv -f "$i" "debug_${i#debug.}"
 		done
 		if test -e strace.log ; then
 			echo "<======== Strace debug log ========>"


