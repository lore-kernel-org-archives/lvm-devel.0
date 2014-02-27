From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Feb 2014 13:55:38 +0000 (UTC)
Subject: master - tests: quote dev
Message-ID: <20140227135538.E034160FA4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c23cd12023bd18a83ae0f284e69f3b6689d79b37
Commit:        c23cd12023bd18a83ae0f284e69f3b6689d79b37
Parent:        f4afd07700986b368c7ea8543f04f8e2dfc02a8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 27 14:49:49 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 27 14:49:49 2014 +0100

tests: quote dev

---
 test/shell/vgck.sh |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgck.sh b/test/shell/vgck.sh
index 0dec605..40af20a 100644
--- a/test/shell/vgck.sh
+++ b/test/shell/vgck.sh
@@ -14,7 +14,7 @@
 aux prepare_vg 3
 lvcreate -n blabla -L 1 $vg
 
-dd if=/dev/urandom bs=512 seek=2 count=32 of=$dev2
+dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
 
 # TODO: aux lvmconf "global/locking_type = 4"
 
@@ -26,7 +26,9 @@ else
     grep "Inconsistent metadata found for VG $vg" vgscan.out
 fi
 
-dd if=/dev/urandom bs=512 seek=2 count=32 of=$dev2
+dd if=/dev/urandom bs=512 seek=2 count=32 of="$dev2"
+aux notify_lvmetad "$dev2"
+
 vgck $vg 2>&1 | tee vgck.out
 grep Incorrect vgck.out
 


