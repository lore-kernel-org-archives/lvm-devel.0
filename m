From: okozina <okozina@fedoraproject.org>
Date: Mon, 30 Mar 2015 16:43:11 +0000 (UTC)
Subject: master - tests: add helper routine for pvmove status check
Message-ID: <20150330164311.B5C8D60D2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c66850ce506d9a8bdae74f999a658507943d57c
Commit:        7c66850ce506d9a8bdae74f999a658507943d57c
Parent:        c8caa04b1c58e1590654b405d1a6d34cd30c7b4f
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Mar 27 14:24:16 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Mar 30 18:38:50 2015 +0200

tests: add helper routine for pvmove status check

---
 test/lib/aux.sh              |   12 ++++++++++++
 test/shell/pvmove-restart.sh |    7 ++-----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index cdd9a2d..b9f63b5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -902,6 +902,18 @@ dmsetup_wrapped() {
 	dmsetup "$@"
 }
 
+wait_pvmove_lv_ready() {
+	# given sleep .1 this is about 60 secs of waiting
+	local retries=${2:-600}
+	while : ; do
+		test $retries -le 0 && die "Waiting for pvmove LV to get activated has timed out"
+		dmsetup info -c -o tables_loaded $1 > out || true;
+		not grep Live out || break
+		sleep .1
+		retries=$((retries-1))
+	done
+}
+
 test -z "$LVM_TEST_AUX_TRACE" || set -x
 
 test -f DEVICES && devs=$(< DEVICES)
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index 06455f5..ca26779 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -34,11 +34,8 @@ aux delay_dev "$dev3" 0 200
 pvmove -i0 -n $vg/$lv1 "$dev1" "$dev3" $mode &
 PVMOVE=$!
 # Let's wait a bit till pvmove starts and kill it
-while : ; do
-	dmsetup info -c -o tables_loaded "$vg-pvmove0" > out || true;
-	not grep Live out || break
-	sleep .1
-done
+aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+
 kill -9 $PVMOVE
 wait
 


