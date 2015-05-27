From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 May 2015 09:11:50 +0000 (UTC)
Subject: master - tests: drop debug print
Message-ID: <20150527091150.1729F6118E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c254743ef31f1d36f85329cad1a5c3b55fca2bb0
Commit:        c254743ef31f1d36f85329cad1a5c3b55fca2bb0
Parent:        d1531ab26d047d95c03c6e5f101c52dd47d47435
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 25 09:59:02 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 27 11:10:43 2015 +0200

tests: drop debug print

---
 test/lib/inittest.sh |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 1af0503..0b898f3 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -100,7 +100,6 @@ else
 	aux prepare_clvmd
 fi
 
-echo "LVM_TEST_LVMPOLLD=$LVM_TEST_LVMPOLLD"
 test -n "$LVM_TEST_LVMPOLLD" && {
 	export LVM_LVMPOLLD_SOCKET="$TESTDIR/lvmpolld.socket"
 	export LVM_LVMPOLLD_PIDFILE="$TESTDIR/lvmpolld.pid"


