From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:10 +0000 (GMT)
Subject: stable-2.02 - tests: move function to aux for reuse
Message-ID: <20201016191210.5FE5D396EC8D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=de1b894337759c574f5e1cf11dcd40ef765d6ad2
Commit:        de1b894337759c574f5e1cf11dcd40ef765d6ad2
Parent:        c68380746ab82a5c2517c71435daf830fa158a6f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 23:37:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

tests: move function to aux for reuse

---
 test/lib/aux.sh                               | 8 ++++++++
 test/shell/lvextend-thin-metadata-dmeventd.sh | 5 +----
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8758dc01d..1a66df16e 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1504,6 +1504,14 @@ thin_pool_error_works_32() {
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
 


