From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 16 Oct 2018 15:57:13 -0400
Subject: master - tests: properly enforce v1
Message-ID: <201810161957.w9GJvDMH002404@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1ac72c84804aa1c00aa385caec9eb007fd39aee
Commit:        f1ac72c84804aa1c00aa385caec9eb007fd39aee
Parent:        4db228b9079386b9e24e0389a080f86ac3008e69
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 16 21:32:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 16 21:56:00 2018 +0200

tests: properly enforce v1

Since with smq policy we can still pick format v2 - enforce
format v1 explicitely.
---
 test/shell/lvcreate-cache-no-tools.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvcreate-cache-no-tools.sh b/test/shell/lvcreate-cache-no-tools.sh
index 23528e4..253c8a5 100644
--- a/test/shell/lvcreate-cache-no-tools.sh
+++ b/test/shell/lvcreate-cache-no-tools.sh
@@ -94,9 +94,9 @@ lvremove -f $vg
 
 fi
 
+# Enforce older cache target format V1
+aux lvmconf 'allocation/cache_metadata_format = 1'
 
-# On older cache target that supports only V1 format
-aux lvmconf 'global/cache_disabled_features = [ "policy_smq" ]'
 rm -f fake-tool.sh
 
 lvcreate -aey -l1 -n $lv1 $vg


