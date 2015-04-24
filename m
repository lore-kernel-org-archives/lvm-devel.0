From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Apr 2015 22:42:20 +0000 (UTC)
Subject: master - tests: try more advanced clean
Message-ID: <20150424224220.EB79460F5F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d7888e83169ac1a7a962ffd66502995792879244
Commit:        d7888e83169ac1a7a962ffd66502995792879244
Parent:        066d0a4e1949afac055a7dc92bedd0f45f519124
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 24 11:12:55 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Apr 25 00:39:43 2015 +0200

tests: try more advanced clean

When test is executed on real device - lets try a more complete
cleanup - discard whole device first and try to wipe any
headers it might be left from previous test.
---
 test/lib/aux.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4e6961a..cc3718c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -431,7 +431,8 @@ prepare_devs() {
 
 	# non-ephemeral devices need to be cleared between tests
 	test -f LOOP || for d in ${DEVICES[@]}; do
-		dd if=/dev/zero of=$d bs=64K count=1
+		blkdiscard "$d" 2>/dev/null || true
+		wipefs -a "$d" 2>/dev/null || dd if=/dev/zero of="$d" bs=64K count=1
 	done
 
 	#for i in `seq 1 $n`; do


