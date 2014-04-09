From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  9 Apr 2014 13:44:39 +0000 (UTC)
Subject: master - tests: add some coverage for bootloader areas
Message-ID: <20140409134439.97EEA60F8E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b45d2768a858cc65a6770eed4db99f8b82b6353b
Commit:        b45d2768a858cc65a6770eed4db99f8b82b6353b
Parent:        10e10cfa4fd802ffe404c0afb30ad896003c9437
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 9 15:44:26 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 9 15:44:26 2014 +0200

tests: add some coverage for bootloader areas

---
 test/shell/pvcreate-usage.sh |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvcreate-usage.sh b/test/shell/pvcreate-usage.sh
index 251746d..378f8b5 100644
--- a/test/shell/pvcreate-usage.sh
+++ b/test/shell/pvcreate-usage.sh
@@ -187,3 +187,25 @@ for ignore in y n; do
 done
 done
 done
+
+#COMM 'pvcreate sets/aligns bootloader area correctly'
+pvcreate --dataalignment 256k --bootloaderareasize 600k "$dev1"
+# ba_start must be aligned based on dataalignment
+# pe_start starts at next dataalignment multiple
+# ba_size is the whole space in between ba_start and pe_start
+check pv_field "$dev1" ba_start "256.00k"
+check pv_field "$dev1" ba_size "768.00k"
+check pv_field "$dev1" pe_start "1.00m"
+
+aux lvmconf 'global/suffix=0'
+aux lvmconf 'global/units="b"'
+#COMM 'pvcreate with booloader area size - test corner cases
+dev_size=$(pvs -o pv_size --noheadings $dev1)
+pv_size=$[dev_size - 1048576] # device size - 1m pe_start = area for data
+# try to use the whole data area for bootloader area
+pvcreate --bootloaderareasize ${pv_size}b --dataalignment 1048576b "$dev1"
+check pv_field "$dev1" pe_start $dev_size
+check pv_field "$dev1" ba_start 1048576
+check pv_field "$dev1" ba_size ${pv_size}
+not pvcreate --bootloaderareasize $[pv_size + 1] --dataalignment 1048576b "$dev1" 2>err
+grep "Bootloader area with data-aligned start must not exceed device size" err


