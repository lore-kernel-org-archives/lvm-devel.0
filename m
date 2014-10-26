From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:38:00 +0000 (UTC)
Subject: master - tests: lvcreate-update
Message-ID: <20141026173800.4FF5E60236@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7bbf3cf3066a62c19e5ec439f658ae5253edaace
Commit:        7bbf3cf3066a62c19e5ec439f658ae5253edaace
Parent:        70616187b32ee890eae8e8607c2d247d16cd6787
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 07:29:25 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

tests: lvcreate-update

Test with old mirror type.
---
 test/shell/lvcreate-usage.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index c2b7112..05f2515 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -114,10 +114,10 @@ lvremove -f $vg
 # - nonzero (bz186013)
 # - a power of 2 and a multiple of page size
 # - <= size of LV
-invalid lvcreate -m 1 -L 32m -n $lv -R 0 $vg 2>err
+invalid lvcreate --type mirror -m 1 -L 32m -n $lv -R 0 $vg 2>err
 grep "may not be zero" err
-invalid lvcreate -m 1 -L 32m -n $lv -R 11k $vg
-invalid lvcreate -m 1 -L 32m -n $lv -R 1k $vg
+invalid lvcreate --type mirror -m 1 -L 32m -n $lv -R 11k $vg
+invalid lvcreate --type mirror -m 1 -L 32m -n $lv -R 1k $vg
 lvcreate -aey -L 32m -n $lv --regionsize 128m  --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "32.00m"
 lvremove -f $vg


