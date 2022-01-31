From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 31 Jan 2022 14:18:38 +0000 (GMT)
Subject: main - tests: skip test part when missed in kernel
Message-ID: <20220131141838.00FF83858C20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=208af8db2afbf6941a7c71d8537e9ec3f60f4e79
Commit:        208af8db2afbf6941a7c71d8537e9ec3f60f4e79
Parent:        b36fce26a29cece9f3e11f081e9ac44c90a0ab0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 31 15:11:47 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 31 15:11:47 2022 +0100

tests: skip test part when missed in kernel

---
 test/shell/profiles-cache.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
index 60345fd61..b408130f4 100644
--- a/test/shell/profiles-cache.sh
+++ b/test/shell/profiles-cache.sh
@@ -62,10 +62,12 @@ EOF
 aux prepare_vg 2 1000000
 
 # Check writecache read data from profile
+if aux have_writecache 1 0 0 ; then
 lvcreate -n $lv1 -l 4 -an $vg "$dev1"
 lvcreate -y --type writecache -l 4 --cachevol $lv1 -n $lv2 --metadataprofile $PFILE $vg "$dev2"
 check lv_field $vg/$lv2 cachesettings "high_watermark=60"
 lvremove -y $vg
+fi
 
 # Check chunk_size is grabbed from configuration
 lvcreate -L1G --config 'allocation/cache_pool_chunk_size=512' --type cache-pool $vg/cpool


