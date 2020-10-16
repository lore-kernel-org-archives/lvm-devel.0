From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:17 +0000 (GMT)
Subject: stable-2.02 - tests: rename shown debug trace
Message-ID: <20201016191217.3F7DE396EC89@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd860802d4cfabaef1da46140895826a80932d6e
Commit:        bd860802d4cfabaef1da46140895826a80932d6e
Parent:        1d7d3db571e09a25aa7329056f5e052932519212
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 19:17:36 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: rename shown debug trace

As there could be few invokes of stacktrace, avoid
repeatedly display logs from commands.
So after first display rename  debug.log* -> debug_log
so the file still can remain for reading in test dir.
---
 test/lib/utils.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 4f4bf9a21..f01f5bdb0 100644
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


