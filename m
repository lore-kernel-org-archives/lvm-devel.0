From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 Jun 2014 15:54:37 +0000 (UTC)
Subject: master - tests: use get_devs
Message-ID: <20140605155437.3C01E61100@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54da0ea61afece94445754d3e0a8fd5e0964f1e4
Commit:        54da0ea61afece94445754d3e0a8fd5e0964f1e4
Parent:        77d4e317a44213baff566f6b13b4a7d930f446b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 5 13:01:43 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 5 17:49:35 2014 +0200

tests: use get_devs

Check how get_devs is usable with shell array DEVICES
---
 test/shell/covercmd.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/covercmd.sh b/test/shell/covercmd.sh
index a036d92..d7dde5b 100644
--- a/test/shell/covercmd.sh
+++ b/test/shell/covercmd.sh
@@ -17,6 +17,7 @@
 . lib/test
 
 aux prepare_pvs 5
+get_devs
 
 pvcreate --metadatacopies 0 "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
@@ -24,7 +25,7 @@ pvcreate --metadatacopies 0 "$dev3"
 # FIXME takes very long time
 #pvck "$dev1"
 
-vgcreate $vg $(cat DEVICES)
+vgcreate $vg "${DEVICES[@]}"
 
 lvcreate -l 5 -i5 -I256 -n $lv $vg
 lvcreate -aey -l 5 -n $lv1 $vg


