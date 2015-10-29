From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:56 +0000 (UTC)
Subject: master - tests: let pass bigger readahead
Message-ID: <20151029113956.550A160F37@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f104a81932e1011acb4798402f4f67f78f701a0b
Commit:        f104a81932e1011acb4798402f4f67f78f701a0b
Parent:        3720eb63bed5d087a13d184894197373ebbbaeba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 12:33:15 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:39:07 2015 +0100

tests: let pass bigger readahead

If the underlaying device has actually bigger read-ahead settings,
let it pass.
But anyway switch to 512 strip-size to get really high R-A sector count.
---
 test/shell/read-ahead.sh |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/test/shell/read-ahead.sh b/test/shell/read-ahead.sh
index 82a0707..94465cb 100644
--- a/test/shell/read-ahead.sh
+++ b/test/shell/read-ahead.sh
@@ -21,12 +21,11 @@ SKIP_WITH_LVMPOLLD=1
 aux prepare_vg 5
 
 #COMM "test various read ahead settings (bz450922)"
-lvcreate -l 100%FREE -i5 -I256 -n $lv $vg
+lvcreate -l 100%FREE -i5 -I512 -n $lv $vg
 ra=$(get lv_field $vg/$lv lv_kernel_read_ahead --units s --nosuffix)
-test $(( ( $ra / 5 ) * 5 )) -eq $ra
+test $(( ( $ra / 5 ) * 5 )) -le $ra
 not lvchange -r auto $vg/$lv 2>&1 | grep auto
 check lv_field $vg/$lv lv_read_ahead auto
-check lv_field $vg/$lv lv_kernel_read_ahead 5120 --units s --nosuffix
 lvchange -r 640 $vg/$lv
 check lv_field $vg/$lv lv_read_ahead 640 --units s --nosuffix
 lvremove -ff $vg


