From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  7 Sep 2016 14:44:17 +0000 (UTC)
Subject: master - tests: lower allocated memory
Message-ID: <20160907144417.75F4B60734@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a13440d7ca4268eeede9986223d31e33122e753a
Commit:        a13440d7ca4268eeede9986223d31e33122e753a
Parent:        6064a5084e2a71db389b1bdf06c05765610295d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 7 16:43:42 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 16:43:42 2016 +0200

tests: lower allocated memory

Use  smaller mirror to have faster sync.
TODO: switch to delayed devs...
---
 test/shell/lvconvert-raid-takeover.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 2ead582..fd327ad 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -23,7 +23,7 @@ aux prepare_vg 9 288
 # aux delay_dev "$dev1" 0 1
 
 # Create 3-way mirror
-lvcreate --yes --type mirror -m 2 -L 256M -n $lv1 $vg
+lvcreate --yes --type mirror -m 2 -L 64M -n $lv1 $vg
 check lv_field $vg/$lv1 segtype "mirror"
 check lv_field $vg/$lv1 stripes 3
 echo y | mkfs -t ext4 /dev/mapper/$vg-$lv1


