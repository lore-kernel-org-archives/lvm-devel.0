From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Sat, 22 Apr 2017 01:50:38 -0400
Subject: master - test: add raid4 to upconvert allocation failure tests
Message-ID: <201704220550.v3M5ocYn014998@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=effeb2b93d4840b906b1bfa45d05bea9ff8d11e6
Commit:        effeb2b93d4840b906b1bfa45d05bea9ff8d11e6
Parent:        149e4fa04b68da8979936ea3eb5bc68fb27127b2
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Apr 22 00:43:31 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Apr 22 00:43:31 2017 +0200

test: add raid4 to upconvert allocation failure tests

---
 .../shell/lvconvert-raid-takeover-alloc-failure.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-raid-takeover-alloc-failure.sh b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
index 7cb8378..3870c35 100644
--- a/test/shell/lvconvert-raid-takeover-alloc-failure.sh
+++ b/test/shell/lvconvert-raid-takeover-alloc-failure.sh
@@ -49,6 +49,10 @@ function check_no_sub_lvs
 
 # 6-way striped: neither conversion to raid5 nor raid6 possible
 lvcreate --yes --stripes 6 --size 4M --name $lv1 $vg
+not lvconvert --yes --type raid4 $vg/$lv1
+check lv_field $vg/$lv1 segtype "striped"
+check_no_sub_lvs $vg $lv1 0 5
+
 not lvconvert --yes --type raid5 $vg/$lv1
 check lv_field $vg/$lv1 segtype "striped"
 check_no_sub_lvs $vg $lv1 0 5


