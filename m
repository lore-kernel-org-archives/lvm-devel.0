From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 14 Oct 2019 09:22:47 -0400
Subject: master - tests: drop manipulation with 'internal' LV
Message-ID: <201910141322.x9EDMlLe018864@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c70bab75311def1a52a42a109737184e1982949c
Commit:        c70bab75311def1a52a42a109737184e1982949c
Parent:        1cd308d6406d297591c9a9f3ee043efe9150203b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 12 23:56:55 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 14 15:20:25 2019 +0200

tests: drop manipulation with 'internal' LV

Cachevol LV is 'internal' LV and should not be 'maintained'  this way
while it's being used as cachevol.
---
 test/shell/cache-single-split.sh |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/shell/cache-single-split.sh b/test/shell/cache-single-split.sh
index 3224ea1..7fc1786 100644
--- a/test/shell/cache-single-split.sh
+++ b/test/shell/cache-single-split.sh
@@ -131,7 +131,6 @@ check lv_field $vg/$lv1 segtype "cache"
 check lv_field $vg/$lv1 cachemode "writeback"
 
 lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
 
 mkfs_mount_umount $lv1
 
@@ -156,7 +155,6 @@ check lv_field $vg/$lv1 segtype "cache"
 check lv_field $vg/$lv1 cachemode "writethrough"
 
 lvchange -an $vg/$lv1
-lvchange -an $vg/$lv2
 
 mkfs_mount_umount $lv1
 


