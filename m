From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 9 Oct 2019 09:13:39 -0400
Subject: master - test: Minimize data written by metadata-zero-space
Message-ID: <201910091313.x99DDdVt004004@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df26b73b8e4355df7f6d4d664edad2b86991b352
Commit:        df26b73b8e4355df7f6d4d664edad2b86991b352
Parent:        53b97b146df4de99207c580c1304d016832e318b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 9 15:11:03 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 9 15:11:03 2019 +0200

test: Minimize data written by metadata-zero-space

The test is checking only 2 megabytes, but is rewriting much more. Bad
for limited ramdisk.
---
 test/shell/metadata-zero-space.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/metadata-zero-space.sh b/test/shell/metadata-zero-space.sh
index 1bd1eef..d037ab2 100644
--- a/test/shell/metadata-zero-space.sh
+++ b/test/shell/metadata-zero-space.sh
@@ -21,7 +21,8 @@ get_devs
 
 # Fill with random data so if the space between metadata
 # copies are not zeroed the grep for zeros will fail.
-dd if=/dev/urandom of="$dev1" bs=1M || true
+dd if=/dev/urandom of="$dev1" bs=1M count=1 || true
+dd if=/dev/urandom of="$dev1" bs=1M skip=15 count=1 || true
 
 pvcreate --pvmetadatacopies 2 "$dev1"
 


