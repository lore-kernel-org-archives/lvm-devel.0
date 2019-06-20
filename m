From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jun 2019 05:22:52 -0400
Subject: stable-2.02 - tests: properly enforce v1
Message-ID: <201906200922.x5K9Mqxc009394@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e0a176f49ab09d2afaea73cafa4d7b41ade0c345
Commit:        e0a176f49ab09d2afaea73cafa4d7b41ade0c345
Parent:        24186cd9ce2d24616da7aba56787bc97acb2e42a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 21:32:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 20 11:21:59 2019 +0200

tests: properly enforce v1

Since with smq policy we can still pick format v2 - enforce
format v1 explicitely.
---
 test/shell/lvcreate-cache-no-tools.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-cache-no-tools.sh b/test/shell/lvcreate-cache-no-tools.sh
index e7d947a..bbab0fe 100644
--- a/test/shell/lvcreate-cache-no-tools.sh
+++ b/test/shell/lvcreate-cache-no-tools.sh
@@ -93,9 +93,9 @@ lvremove -f $vg
 
 fi
 
+# Enforce older cache target format V1
+aux lvmconf 'allocation/cache_metadata_format = 1'
 
-# On older cache target that supports only V1 format
-aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
 rm -f fake-tool.sh
 
 lvcreate -aey -l1 -n $lv1 $vg


