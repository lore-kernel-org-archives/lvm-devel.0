From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 27 Apr 2017 09:30:35 -0400
Subject: master - test: Update pattern to match code
Message-ID: <201704271330.v3RDUZoh030532@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14c84c79db91d16f7beed203aa8c03127426d1d9
Commit:        14c84c79db91d16f7beed203aa8c03127426d1d9
Parent:        af47ec9f515402e69328fb73a73172845ff05b2f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Apr 27 10:22:11 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Apr 27 15:30:03 2017 +0200

test: Update pattern to match code

Fix commit a3fdc966b5
---
 test/shell/lvcreate-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 646bd10..faa78b2 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -57,7 +57,7 @@ fail lvcreate -l 1 --cachepool pool8 $vg
 # no size specified
 invalid lvcreate --cachepool pool $vg 2>&1 | tee err
 #grep "specify either size or extents" err
-grep "Incorrect syntax" err
+grep "No command with matching syntax recognised" err
 
 # Check nothing has been created yet
 check vg_field $vg lv_count 0


