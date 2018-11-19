From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 07:18:20 -0500
Subject: master - tests: skip when gcore from gdb package is missing
Message-ID: <201811191218.wAJCIKw1012458@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14f24c217586a4544b911b5ea90e8b627a8efd01
Commit:        14f24c217586a4544b911b5ea90e8b627a8efd01
Parent:        4021e88a31a440e64992742be76367f98fbc9400
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 18 21:37:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Nov 18 22:03:50 2018 +0100

tests: skip when gcore from gdb package is missing

gcore is needed for gathering all userspace mappings.
---
 test/shell/dmsecuretest.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/dmsecuretest.sh b/test/shell/dmsecuretest.sh
index 45abd00..fca72bf 100644
--- a/test/shell/dmsecuretest.sh
+++ b/test/shell/dmsecuretest.sh
@@ -21,6 +21,9 @@ SECURE="434e0cbab02ca68ffba9268222c3789d703fe62427b78b308518b3228f6a2122"
 
 DMTEST="${PREFIX}-test-secure"
 
+# Test needs installed gdb package with gcore app
+which gcore || skip
+
 aux driver_at_least 4 6 || skip
 
 # ensure we can create devices (uses dmsetup, etc)


