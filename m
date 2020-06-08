From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Mon,  8 Jun 2020 13:42:15 +0000 (GMT)
Subject: master - blkdeactivate: add missing VDO_AVAILABLE check in deactivate_vdo
Message-ID: <20200608134215.91301385DC00@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8806f2d5ed4792042b246b930fb44f24b9ee45c2
Commit:        8806f2d5ed4792042b246b930fb44f24b9ee45c2
Parent:        fa9eb76a5dc8d76a1f06a44337f909c75df1fee9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 8 15:41:35 2020 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 8 15:41:35 2020 +0200

blkdeactivate: add missing VDO_AVAILABLE check in deactivate_vdo

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


