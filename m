From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 21 Feb 2023 14:39:17 +0000 (GMT)
Subject: main - post-release
Message-ID: <20230221143917.DB0E33858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f6da9926d0e7be66e759c27f42baf0c414c1ff8
Commit:        0f6da9926d0e7be66e759c27f42baf0c414c1ff8
Parent:        f7dd2562c53347cec69bc060f838c95839770586
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 21 15:36:24 2023 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Feb 21 15:36:24 2023 +0100

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 5317d59a5..2a5ec2776 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.19(2) (2023-02-21)
+2.03.20(2)-git (2023-02-21)
diff --git a/VERSION_DM b/VERSION_DM
index 1f8535376..20aaeb0b7 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.191 (2023-02-21)
+1.02.193-git (2023-02-21)
diff --git a/WHATS_NEW b/WHATS_NEW
index b54a092d8..4a7c3307a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+version 2.03.20 - 
+====================================
+
 version 2.03.19 - 21st February 2023
 ====================================
   Configure supports --with-systemd-run executed from udev rules.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index e50a4d131..c2eefc8db 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.193 - 
+=====================================
+
 Version 1.02.191 - 21st February 2023
 =====================================
   Improve parallel creation of /dev/mapper/control device node.

