From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 7 Mar 2017 09:18:56 -0500
Subject: master - test: add delay to lvchange-raid1-writemostly.sh
Message-ID: <201703071418.v27EIu4h016692@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43fb4aa69b720301e12a9c0a85e7e778f68f72bf
Commit:        43fb4aa69b720301e12a9c0a85e7e778f68f72bf
Parent:        872932a0fb31af4bb52b575157bc7f93025bfd59
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 7 15:18:13 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 7 15:18:13 2017 +0100

test: add delay to lvchange-raid1-writemostly.sh

Commit 8ab072507706 introduced this new test.

Add a read delay to the PVs to avoid a race
in the script causing the test to fail.

Correct comment.
---
 test/shell/lvchange-raid1-writemostly.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvchange-raid1-writemostly.sh b/test/shell/lvchange-raid1-writemostly.sh
index 1414398..611992a 100644
--- a/test/shell/lvchange-raid1-writemostly.sh
+++ b/test/shell/lvchange-raid1-writemostly.sh
@@ -21,14 +21,14 @@ aux prepare_vg 4
 
 for d in $dev1 $dev2 $dev3 $dev4
 do
-	aux delay_dev $d 1
+	aux delay_dev $d 1 1
 done
 
 #
 # Test writemostly prohibited on resynchronizing raid1
 #
 
-# Create 4-way striped LV
+# Create 4-way raid1 LV
 lvcreate -aey --ty raid1 -m 3 -L 32M -n $lv1 $vg
 not lvchange -y --writemostly $dev1 $vg/$lv1
 check lv_field $vg/$lv1 segtype "raid1"


