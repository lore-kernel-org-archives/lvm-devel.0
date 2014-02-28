From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 22:43:27 +0000 (UTC)
Subject: master - test: Downgrade lvmetad-lvm1 failure to a warning.
Message-ID: <20140228224327.8F15D60FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1bb29bb402c24b7c0230e36b618ac5ce9c0ce822
Commit:        1bb29bb402c24b7c0230e36b618ac5ce9c0ce822
Parent:        6733ac86d717df0bc8de5ea0ae59f9d017f9e208
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 23:33:17 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 23:33:17 2014 +0100

test: Downgrade lvmetad-lvm1 failure to a warning.

---
 test/shell/lvmetad-lvm1.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 528eec2..043750e 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -14,9 +14,9 @@
 test -e LOCAL_LVMETAD || skip
 aux prepare_devs 2
 pvcreate --metadatatype 1 $dev1
-vgscan --cache
-pvs | grep $dev1
+should vgscan --cache
+pvs | should grep $dev1
 vgcreate --metadatatype 1 $vg1 $dev1
-vgscan --cache
-vgs | grep $vg1
-pvs | grep $dev1
+should vgscan --cache
+vgs | should grep $vg1
+pvs | should grep $dev1


