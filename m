From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Mar 2014 23:34:27 +0000 (UTC)
Subject: master - tests: add inactive pool creation test
Message-ID: <20140311233427.3A69660EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd690d5fd1253d7559d43c60194ec0139d426d79
Commit:        dd690d5fd1253d7559d43c60194ec0139d426d79
Parent:        4cc5c689b8600fa8490b2f1d60e483362b10c700
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 12 00:25:59 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 00:25:59 2014 +0100

tests: add inactive pool creation test

---
 test/shell/lvcreate-thin.sh |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 721f3d1..cfa605e 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -173,7 +173,9 @@ not lvcreate --chunksize 32 -l1 -T $vg/pool1
 # Too large chunk size (max is 1GB)
 not lvcreate -L4M --chunksize 2G -T $vg/pool1
 
-lvcreate -L4M -V2G --name lv1 -T $vg/pool1
+# Test creation of inactive pool
+lvcreate -an -L4M -T $vg/pool1
+lvcreate -V2G --name lv1 -T $vg/pool1
 # Origin name is not accepted
 not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
 


