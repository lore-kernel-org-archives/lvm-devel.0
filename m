From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:52 +0000 (UTC)
Subject: master - tests: no point in using should
Message-ID: <20151029113952.17CD860E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b5525383f2070a6df8508bfe5696324ca6acb54
Commit:        8b5525383f2070a6df8508bfe5696324ca6acb54
Parent:        f58c63410327c2bc49b671df4538dee9e90e577d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 12:23:38 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:39:07 2015 +0100

tests: no point in using should

lvmetad does not support lvm1 - so expect failure.
---
 test/shell/lvmetad-lvm1.sh |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvmetad-lvm1.sh b/test/shell/lvmetad-lvm1.sh
index 3b14fdd..c1b34ea 100644
--- a/test/shell/lvmetad-lvm1.sh
+++ b/test/shell/lvmetad-lvm1.sh
@@ -14,14 +14,19 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# lvmetad does not support lvm1 format
+
 aux prepare_devs 2
 pvcreate --metadatatype 1 "$dev1"
-should vgscan --cache
-pvs | should grep "$dev1"
+not vgscan --cache
+pvs | tee out
+not grep "$dev1" out
 vgcreate --metadatatype 1 $vg1 "$dev1"
-should vgscan --cache
-vgs | should grep $vg1
-pvs | should grep "$dev1"
+not vgscan --cache
+vgs | tee out
+not grep $vg1 out
+pvs | tee out
+not grep "$dev1" out
 
 # check for RHBZ 1080189 -- SEGV in lvremove/vgremove
 pvcreate -ff -y --metadatatype 1 "$dev1" "$dev2"


