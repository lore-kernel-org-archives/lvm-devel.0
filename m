From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 May 2015 09:11:54 +0000 (UTC)
Subject: master - tests: check for clmvd socket
Message-ID: <20150527091154.5E0356118E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d3abc25e76d351b1269f55ff524368eb4ddf00b1
Commit:        d3abc25e76d351b1269f55ff524368eb4ddf00b1
Parent:        f0a4955eb1e9fe070d10f451d9d296ceb665fbaa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 27 10:43:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 27 11:10:43 2015 +0200

tests: check for clmvd socket

A bit hacky since it expects PID_DIR == DEFAULT_RUN_DIR for now,
just to check whether it fixes startup clvmd sync problem.
---
 test/lib/aux.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index fedf726..53ebd8a 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -50,7 +50,7 @@ prepare_clvmd() {
 
 	for i in {1..100} ; do
 		test $i -eq 100 && die "Startup of clvmd is too slow."
-		test -e "$CLVMD_PIDFILE" && break
+		test -e "$CLVMD_PIDFILE" -a -e "${CLVMD_PIDFILE%/*}/lvm/clvmd.sock" && break
 		sleep .2
 	done
 }
@@ -572,8 +572,8 @@ prepare_devs() {
 	test -f LOOP || for d in ${DEVICES[@]}; do
 		blkdiscard "$d" 2>/dev/null || true
 		# ensure disk header is always zeroed
-		dd if=/dev/zero of="$d" bs=4096 count=1
-		wipefs -a "$d" 2>/dev/null || dd if=/dev/zero of="$d" bs=64K count=1
+		dd if=/dev/zero of="$d" bs=32k count=1
+		wipefs -a "$d" 2>/dev/null || true
 	done
 
 	#for i in `seq 1 $n`; do


