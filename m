From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 18 Mar 2010 15:53:07 -0500
Subject: [PATCH 2 of 12] LVM: testsuite fixes 2
Message-ID: <201003182053.o2IKr7AX024453@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-testsuite-fixes-2.patch

Flip the 'not' on a test that should be working.

Index: LVM2/test/t-lvconvert-repair.sh
===================================================================
--- LVM2.orig/test/t-lvconvert-repair.sh
+++ LVM2/test/t-lvconvert-repair.sh
@@ -69,5 +69,5 @@ vgextend $vg $dev3
 lvcreate -m 2 -l 1 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4
 vgchange -a n $vg
 pvremove -ff -y $dev4
-echo 'y' | not lvconvert -y -i 1 --repair $vg/mirror2
+echo 'y' | lvconvert -y -i 1 --repair $vg/mirror2
 vgs


