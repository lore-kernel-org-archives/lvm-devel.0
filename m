From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Mar 2015 10:11:42 +0000 (UTC)
Subject: master - tests: start clvmd without lib/
Message-ID: <20150320101142.62E9260B44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21343ffbfed94f41da11fac4dd056af58f4341a9
Commit:        21343ffbfed94f41da11fac4dd056af58f4341a9
Parent:        a515a91fcc8df04b5dfd9fe23ef6925c58846af0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 20 11:08:21 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 20 11:08:21 2015 +0100

tests: start clvmd without lib/

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 339da31..69c1473 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -43,7 +43,7 @@ prepare_clvmd() {
 	local run_valgrind=
 	test "${LVM_VALGRIND_CLVMD:-0}" -eq 0 || run_valgrind="run_valgrind"
 	rm -f "$CLVMD_PIDFILE"
-	$run_valgrind lib/clvmd -Isinglenode -d 1 -f &
+	$run_valgrind clvmd -Isinglenode -d 1 -f &
 	echo $! > LOCAL_CLVMD
 
 	for i in $(seq 1 100) ; do


