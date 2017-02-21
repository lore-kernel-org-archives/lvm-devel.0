From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 21 Feb 2017 08:43:55 +0000 (UTC)
Subject: master - tests: make sure which PV is used for allocation
Message-ID: <20170221084355.EA63360FB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7c14004f69f18aeb6fbb022f0ef81f109177022c
Commit:        7c14004f69f18aeb6fbb022f0ef81f109177022c
Parent:        d409fec079d27c349b4e570a619bd860ce4fde7e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 21 09:38:04 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 21 09:38:04 2017 +0100

tests: make sure which PV is used for allocation

---
 test/shell/lvm1-basic.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvm1-basic.sh b/test/shell/lvm1-basic.sh
index 8884bc1..166d5bf 100644
--- a/test/shell/lvm1-basic.sh
+++ b/test/shell/lvm1-basic.sh
@@ -28,7 +28,7 @@ grep "$dev1" out
 # check for RHBZ 1080189 -- SEGV in lvremove/vgremove
 pvcreate -ff -y --metadatatype 1 "$dev1" "$dev2"
 vgcreate --metadatatype 1 $vg1 "$dev1" "$dev2"
-lvcreate -l1 $vg1
+lvcreate -l1 $vg1 "$dev1"
 pvremove -ff -y "$dev2"
 vgchange -an $vg1
 not lvremove $vg1


