From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:33:05 +0000 (GMT)
Subject: main - test: remove leaked exit
Message-ID: <20220126143305.4C64F3864835@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a425729da9e756a91a5729addb26029216bfd476
Commit:        a425729da9e756a91a5729addb26029216bfd476
Parent:        62f11b0b0b0e4e6aebec5857406b2d4b22406378
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 26 15:32:30 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:32:30 2022 +0100

test: remove leaked exit

---
 test/shell/profiles-cache.sh | 1 -
 1 file changed, 1 deletion(-)

diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
index 47a5cdf2f..60345fd61 100644
--- a/test/shell/profiles-cache.sh
+++ b/test/shell/profiles-cache.sh
@@ -66,7 +66,6 @@ lvcreate -n $lv1 -l 4 -an $vg "$dev1"
 lvcreate -y --type writecache -l 4 --cachevol $lv1 -n $lv2 --metadataprofile $PFILE $vg "$dev2"
 check lv_field $vg/$lv2 cachesettings "high_watermark=60"
 lvremove -y $vg
-exit
 
 # Check chunk_size is grabbed from configuration
 lvcreate -L1G --config 'allocation/cache_pool_chunk_size=512' --type cache-pool $vg/cpool


