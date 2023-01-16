From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:17 +0000 (GMT)
Subject: main - tests: vdo resizing
Message-ID: <20230116113917.7803C3858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa09232dc4fb825f4e643bbe87a95e2318dd5a93
Commit:        aa09232dc4fb825f4e643bbe87a95e2318dd5a93
Parent:        c20f01a0cbb24e8276734a00f26a510cf6daaf21
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 16 01:11:37 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:40 2023 +0100

tests: vdo resizing

---
 test/shell/lvresize-vdo.sh | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/test/shell/lvresize-vdo.sh b/test/shell/lvresize-vdo.sh
index 6fe0e9c26..cbe8ce967 100644
--- a/test/shell/lvresize-vdo.sh
+++ b/test/shell/lvresize-vdo.sh
@@ -32,4 +32,19 @@ check lv_field $vg/${lv2}_vdata size "6.00g"
 lvresize -L6G $vg/$lv1
 check lv_field $vg/$lv1 size "6.00g"
 
+# Check too large size
+not lvresize -L4P $vg/$lv1 2>err
+grep "Volume too large" err
+
+# Can't resize inactive VDO
+lvchange -an $vg
+not lvresize -L10G $vg/$lv1  2>err
+grep "Cannot resize inactive" err
+
+not lvresize -L10G $vg/$lv2 2>err
+grep "Cannot resize inactive" err
+
+not lvresize -L10G $vg/${lv2}_vdata 2>err
+grep "Cannot resize inactive" err
+
 vgremove -ff $vg

