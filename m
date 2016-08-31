From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 31 Aug 2016 09:14:03 +0000 (UTC)
Subject: master - tests: skip test for older cache target
Message-ID: <20160831091403.EDD76614B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a4267ade462e9066fbe70076da0eff679b3cdb6
Commit:        3a4267ade462e9066fbe70076da0eff679b3cdb6
Parent:        b26604c8d84a189fc3ee276d6e8711a49eecd831
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 30 13:28:36 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 31 11:13:59 2016 +0200

tests: skip test for older cache target

Some test on older can targets are not going to work, and
since there is no other fix then using newer kernel - skip
such tests completely.
---
 test/shell/lvconvert-cache-chunks.sh |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-cache-chunks.sh b/test/shell/lvconvert-cache-chunks.sh
index 806db0f..4631e0e 100644
--- a/test/shell/lvconvert-cache-chunks.sh
+++ b/test/shell/lvconvert-cache-chunks.sh
@@ -10,6 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 # Exercise number of cache chunks in cache pool
+# Skips creation of real cached device for older cache targets...
 
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
@@ -34,8 +35,11 @@ lvcreate -L1M -n $lv1 $vg
 # Not let pass small chunks when caching origin
 fail lvconvert -H --chunksize 128K --cachepool $vg/cpool $vg/$lv1
 
-# Though 2M is valid
-lvconvert -y -H  --chunksize 2M --cachepool $vg/cpool $vg/$lv1
+# Thought 2M is valid
+if aux have_cache 1 8 0 ; then
+	# Without SMQ we run out of kernel memory easily
+	lvconvert -y -H  --chunksize 2M --cachepool $vg/cpool $vg/$lv1
+fi
 
 lvremove -f $vg
 
@@ -46,8 +50,10 @@ lvcreate -L1T -n cpool $vg
 # Not allowed to create more then 10e6 chunks
 fail lvconvert -y --type cache-pool --chunksize 128K $vg/cpool
 
-# Let operation pass when max_chunk limit is raised
-lvconvert -y --type cache-pool --chunksize 128K $vg/cpool \
-	--config 'allocation/cache_pool_max_chunks=10000000'
+if aux have_cache 1 8 0 ; then
+	# Let operation pass when max_chunk limit is raised
+	lvconvert -y --type cache-pool --chunksize 128K $vg/cpool \
+		--config 'allocation/cache_pool_max_chunks=10000000'
+fi
 
 vgremove -f $vg


