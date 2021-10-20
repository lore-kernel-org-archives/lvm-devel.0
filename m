From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Oct 2021 10:10:23 +0000 (GMT)
Subject: main - WHATS_NEW: update
Message-ID: <20211020101023.4707B3857C53@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36be4d68f68d71173fed528f2f377c600f68f724
Commit:        36be4d68f68d71173fed528f2f377c600f68f724
Parent:        33e47182f773c1a902b533580b63a803906de55d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 20 11:08:36 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 20 11:10:37 2021 +0200

WHATS_NEW: update

---
 WHATS_NEW | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0199c174e..28e605280 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,6 @@
 Version 2.03.14 - 
 ==================================
-  Device scanning is skipping different filesystems.
+  Device scanning is skipping directories on different filesystems.
   Print info message with too many or too large archived files.
   Reduce metadata readings during scanning phase.
   Optimize computation of crc32 check sum with multiple PVs.
@@ -8,7 +8,7 @@ Version 2.03.14 -
   Filter out unsupported MQ/SMQ cache policy setting.
   Fix memleak in mpath filter.
   Support newer location for VDO statistics.
-  Add support for VDO async-unsage write policy.
+  Add support for VDO async-unsafe write policy.
   Improve lvm_import_vdo script.
   Support VDO LV with lvcreate -ky.
   Fix lvconvert for VDO LV bigger then 2T.


