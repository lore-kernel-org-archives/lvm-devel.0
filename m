From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Feb 2015 13:55:55 +0000 (UTC)
Subject: master - tests: fix pvcreate-operation-md test to properly clean up devs before their reuse
Message-ID: <20150213135555.B3DB560249@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1ced5562cddb38b0eda1be1e1657b5eee2500f37
Commit:        1ced5562cddb38b0eda1be1e1657b5eee2500f37
Parent:        993c988895c2bdac1867b79ef1de5c14cdd4072d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 13 14:53:26 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 13 14:53:26 2015 +0100

tests: fix pvcreate-operation-md test to properly clean up devs before their reuse

pvcreate filters out devices with existing partitions defined on them,
we need to properly clean up the devs before we reuse them.
---
 test/shell/pvcreate-operation-md.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvcreate-operation-md.sh b/test/shell/pvcreate-operation-md.sh
index f959c0b..87117d1 100644
--- a/test/shell/pvcreate-operation-md.sh
+++ b/test/shell/pvcreate-operation-md.sh
@@ -132,9 +132,13 @@ EOF
     fi
 fi
 
+# make sure we're clean for another test
+test -b "$mddev" && cleanup_md
+dd if=/dev/zero of="$dev1" bs=512 count=1
+dd if=/dev/zero of="$dev2" bs=512 count=1
+
 # Test newer topology-aware alignment detection w/ --dataalignment override
 if kernel_at_least 2 6 33 ; then
-    cleanup_md
     pvcreate -f "$dev1"
     pvcreate -f "$dev2"
 


