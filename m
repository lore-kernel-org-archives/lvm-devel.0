From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue,  3 Jan 2023 15:10:17 +0000 (GMT)
Subject: main - post-release
Message-ID: <20230103151017.BD0A33858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=118145b07249d96f4f61521bb1daf04cc8d4c1e9
Commit:        118145b07249d96f4f61521bb1daf04cc8d4c1e9
Parent:        2abb029f2a9f056a6061dab6f898125dc40637ae
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jan 3 16:02:07 2023 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jan 3 16:02:07 2023 +0100

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 5 ++++-
 WHATS_NEW_DM | 3 +++
 4 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/VERSION b/VERSION
index 54e07f9c2..50e9c95ee 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.18(2) (2022-12-22)
+2.03.19(2)-git (2022-12-22)
diff --git a/VERSION_DM b/VERSION_DM
index 9ead606c4..21ef672a5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.189 (2022-12-22)
+1.02.191-git (2022-12-22)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8790cfc51..172a6a42b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,7 @@
-Version 2.03.18 - 22nd December 2022
+version 2.03.19 - 
+====================================
+
+version 2.03.18 - 22nd december 2022
 ====================================
   Fix issues reported by coverity scan.
   Fix warning for thin pool overprovisioning on lvextend (2.03.17).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 35e1d990f..052fb9daf 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.191 - 
+=====================================
+
 Version 1.02.189 - 22nd December 2022
 =====================================
   Improve 'dmsetup create' without given table line with new kernels.

