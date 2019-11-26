From: David Teigland <teigland@sourceware.org>
Date: Tue, 26 Nov 2019 17:52:54 -0500
Subject: master - tests hints: update check for io count
Message-ID: <31950.119112617525100325@us-mta-161.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b400353c71397954a7cc4c4b52b9570715104773
Commit:        b400353c71397954a7cc4c4b52b9570715104773
Parent:        a61272a6f048e56ea75e34ad190af10ff9773c8c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 26 16:31:38 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 26 16:52:28 2019 -0600

tests hints: update check for io count

Running a reporting command on a VG now includes one
additional read to check the mda_header for any change
to the vg between scan and lock.
---
 test/shell/hints.sh |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/shell/hints.sh b/test/shell/hints.sh
index 019912e..f95505a 100644
--- a/test/shell/hints.sh
+++ b/test/shell/hints.sh
@@ -52,15 +52,17 @@ pvs
 grep -v -E "$dev1|$dev2" $HINTS > tmptest
 not grep scan: tmptest
 
-# test that 'pvs' submits only two reads, one for each PV in hints
+# test that 'pvs' submits only three reads, one for each PV in hints
+# for initial scan, and one more in vg_read rescan check
 
 if [ -e "/usr/bin/strace" ]; then
 strace -e io_submit pvs 2>&1|tee tmptest
-test "$(grep io_submit tmptest | wc -l)" -eq 2
+test "$(grep io_submit tmptest | wc -l)" -eq 3
 
-# test that 'pvs -a' submits six reads, one for each device
+# test that 'pvs -a' submits seven reads, one for each device,
+# and one more in vg_read rescan check
 strace -e io_submit pvs -a 2>&1|tee tmptest
-test "$(grep io_submit tmptest | wc -l)" -eq 6
+test "$(grep io_submit tmptest | wc -l)" -eq 7
 fi
 
 #



