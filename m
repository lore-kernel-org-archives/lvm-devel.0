From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 18 Feb 2014 09:39:42 +0000 (UTC)
Subject: master - tests: use exclusive activation for mirror case
Message-ID: <20140218093942.CC23060DB0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0e0f91b6ddcdd338bcd528b3f44eb3f019704fb3
Commit:        0e0f91b6ddcdd338bcd528b3f44eb3f019704fb3
Parent:        b1e8284f339cb412b83f730783ee8a06feac9341
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 18 10:36:53 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 18 10:39:29 2014 +0100

tests: use exclusive activation for mirror case

Since mirror doesn't take exclusive lock implicitely yet,
enforce it for cluster testing.
---
 test/shell/lvchange-partial.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 4e508a9..b79004d 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -17,7 +17,7 @@ aux prepare_vg 4
 TYPE=raid1
 aux target_at_least dm-raid 1 1 0 || TYPE=mirror
 
-lvcreate --type $TYPE -m 1 -l 2 -n $lv1 $vg
+lvcreate -aey --type $TYPE -m 1 -l 2 -n $lv1 $vg
 lvchange -an $vg/$lv1
 aux disable_dev "$dev1"
 


