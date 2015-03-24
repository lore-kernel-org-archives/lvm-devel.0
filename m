From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 Mar 2015 08:51:36 +0000 (UTC)
Subject: master - tests: select-tools.sh: add test for fix in commit c9f021de0b4d2c873ef5b97d17c602d0380359fd
Message-ID: <20150324085136.1C4B6610FF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9dbe2d760f3810463ffa416e82f89766b12b0071
Commit:        9dbe2d760f3810463ffa416e82f89766b12b0071
Parent:        8759f7d755cec7286d1bccda3a323b12481d5738
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 24 09:50:35 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 24 09:50:35 2015 +0100

tests: select-tools.sh: add test for fix in commit c9f021de0b4d2c873ef5b97d17c602d0380359fd

---
 test/shell/select-tools.sh |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index d04ed0a..975ebdb 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -273,3 +273,18 @@ pvchange -a --deltag 309 --deltag tag
 # iterates over LVs with process_each_lv_in_vg - so internally it actually
 # operates per-LV, but we still need the selection to be done per-VG)
 vgremove --yes -S 'lv_name=lv2' # should remove whole vg1, not just the lv2
+
+# if calling lvremove and an LV is removed that is related to other LV
+# and we're doing selection based on this relation, check if we're
+# selecting on initial state (here, thin origin LV thin_orig is removed
+# first, but thin snap should be still selectable based on origin=thin_orig
+# condition even though thin_orig has just been removed)
+vgcreate -s 4m $vg1 $dev1 $dev2
+lvcreate -l100%FREE -T $vg1/pool
+lvcreate -V4m -T $vg1/pool -n thin_orig
+lvcreate -s $vg1/thin_orig -n thin_snap
+lvremove -ff -S 'lv_name=thin_orig || origin=thin_orig' > out
+grep "Logical volume \"thin_orig\" successfully removed" out
+grep "Logical volume \"thin_snap\" successfully removed" out
+not lvs $vg1/thin_orig
+not lvs $vg1/thin_snap


