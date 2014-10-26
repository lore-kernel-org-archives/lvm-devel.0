From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 26 Oct 2014 17:38:02 +0000 (UTC)
Subject: master - tests: update cache creation tests
Message-ID: <20141026173802.6293060236@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c28a7706ed00c135e6fb06d22dde1c374f32f847
Commit:        c28a7706ed00c135e6fb06d22dde1c374f32f847
Parent:        7bbf3cf3066a62c19e5ec439f658ae5253edaace
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 16:19:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Oct 26 18:37:13 2014 +0100

tests: update cache creation tests

---
 test/shell/lvcreate-cache.sh |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 69d0534..b37f321 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -202,6 +202,27 @@ check lv_attr_bit perm $vg/$lv6 "r"
 
 lvremove -f $vg
 
+########################################
+# Validate args are properly preserved #
+########################################
+lvcreate --type cache-pool -L10 --chunksize 256 --cachemode writeback $vg/cpool1
+lvcreate -H -L10 $vg/cpool1
+check lv_field $vg/cpool1 chunksize "256.00k"
+check lv_field $vg/cpool1 cachemode "writeback"
+
+lvcreate --type cache-pool -L10 --chunksize 256 --cachemode writethrough $vg/cpool2
+lvcreate -H -L10 --chunksize 512 --cachemode writeback $vg/cpool2
+check lv_field $vg/cpool2 chunksize "512.00k"
+check lv_field $vg/cpool2 cachemode "writeback"
+
+# Chunk bigger then pool size
+fail lvcreate --type cache-pool -l1 --chunksize 1G $vg/cpool3
+
+lvcreate --type cache-pool -L10 $vg/cpool4
+fail lvcreate -H -L10 --chunksize 16M $vg/cpool4
+
+lvremove -f $vg
+
 
 ##############################
 # Test things that should fail


