From: Alasdair Kergon <agk@sourceware.org>
Date: Fri, 11 Aug 2017 15:50:59 -0400
Subject: master - pvcreate: Disallow --bootloaderareasize with --restorefile.
Message-ID: <201708111950.v7BJoxvP001127@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7d09d7288b3aaecdfba9a3a05e7697f7dcdfed79
Commit:        7d09d7288b3aaecdfba9a3a05e7697f7dcdfed79
Parent:        955083e625eb003090ce8f699e8d414a215cce1f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Aug 11 20:28:53 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Aug 11 20:28:53 2017 +0100

pvcreate: Disallow --bootloaderareasize with --restorefile.

The backup file already holds the bootloader area details to use so
don't overcomplicate things.
---
 WHATS_NEW              |    1 +
 tools/command-lines.in |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c484529..b21702c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Disallow --bootloaderareasize with pvcreate --restorefile.
   Fix lvmlockd check for running lock managers during lock adoption.
   Add --withgeneralpreamble and --withlocalpreamble to lvmconfig.
   Improve makefiles' linking.
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1ef234e..2f4e48f 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1367,6 +1367,8 @@ OO: --dataalignment SizeKB, --dataalignmentoffset SizeKB, --bootloaderareasize S
 --metadataignore Bool, --norestorefile, --setphysicalvolumesize SizeMB,
 --reportformat ReportFmt, --restorefile String, --uuidstr String, --zero Bool
 ID: pvcreate_general
+RULE: --norestorefile not --restorefile
+RULE: --bootloaderareasize not --restorefile
 
 ---
 


