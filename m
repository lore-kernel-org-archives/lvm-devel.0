From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:33:12 +0000 (UTC)
Subject: master - tests: duplicate update of config
Message-ID: <20141104143312.53A73608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cebbda0931e43097a148bbf2c4b8a1de1c77d9fa
Commit:        cebbda0931e43097a148bbf2c4b8a1de1c77d9fa
Parent:        00a45ca491de21336f8d1d0253344995cea3b4f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 15:07:40 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:29:22 2014 +0100

tests: duplicate update of config

---
 test/shell/thin-volume-list.sh |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/test/shell/thin-volume-list.sh b/test/shell/thin-volume-list.sh
index 31f4034..32d13b8 100644
--- a/test/shell/thin-volume-list.sh
+++ b/test/shell/thin-volume-list.sh
@@ -22,6 +22,7 @@ aux prepare_vg 2
 
 lvcreate -T -L8M $vg/pool -V10M -n $lv1
 
+# skip $vg from activation
 aux lvmconf "activation/volume_list = [ \"$vg1\" ]"
 
 # We still could pass - since pool is still active
@@ -32,9 +33,6 @@ check inactive $vg $lv2
 
 vgchange -an $vg
 
-# skip $vg from activation
-aux lvmconf "activation/volume_list = [ \"$vg1\" ]"
-
 # Pool is not active - so it cannot create thin volume
 not lvcreate -V10 -T $vg/pool
 


