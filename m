From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:37:52 -0500
Subject: master - tests: cache profile and metadata2
Message-ID: <201703101837.v2AIbqRI020261@int-mx09.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53f5cf0af000f9c80b320e57eb44ba76d2ccf7a2
Commit:        53f5cf0af000f9c80b320e57eb44ba76d2ccf7a2
Parent:        a11b875074936fa7ae357133f1e2e3f18ebdc3eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 10 19:01:46 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:02 2017 +0100

tests: cache profile and metadata2

New tests trying to cover support syntax variants.
A lot it still missing...
---
 test/shell/cache-metadata2.sh        |   83 ++++++++++++++++++++
 test/shell/lvconvert-cache-chunks.sh |    6 +-
 test/shell/profiles-cache.sh         |  141 ++++++++++++++++++++++++++++++++++
 3 files changed, 228 insertions(+), 2 deletions(-)

diff --git a/test/shell/cache-metadata2.sh b/test/shell/cache-metadata2.sh
new file mode 100644
index 0000000..acf6d0d
--- /dev/null
+++ b/test/shell/cache-metadata2.sh
@@ -0,0 +1,83 @@
+#!/bin/sh
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise usage of metadata2 cache metadata format
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+# Until new version of cache_check tools - no integrity validation
+LVM_TEST_CACHE_CHECK_CMD=""
+
+. lib/inittest
+
+META2=
+aux have_cache 1 10 0 || {
+	META2=not
+	aux have_cache 1 3 0 || skip
+}
+
+aux prepare_vg 5 80
+
+lvcreate -L2 -n $lv1 $vg
+
+lvcreate --type cache-pool -L1 $vg/cpool1
+# no parameter - no format is stored
+check lv_field $vg/cpool1 cachemetadataformat ""
+
+lvcreate --type cache-pool -L1 --config 'allocation/cache_metadata_format=1' $vg/cpool
+# format is in configuration - would be applied during actual caching
+# so not stored in this moment
+check lv_field $vg/cpool cachemetadataformat ""
+
+
+lvcreate --type cache-pool -L1 --cachemetadataformat 1 $vg/cpool2
+# format was specified on cmdline  - preserve it metadata
+check lv_field $vg/cpool2 cachemetadataformat "1"
+
+lvconvert --yes -H --cachepool $vg/cpool --config 'allocation/cache_metadata_format=1' $vg/$lv1
+check lv_field $vg/cpool2 cachemetadataformat "1"
+
+lvs -a -o+cachemetadataformat $vg
+
+lvremove -f $vg
+
+if [ -z "$META2" ]; then
+# for these test we need kernel with metadata2 support
+
+lvcreate --type cache-pool -L1 $vg/cpool
+lvcreate -H -L10 -n $lv1 --cachepool $vg/cpool
+check lv_field $vg/$lv1 cachemetadataformat "2"
+lvremove -f $vg
+
+lvcreate -L10 -n $lv1 $vg
+lvcreate --type cache-pool -L1 $vg/cpool
+lvconvert -y -H --cachepool $vg/cpool $vg/$lv1
+check lv_field $vg/$lv1 cachemetadataformat "2"
+lvremove -f $vg
+
+
+lvcreate -L10 -n $lv1 $vg
+lvcreate --type cache-pool -L1 $vg/cpool
+lvconvert --cachemetadataformat 1 -y -H --cachepool $vg/cpool $vg/$lv1
+check lv_field $vg/$lv1 cachemetadataformat "1"
+lvremove -f $vg
+
+lvcreate -L10 -n $lv1 $vg
+lvcreate --type cache-pool -L1 $vg/cpool
+lvconvert --config 'allocation/cache_metadata_format=1' -y -H --cachepool $vg/cpool $vg/$lv1
+check lv_field $vg/$lv1 cachemetadataformat "1"
+lvremove -f $vg
+
+fi
+#lvs -a -o name,cachemetadataformat,kernelmetadataformat,chunksize,cachepolicy,cachemode $vg
+
+vgremove -f $vg
diff --git a/test/shell/lvconvert-cache-chunks.sh b/test/shell/lvconvert-cache-chunks.sh
index 4631e0e..918b55d 100644
--- a/test/shell/lvconvert-cache-chunks.sh
+++ b/test/shell/lvconvert-cache-chunks.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2016 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2016-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -33,7 +33,9 @@ test $(get lv_field $vg/cpool chunk_size --units s --nosuffix) -gt 1000
 lvcreate -L1M -n $lv1 $vg
 
 # Not let pass small chunks when caching origin
-fail lvconvert -H --chunksize 128K --cachepool $vg/cpool $vg/$lv1
+fail lvconvert -H --chunksize 128K --cachepool $vg/cpool $vg/$lv1 >out 2>&1
+cat out
+grep "too small chunk size" out
 
 # Thought 2M is valid
 if aux have_cache 1 8 0 ; then
diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
new file mode 100644
index 0000000..8b27f20
--- /dev/null
+++ b/test/shell/profiles-cache.sh
@@ -0,0 +1,141 @@
+#!/bin/sh
+# Copyright (C) 2017 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Exercise obtaining cache parameter from various sources
+# Either commmand line or metadata profile or implicit default...
+
+SKIP_WITH_LVMLOCKD=1
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+PDIR="$LVM_SYSTEM_DIR/profile"
+PFILE="cache-test"
+
+aux prepare_profiles
+
+cat <<EOF > $PDIR/${PFILE}.profile
+allocation {
+	cache_pool_chunk_size = 128
+	cache_mode = "writeback"
+	cache_policy = "mq"
+	cache_metadata_format = 1
+
+	cache_settings {
+		smq {
+			sequential_threshold = 300
+			random_threshold = 500
+		}
+		mq {
+		}
+		mq {
+			sequential_threshold = 100
+			random_threshold = 200
+		}
+	}
+}
+EOF
+
+cat <<EOF > $PDIR/${PFILE}1.profile
+allocation {
+	cache_pool_chunk_size = 512
+	cache_mode = "passthrough"
+	cache_policy = "smq"
+	cache_metadata_format = 1
+}
+EOF
+
+aux prepare_vg 2 1000000
+
+# Check chunk_size is grabbed from configuration
+lvcreate -L1G --config 'allocation/cache_pool_chunk_size=512' --type cache-pool $vg/cpool
+check lv_field $vg/cpool chunksize "512.00k"
+
+# Check chunk_size can be overruled when caching LV.
+lvcreate -H --chunksize 128K -L10 --cachepool $vg/cpool -n $lv1
+check lv_field $vg/$lv1 chunksize "128.00k"
+
+lvremove -f $vg
+
+
+# Check chunk_size is grabbed from metadata profile
+lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+#lvcreate -L1G --commandprofile $PFILE --type cache-pool $vg/cpool
+
+# profile name is stored with cache-pool
+check lv_field $vg/cpool profile "$PFILE"
+# cache chunk size is selected and stored on creation time
+check lv_field $vg/cpool chunksize "128.00k"
+# cache metadata format is not stored with cache-pool
+check lv_field $vg/cpool cachemetadataformat ""
+# cache mode is not stored with cache-pool
+check lv_field $vg/cpool cachemode ""
+# cache policy is not stored with cache-pool
+check lv_field $vg/cpool cachepolicy ""
+# cache settings are not stored with cache-pool
+check lv_field $vg/cpool cachesettings ""
+
+
+lvcreate -L10 -n $lv1 $vg
+lvconvert --metadataprofile ${PFILE}1 -y -H --cachepool $vg/cpool $vg/$lv1
+# chunk size 128k is replace with 512k from PFILE1
+check lv_field $vg/$lv1 chunksize "512.00k"
+# cachemode is from PFILE1
+check lv_field $vg/$lv1 cachemode "passthrough"
+lvremove -f $vg
+
+lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+lvcreate -H -L10 -n $lv1 --cachepool $vg/cpool
+# profile name is stored with cache
+check lv_field $vg/$lv1 profile "$PFILE"
+# cache chunk size is selected and stored on creation time
+check lv_field $vg/$lv1 chunksize "128.00k"
+# cache metadata format is stored with cache
+check lv_field $vg/$lv1 cachemetadataformat "1"
+# cache mode is stored with cache
+check lv_field $vg/$lv1 cachemode "writeback"
+# cache policy is stored with cache
+check lv_field $vg/$lv1 cachepolicy "mq"
+# cache settings are stored with cache
+check lv_field $vg/$lv1 cachesettings "sequential_threshold=100,random_threshold=200"
+
+lvremove -f $vg
+
+#####
+
+lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+lvcreate --cachesettings 'sequential_threshold=300'  -H -L10 -n $lv1 --cachepool $vg/cpool
+check lv_field $vg/$lv1 profile "$PFILE"
+check lv_field $vg/$lv1 cachesettings "sequential_threshold=300"
+lvremove -f $vg
+
+#####
+
+lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+lvcreate --chunksize 256    -H -L10 -n $lv1 --cachepool $vg/cpool
+check lv_field $vg/$lv1 cachemode "writeback"
+check lv_field $vg/$lv1 chunksize "256.00k"
+lvremove -f $vg
+
+
+#####
+
+lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+lvcreate --metadataprofile ${PFILE}1   -H -L10 -n $lv1 --cachepool $vg/cpool
+check lv_field $vg/$lv1 chunksize "512.00k"
+check lv_field $vg/$lv1 cachemode "passthrough"
+lvremove -f $vg
+
+#lvs -a -o+chunksize,cachemode,cachemetadataformat,cachepolicy,cachesettings $vg
+
+vgremove -ff $vg


