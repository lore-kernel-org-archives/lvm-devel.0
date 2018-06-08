From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:39:17 -0400
Subject: master - tests: check pvresize with metadata size
Message-ID: <201806081239.w58CdHDl006144@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0e2a358da926b75dabd5074fcff589cac0f22821
Commit:        0e2a358da926b75dabd5074fcff589cac0f22821
Parent:        59dc9b445d6dba0ae119a2f517f4f665c6c522a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 14:28:47 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:31 2018 +0200

tests: check pvresize with metadata size

Test new size of a PV can keep also metadata.
---
 test/shell/pvresize-mdas.sh |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvresize-mdas.sh b/test/shell/pvresize-mdas.sh
index da4119c..240dfb2 100644
--- a/test/shell/pvresize-mdas.sh
+++ b/test/shell/pvresize-mdas.sh
@@ -26,3 +26,13 @@ pvresize --setphysicalvolumesize 4m -y "$dev1"
 check pv_field "$dev1" pv_size 4.00m
 check pv_field "$dev1" pv_mda_count 2
 pvs "$dev1"
+
+# Check physical size is checked agains metadatasize
+pvcreate --metadatasize 2m --metadatacopies 1 -y "$dev1"
+not pvresize --setphysicalvolumesize 2m -y "$dev1" |& tee out
+grep "Size must exceed physical extent start of 6144 sectors on" out
+# 3MiB shall pass with 1M default alignment
+pvresize --setphysicalvolumesize 3m -y "$dev1"
+check pv_field "$dev1" pv_size 3.00m
+check pv_field "$dev1" pv_mda_count 1
+pvs "$dev1"


