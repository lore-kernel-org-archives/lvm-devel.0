From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 19 Oct 2020 15:56:32 +0000 (GMT)
Subject: stable-2.02 - blkdeactivate: add missing VDO_AVAILABLE check in deactivate_vdo
Message-ID: <20201019155632.74FC7388EC0D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa4f1f117a355c7046a348fd217fdfab20242ae6
Commit:        aa4f1f117a355c7046a348fd217fdfab20242ae6
Parent:        2c048bd77d669f77825455b8e5110c80beff7da5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 8 15:41:35 2020 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Oct 19 16:02:20 2020 +0200

blkdeactivate: add missing VDO_AVAILABLE check in deactivate_vdo

(cherry picked from commit 8806f2d5ed4792042b246b930fb44f24b9ee45c2)
---
 scripts/blkdeactivate.sh.in | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 57b3e58bf..7c517b87b 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -330,6 +330,12 @@ deactivate_vdo() {
         test -b "$DEV_DIR/mapper/$xname" || return 0
         test -z "${SKIP_DEVICE_LIST["$kname"]}" || return 1
 
+	# Skip VDO device deactivation if VDO tools missing.
+	test "$VDO_AVAILABLE" -eq 0 && {
+		add_device_to_skip_list
+		return 1
+	}
+
         deactivate_holders "$DEV_DIR/mapper/$xname" || return 1
 
         echo -n "  [VDO]: deactivating VDO volume $xname... "


