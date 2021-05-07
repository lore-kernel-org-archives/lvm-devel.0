From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  7 May 2021 21:15:13 +0000 (GMT)
Subject: main - post-release
Message-ID: <20210507211513.4D0D8389440C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e2f09d78b64719e6c3d403fb1c6f93b06d80335
Commit:        3e2f09d78b64719e6c3d403fb1c6f93b06d80335
Parent:        01b05cf51dd547354b4ad70e7f8f4ff7ff0bb152
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 7 22:36:56 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 7 23:09:15 2021 +0200

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index d9c3e2336..6e36bd169 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.12(2) (2021-05-07)
+2.03.13(2)-git (2021-05-07)
diff --git a/VERSION_DM b/VERSION_DM
index 6105a0ff1..df334e09b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.177 (2021-05-07)
+1.02.179-git (2021-05-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 6f339a509..4b5b23072 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.03.13 - 
+===============================
+
 Version 2.03.12 - 07th May 2021
 ===============================
   Allow attaching cache to thin data volume.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index fe4310509..9de74dfe2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.179 - 
+================================
+
 Version 1.02.177 - 07th May 2021
 ================================
   Configure proceeds without libaio to allow build of device-mapper only.


