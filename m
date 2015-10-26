From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Oct 2015 06:39:14 +0000 (UTC)
Subject: master - tests: snapshot now respects threshold
Message-ID: <20151026063914.7E70660EE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b29593378f41f6dd401fb9582fba1a100f33dbbb
Commit:        b29593378f41f6dd401fb9582fba1a100f33dbbb
Parent:        428ca9b1207eba53ffc721bd9e528a1a148128c2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 26 07:38:23 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 07:38:23 2015 +0100

tests: snapshot now respects threshold

---
 test/shell/snapshot-usage.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index ed9d8cb..d15eee1 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -169,13 +169,13 @@ lvcreate -s -l12 $vg1/lvol0
 fill 1K
 check lv_field $vg1/lvol1 data_percent "100.00"
 
-# Check it resizes 100% full valid snapshot
+# Check it resizes 100% full valid snapshot to fit threshold
 lvextend --use-policies $vg1/lvol1
-check lv_field $vg1/lvol1 data_percent "80.00"
+check lv_field $vg1/lvol1 data_percent "50.00"
 
 fill 4K
 lvextend --use-policies $vg1/lvol1
-check lv_field $vg1/lvol1 size "18.00k"
+check lv_field $vg1/lvol1 size "24.00k"
 
 lvextend -l+33 $vg1/lvol1
 check lv_field $vg1/lvol1 size "$EXPECT3"


