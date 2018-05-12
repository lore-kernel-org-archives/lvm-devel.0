From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 May 2018 12:26:00 -0400
Subject: master - tests: move device discard
Message-ID: <201805121626.w4CGQ01L007866@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7362ed68be4a292fd51ad32fd8960c1c8ef765d9
Commit:        7362ed68be4a292fd51ad32fd8960c1c8ef765d9
Parent:        f5da325d701082edab568160824c9c8c7289cf15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 7 11:56:00 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 12 17:48:31 2018 +0200

tests: move device discard

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 853a78f..877934c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -867,6 +867,7 @@ prepare_devs() {
 	prepare_backing_dev $(( n * devsize ))
 	# shift start of PV devices on /dev/loopXX by 1M
 	not diff LOOP BACKING_DEV >/dev/null 2>&1 || shift=2048
+	blkdiscard "$BACKING_DEV" 2>/dev/null || true
 	echo -n "## preparing $n devices..."
 
 	local size=$(( devsize * 2048 )) # sectors
@@ -894,7 +895,6 @@ prepare_devs() {
 
 	# non-ephemeral devices need to be cleared between tests
 	test -f LOOP -o -f RAMDISK || for d in "${DEVICES[@]}"; do
-		blkdiscard "$d" 2>/dev/null || true
 		# ensure disk header is always zeroed
 		dd if=/dev/zero of="$d" bs=32k count=1
 		wipefs -a "$d" 2>/dev/null || true


