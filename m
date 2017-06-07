From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 7 Jun 2017 08:29:00 -0400
Subject: master - test: Update to RAID1 upconvert using recover
Message-ID: <201706071229.v57CT0II004065@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5aa72441c53d6dc356f9b67463934fa5c1bd2a8
Commit:        b5aa72441c53d6dc356f9b67463934fa5c1bd2a8
Parent:        acaf3a5d47fd65b2e385a516544f8e6ec8d89b2d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jun 7 14:26:05 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Jun 7 14:28:31 2017 +0200

test: Update to RAID1 upconvert using recover

Commit 88e649628863 changed upconverting from linear to RAID using
recover instead of resync.
---
 test/shell/lvcreate-large-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index ca3f715..7540c6f 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -101,7 +101,7 @@ lvremove -ff $vg1
 lvcreate -aey -L 200T -n $lv1 $vg1
 lvconvert -y --type raid1 -m 1 $vg1/$lv1
 check lv_field $vg1/$lv1 size "200.00t"
-check raid_leg_status $vg1 $lv1 "aa"
+check raid_leg_status $vg1 $lv1 "Aa"
 lvremove -ff $vg1
 
 # bz837927 END


