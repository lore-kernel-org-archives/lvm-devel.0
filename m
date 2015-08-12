From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Aug 2015 12:41:23 +0000 (UTC)
Subject: master - tests: keep testing mq policy
Message-ID: <20150812124123.5FBB860072@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2d814e78d17320a557c1c0fe40440cda896ea2d
Commit:        c2d814e78d17320a557c1c0fe40440cda896ea2d
Parent:        9e3ef2809a83c55131932cbd33b8de0138b590b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 12 14:18:28 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 12 14:33:16 2015 +0200

tests: keep testing mq policy

Tests were written for 'mq' policy, so disable smq.
---
 test/shell/lvchange-cache.sh       |    2 ++
 test/shell/lvconvert-cache-raid.sh |    2 ++
 test/shell/lvcreate-cache.sh       |    1 +
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-cache.sh b/test/shell/lvchange-cache.sh
index 9ce0314..3efd762 100644
--- a/test/shell/lvchange-cache.sh
+++ b/test/shell/lvchange-cache.sh
@@ -16,6 +16,8 @@ test -e LOCAL_LVMPOLLD && skip
 aux have_cache 1 3 0 || skip
 aux prepare_vg 3
 
+aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
+
 lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
 lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 lvcreate -n noncache -l 1 $vg
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index b8333d9..5f51fee 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -18,6 +18,8 @@ test -e LOCAL_LVMPOLLD && skip
 aux have_cache 1 3 0 || skip
 aux have_raid 1 0 0 || skip
 
+aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
+
 aux prepare_vg 5 80
 
 # Bug 1095843
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index aa0ab53..b921909 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -23,6 +23,7 @@ aux have_cache 1 3 0 || skip
 # FIXME: parallel cache metadata allocator is crashing when used value 8000!
 aux prepare_vg 5 80000
 
+aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
 
 #######################
 # Cache_Pool creation #


