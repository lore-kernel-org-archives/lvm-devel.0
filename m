From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:54 +0000 (UTC)
Subject: master - TEST: Add LVM_VALGRIND_LVMETAD to testing options.
Message-ID: <20120926175554.8A0B7A33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d7a8b453196893186ae3eb61dc31c1df8b1cf6f
Commit:        2d7a8b453196893186ae3eb61dc31c1df8b1cf6f
Parent:        0a87fed794f2886047298bbc7b21919e9fc04951
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Sep 10 07:42:39 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 17:26:23 2012 +0200

TEST: Add LVM_VALGRIND_LVMETAD to testing options.

---
 test/lib/aux.sh |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index d6a2008..d1d5e10 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -73,8 +73,11 @@ prepare_lvmetad() {
 	lvmconf "global/use_lvmetad = 1"
 	lvmconf "devices/md_component_detection = 0"
 
+	local run_valgrind=
+	test -z "$LVM_VALGRIND_LVMETAD" || run_valgrind="run_valgrind"
+
 	echo "preparing lvmetad..."
-	lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -d wire,debug &
+	$run_valgrind lvmetad -f "$@" -s "$TESTDIR/lvmetad.socket" -d wire,debug &
 	echo $! > LOCAL_LVMETAD
 
 	sleep .3


