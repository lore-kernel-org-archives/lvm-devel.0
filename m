From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 10 Nov 2022 13:22:22 +0000 (GMT)
Subject: main - post-release
Message-ID: <20221110132222.4B9B43858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c77384785d3bd3d0c265220395dc392b52e62218
Commit:        c77384785d3bd3d0c265220395dc392b52e62218
Parent:        f8127c45c5fa8fc8e163565bfa2001a0bb8ae72e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Nov 10 14:21:57 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Nov 10 14:21:57 2022 +0100

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index d011ad748..b5c261028 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.17(2) (2022-11-10)
+2.03.18(2)-git (2022-11-10)
diff --git a/VERSION_DM b/VERSION_DM
index 3f4240a76..c1923fa3a 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.187 (2022-11-10)
+1.02.189-git (2022-11-10)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2f4ffd894..613acfa86 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.03.18 - 
+====================================
+
 Version 2.03.17 - 10th November 2022
 ====================================
   Add new options (--fs, --fsmode) for FS handling when resizing LVs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f676ff7e1..1067312d3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.189 - 
+=====================================
+
 Version 1.02.187 - 10th November 2022
 =====================================
   Add DM_REPORT_GROUP_JSON_STD for more JSON standard compliant output format.

