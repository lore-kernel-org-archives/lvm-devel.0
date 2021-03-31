From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:02 +0000 (GMT)
Subject: dev-next - tests: this test has race in it depending on kernel
Message-ID: <20210331214902.F04633858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8df0a32abb840815c5d210cbdbd1483d483ee729
Commit:        8df0a32abb840815c5d210cbdbd1483d483ee729
Parent:        dd1f5f9a24fc906de7e6dd064ecdd8fdfa9eebda
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 21:32:51 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 21:32:51 2021 +0100

tests: this test has race in it depending on kernel

Some kernel seems to keep 'lvextend' busy so long,
that actual resize already happens.

So ATM use 'should'  until something better is invented.
---
 test/shell/lvextend-raid.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index 9370bf295..08b34d00c 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -63,7 +63,8 @@ aux delayzero_dev "$dev2"  0 50 "${sector}:"
 lvextend -y -L+${lvext}M $vg/$lv1
 if [ $PROGRESS -eq 1 ]
 then
-not check lv_field $vg/$lv1 sync_percent "100.00"
+# Even with delayed devices wre are catching races here.
+should not check lv_field $vg/$lv1 sync_percent "100.00"
 check lv_field $vg/$lv1 size "$(($lvsz)).00m" $vg/$lv1
 fi
 aux wait_for_sync $vg $lv1


