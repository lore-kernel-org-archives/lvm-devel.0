From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 22 Mar 2023 12:44:21 +0000 (GMT)
Subject: main - post-release
Message-ID: <20230322124421.26DEB3858439@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=238e3777777e1e75b388d8e05f9c1212aa4d1eed
Commit:        238e3777777e1e75b388d8e05f9c1212aa4d1eed
Parent:        3e0ee8dbad69b01c63b13f41ba449cba48756968
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Mar 21 13:36:36 2023 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 21 13:36:36 2023 +0100

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 8f75291df..60c7a1dd4 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.20(2) (2023-03-21)
+2.03.21(2)-git (2023-03-21)
diff --git a/VERSION_DM b/VERSION_DM
index a1f7b8fce..68bf19e27 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.193 (2023-03-21)
+1.02.195-git (2023-03-21)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8328a668a..6f801828f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+version 2.03.21 - 
+=================================
+
 version 2.03.20 - 21st March 2023
 =================================
   Fix segfault if using -S|--select with log/report_command_log=1 setting.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2227b10d9..88298caad 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.195 - 
+==================================
+
 Version 1.02.193 - 21st March 2023
 ==================================
 

