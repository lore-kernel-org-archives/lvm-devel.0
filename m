From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Apr 2023 17:55:37 +0000 (GMT)
Subject: main - tests: some aux corrections
Message-ID: <20230425175537.DF0793858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b88c9f6199499692c8b4b47488dffd0f187b9f7
Commit:        7b88c9f6199499692c8b4b47488dffd0f187b9f7
Parent:        4a003ba671bd4f38d9108f5dd174eccda1522c3b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 25 15:07:25 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 25 18:59:04 2023 +0200

tests: some aux corrections

Keep backups within test_dir instead of dev_dir (so it doesn't
leak large files there if the tests are run over real /dev dir).

Move restoring of dm_mirror throttling before test_dir is removed.
---
 test/lib/aux.sh | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 6a0b9da93..c773485f5 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -448,6 +448,7 @@ teardown_devs_prefixed() {
 teardown_devs() {
 	# Delete any remaining dm/udev semaphores
 	teardown_udev_cookies
+	restore_dm_mirror
 
 	test ! -f MD_DEV || cleanup_md_dev
 	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
@@ -483,7 +484,6 @@ teardown_devs() {
 			udev_wait
 		}
 	}
-	restore_dm_mirror
 }
 
 kill_sleep_kill_() {
@@ -1394,7 +1394,8 @@ backup_dev() {
 	local dev
 
 	for dev in "$@"; do
-		dd if="$dev" of="${dev}.backup" bs=1024
+		dd if="$dev" of="${dev##*/}.backup" bs=16K conv=fdatasync || \
+			die "Cannot backup device: \"$dev\"  with size $(blockdev --getsize64 "$dev" || true) bytes."
 	done
 }
 
@@ -1402,9 +1403,9 @@ restore_dev() {
 	local dev
 
 	for dev in "$@"; do
-		test -e "${dev}.backup" || \
+		test -e "${dev##*/}.backup" || \
 			die "Internal error: $dev not backed up, can't restore!"
-		dd of="$dev" if="${dev}.backup" bs=1024
+		dd of="$dev" if="${dev##*/}.backup" bs=16K
 	done
 }
 
@@ -1743,9 +1744,9 @@ udev_wait() {
 	pgrep udev >/dev/null || return 0
 	which udevadm &>/dev/null || return 0
 	if test -n "${1-}" ; then
-		udevadm settle --exit-if-exists="$1" || true
+		udevadm settle --exit-if-exists="$1" 2>/dev/null || true
 	else
-		udevadm settle --timeout=15 || true
+		udevadm settle --timeout=15 2>/dev/null || true
 	fi
 }
 

