From: okozina <okozina@fedoraproject.org>
Date: Mon, 30 Mar 2015 16:43:09 +0000 (UTC)
Subject: master - tests: fix check for existence of a pvmove Lv
Message-ID: <20150330164309.898F560905@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c8caa04b1c58e1590654b405d1a6d34cd30c7b4f
Commit:        c8caa04b1c58e1590654b405d1a6d34cd30c7b4f
Parent:        f1e3e9916966a2ebdaf9315f929c1f34e326f6e0
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Mar 27 15:42:11 2015 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Mar 30 18:38:50 2015 +0200

tests: fix check for existence of a pvmove Lv

---
 test/shell/pvmove-basic.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index e5add05..1b9b63f 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -69,8 +69,8 @@ check_and_cleanup_lvs_() {
 	check dev_md5sum $vg $lv1
 	check dev_md5sum $vg $lv2
 	check dev_md5sum $vg $lv3
-	get lv_field $vg name >out
-	not grep ^pvmove out
+	get lv_field $vg name -a >out
+	not grep "^\[pvmove" out
 	vgchange -an $vg
 	lvremove -ff $vg
 	(dm_table | not grep $vg) || \


