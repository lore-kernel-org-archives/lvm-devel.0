From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 Jan 2022 14:10:33 +0000 (GMT)
Subject: main - test: check writecache profile support
Message-ID: <20220126141033.9A3EC385041C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=89cec5b65af5533bcde358d8d4f7d1d5701a341b
Commit:        89cec5b65af5533bcde358d8d4f7d1d5701a341b
Parent:        b95506815fa149cf135687cbe047b7bdfcd6e00f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 24 14:49:53 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 26 15:09:58 2022 +0100

test: check writecache profile support

FIXME
---
 test/shell/profiles-cache.sh  | 10 ++++++++++
 test/shell/writecache-misc.sh |  6 ++++++
 2 files changed, 16 insertions(+)

diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
index 9e17ebf60..47a5cdf2f 100644
--- a/test/shell/profiles-cache.sh
+++ b/test/shell/profiles-cache.sh
@@ -43,6 +43,9 @@ allocation {
 			sequential_threshold = 100
 			random_threshold = 200
 		}
+		writecache {
+			high_watermark = 60
+		}
 	}
 }
 EOF
@@ -58,6 +61,13 @@ EOF
 
 aux prepare_vg 2 1000000
 
+# Check writecache read data from profile
+lvcreate -n $lv1 -l 4 -an $vg "$dev1"
+lvcreate -y --type writecache -l 4 --cachevol $lv1 -n $lv2 --metadataprofile $PFILE $vg "$dev2"
+check lv_field $vg/$lv2 cachesettings "high_watermark=60"
+lvremove -y $vg
+exit
+
 # Check chunk_size is grabbed from configuration
 lvcreate -L1G --config 'allocation/cache_pool_chunk_size=512' --type cache-pool $vg/cpool
 check lv_field $vg/cpool chunksize "512.00k"
diff --git a/test/shell/writecache-misc.sh b/test/shell/writecache-misc.sh
index 80b793256..f62974c54 100644
--- a/test/shell/writecache-misc.sh
+++ b/test/shell/writecache-misc.sh
@@ -52,6 +52,12 @@ aux prepare_devs 4
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
 
 
+# Create writecache without a specified name so it gets automatic name
+lvcreate -n $lv1 -l 4 -an $vg "$dev1"
+lvcreate -y --type writecache -l 4 --cachevol $lv1 $vg "$dev2"
+check lv_exists $vg lvol0
+lvremove -y $vg
+
 #
 # Test pvmove with writecache
 #


