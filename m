From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 21 Apr 2023 08:43:40 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20230421084340.831513858D37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54efdab230ec4f6d10ffdb9170b07c0664c157ea
Commit:        54efdab230ec4f6d10ffdb9170b07c0664c157ea
Parent:        7807672975cc991720d817b4e541ca5e720df26e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Apr 21 10:35:10 2023 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Apr 21 10:35:10 2023 +0200

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 ++-
 WHATS_NEW_DM | 2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 60c7a1dd4..7a803d387 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.21(2)-git (2023-03-21)
+2.03.21(2) (2023-04-21)
diff --git a/VERSION_DM b/VERSION_DM
index 68bf19e27..91e14241f 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.195-git (2023-03-21)
+1.02.195 (2023-04-21)
diff --git a/WHATS_NEW b/WHATS_NEW
index 2bff3445d..88093cf25 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,8 @@
-version 2.03.21 - 
+version 2.03.21 - 21st April 2023
 =================================
   Fix activation of vdo-pool for with 0 length headers (converted pools).
   Avoid printing internal init messages when creation integration devices.
+  Allow (write)cache over raid+integrity LV.
 
 version 2.03.20 - 21st March 2023
 =================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 88298caad..18e9362b3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.195 - 
+Version 1.02.195 - 21st April 2023
 ==================================
 
 Version 1.02.193 - 21st March 2023

