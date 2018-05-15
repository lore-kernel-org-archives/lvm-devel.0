From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 May 2018 16:19:22 -0400
Subject: master - doc: add some performance info
Message-ID: <201805152019.w4FKJMAN004094@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed799404f887339ebf8bc6ca4504c8bff6b1f491
Commit:        ed799404f887339ebf8bc6ca4504c8bff6b1f491
Parent:        3bbc17a6706b4ceae8a41da519d87945da27fd14
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 15 15:16:02 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 15 15:17:36 2018 -0500

doc: add some performance info

---
 doc/lvm-disk-reading.txt |  107 ++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 107 insertions(+), 0 deletions(-)

diff --git a/doc/lvm-disk-reading.txt b/doc/lvm-disk-reading.txt
index 1255ae8..66b4467 100644
--- a/doc/lvm-disk-reading.txt
+++ b/doc/lvm-disk-reading.txt
@@ -229,3 +229,110 @@ It may be worthwhile to change the filters to use the udev info as a hint,
 or only use udev info for filtering in reporting commands where
 inaccuracies are not a big problem.)
 
+
+
+I/O Performance
+---------------
+
+. 400 loop devices used as PVs
+. 40 VGs each with 10 PVs
+. each VG has one active LV
+. each of the 10 PVs in vg0 has an artificial 100 ms read delay
+. read/write/io_submit are system call counts using strace
+. old is lvm 2.2.175
+. new is lvm 2.2.178 (shortly before)
+
+
+Command: pvs
+------------
+old: 0m17.422s
+new: 0m0.331s
+
+old: read 7773 write 497
+new: read 2807 write 495 io_submit 448
+
+
+Command: vgs
+------------
+old: 0m20.383s
+new: 0m0.325s
+
+old: read 10684 write 129
+new: read  2807 write 129 io_submit 448
+
+
+Command: vgck vg0
+-----------------
+old: 0m16.212s
+new: 0m1.290s
+
+old: read 6372 write 4
+new: read 2807 write 4 io_submit 458
+
+
+Command: lvcreate -n test -l1 -an vg0
+-------------------------------------
+old: 0m29.271s
+new: 0m1.351s
+
+old: read 6503 write 39
+new: read 2808 write 9 io_submit 488
+
+
+Command: lvremove vg0/test
+--------------------------
+old: 0m29.262s
+new: 0m1.348s
+
+old: read 6502 write 36
+new: read 2807 write 6 io_submit 488
+
+
+io_submit sources
+-----------------
+
+vgs:
+  reads:
+  - 400 for each PV
+  - 40 for each LV
+  - 8 for other devs on the system
+
+vgck vg0:
+  reads:
+  - 400 for each PV
+  - 40 for each LV
+  - 10 for each PV in vg0 (rescan)
+  - 8 for other devs on the system
+
+lvcreate -n test -l1 -an vg0
+  reads:
+  - 400 for each PV
+  - 40 for each LV
+  - 10 for each PV in vg0 (rescan)
+  - 8 for other devs on the system
+  writes:
+  - 10 for metadata on each PV in vg0
+  - 10 for precommit on each PV in vg0
+  - 10 for commit on each PV in vg0
+
+
+
+With lvmetad
+------------
+
+Command: pvs
+------------
+old: 0m5.405s
+new: 0m1.404s
+
+Command: vgs
+------------
+old: 0m0.222s
+new: 0m0.223s
+
+Command: lvcreate -n test -l1 -an vg0
+-------------------------------------
+old: 0m10.128s
+new: 0m1.137s
+
+


