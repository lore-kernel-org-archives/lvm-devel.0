From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 22 Mar 2023 12:44:17 +0000 (GMT)
Subject: main - tests: nomda-restoremissing
Message-ID: <20230322124417.9BCD43857C48@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49dbeb9b4566df684164f40ca6ebdab3d6696836
Commit:        49dbeb9b4566df684164f40ca6ebdab3d6696836
Parent:        ddfe839dd1aa42e3d2a15a19eaf86c4b6fc65d19
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Mar 20 12:42:50 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Mar 20 12:42:50 2023 -0500

tests: nomda-restoremissing

This test was broken by commit 69ea2e3f9
"vg_read: keep MISSING_PV when device with no mda reappears"
Change the test to match the new behavior.
---
 test/shell/nomda-restoremissing.sh | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index fb3f93053..d9c544bc4 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -31,7 +31,18 @@ not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
 not lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # write operations fail
 aux enable_dev "$dev1"
-lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # no MDA => automatically restored
+# Old versions would automatically clear MISSING_PV on a PV that had no mda,
+# but this made no sense; the existence of an mda means nothing for the
+# validity of the data on the device.  I suspect that at some point in the
+# past, the MISSING_PV flag was used to decide if metadata could be used
+# from the device, so the flag could be cleared on a PV with no mda.
+# These days lvm knows when to ignore outdated metadata.
+# MISSING_PV probably has little to no value for determining valid data either,
+# so it's likely that we'll begin to automatically clear MISSING_PV in the
+# future (but it will have nothing to do with having mdas.)
+not lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg 
+vgextend --restoremissing $vg "$dev1"
+lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg 
 vgck $vg
 
 vgremove -ff $vg

