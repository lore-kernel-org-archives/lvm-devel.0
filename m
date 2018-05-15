From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 May 2018 16:05:24 -0400
Subject: master - tests: time limit waiting on lvmetad kill
Message-ID: <201805152005.w4FK5ODr001463@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b3ee66b1f86518ef39a1b88a868083f9d2fc4e7
Commit:        3b3ee66b1f86518ef39a1b88a868083f9d2fc4e7
Parent:        b5da4fdfcebb5a9c2c32b64b27a12f6480829a97
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 15 21:52:05 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 15 22:02:41 2018 +0200

tests: time limit waiting on lvmetad kill

---
 test/shell/lvmetad-disabled.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index 0f180c7..84d7b54 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -19,7 +19,11 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_devs 2
 
 kill "$(< LOCAL_LVMETAD)"
-while test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket close
+for i in {200..0} ; do
+	test -e "$TESTDIR/lvmetad.socket" || break
+	test "$i" -eq 0 && die "Too slow closing of lvmetad.socket. Aborting test."
+	echo -n .; sleep .1;
+done # wait for the socket close
 test ! -e "$LVM_LVMETAD_PIDFILE"
 
 aux lvmconf "global/use_lvmetad = 0"


