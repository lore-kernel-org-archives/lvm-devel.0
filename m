From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 14:19:44 +0000 (UTC)
Subject: master - tests: make test usable in cluster
Message-ID: <20140317141944.2F7A3610C0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2c544dc91d8712b49c44aeea2241b37044eedac
Commit:        a2c544dc91d8712b49c44aeea2241b37044eedac
Parent:        ae2d80dd7e3379e62be610e56114ebba02a0eac2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 15:18:20 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 15:18:20 2014 +0100

tests: make test usable in cluster

Origin needs exclusive activation
---
 test/shell/lvconvert-snapshot.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index 4a650d2..e38d69b 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -20,7 +20,7 @@ vgcreate -s 1k $vg $(cat DEVICES)
 
 lvcreate -V50 -L1 -n $lv1 -s $vg
 
-lvcreate -L1 -n $lv2 $vg
+lvcreate -aey -L1 -n $lv2 $vg
 lvcreate -L1 -s -n $lv3 $vg/$lv2
 
 lvcreate -l1 -n $lv4 $vg


