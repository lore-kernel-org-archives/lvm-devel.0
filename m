From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 18:42:06 -0400
Subject: master - tests: update checked message
Message-ID: <201708012242.v71Mg6xh017423@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5dd53943c9bee9d55cde9c8fee27a2e3ea031327
Commit:        5dd53943c9bee9d55cde9c8fee27a2e3ea031327
Parent:        19bd65207e2aec48a8d6194aefac9be05a13d944
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 2 00:04:35 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 2 00:04:35 2017 +0200

tests: update checked message

---
 test/shell/lvconvert-thin.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 587f922..1f8d2ed 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -80,8 +80,8 @@ lvremove -f $vg
 lvcreate -L1T -n $lv1 $vg
 lvcreate -L32 -n $lv2 $vg
 lvconvert --yes -c 8M --type thin-pool $vg/$lv1 2>&1 | tee err
-# Check tther is warning for large chunk size and zeroing enabled
-grep "Pool zeroing and large" err
+# Check there is a warning for large chunk size and zeroing enabled
+grep "WARNING: Pool zeroing and" err
 UUID=$(get lv_field $vg/$lv2 uuid)
 # Fail is pool is active
 # TODO  maybe detect inactive pool and deactivate


