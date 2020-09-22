From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:52 +0000 (GMT)
Subject: master - tests: move function to aux for reuse
Message-ID: <20200922214652.B910039450FB@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e280f56dd3fa1419c37c486ae651b000f26cfeca
Commit:        e280f56dd3fa1419c37c486ae651b000f26cfeca
Parent:        adead83dc2763a12f2f0e711793b5fd8c446b3f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 23:37:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:43:26 2020 +0200

tests: move function to aux for reuse

---
 test/lib/aux.sh                               | 8 ++++++++
 test/shell/lvextend-thin-metadata-dmeventd.sh | 5 +----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a17bf846c..77942009b 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1467,6 +1467,14 @@ thin_pool_error_works_32() {
 	esac
 }
 
+thin_restore_needs_more_volumes() {
+	case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
+		# With older version of thin-tool we got slightly more compact metadata
+		0.[0-6]*|0.7.0*) return 0 ;;
+	esac
+	return 1
+}
+
 udev_wait() {
 	pgrep udev >/dev/null || return 0
 	which udevadm &>/dev/null || return 0
diff --git a/test/shell/lvextend-thin-metadata-dmeventd.sh b/test/shell/lvextend-thin-metadata-dmeventd.sh
index 5f6db994a..3193cc29c 100644
--- a/test/shell/lvextend-thin-metadata-dmeventd.sh
+++ b/test/shell/lvextend-thin-metadata-dmeventd.sh
@@ -61,10 +61,7 @@ test -n "$LVM_TEST_THIN_RESTORE_CMD" || LVM_TEST_THIN_RESTORE_CMD=$(which thin_r
 aux have_thin 1 10 0 || skip
 
 BIG_DATA=""
-case $("$LVM_TEST_THIN_RESTORE_CMD" -V) in
-	# With older version of thin-tool we got slightly more compact metadata
-	0.[0-6]*|0.7.0*) BIG_DATA="generate_more_metadata" ;;
-esac
+aux thin_restore_needs_more_volumes && BIG_DATA="generate_more_metadata"
 
 aux prepare_dmeventd
 


