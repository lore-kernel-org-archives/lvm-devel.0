From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon,  7 Feb 2022 17:08:24 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20220207170824.E1DEC3858426@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6987f318ec135ffd54a05872a8aa621726fe7acb
Commit:        6987f318ec135ffd54a05872a8aa621726fe7acb
Parent:        563105bba92f5a840d7d9f01acbc8be9daf39b32
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Feb 7 18:00:54 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Feb 7 18:00:54 2022 +0100

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 5 +++--
 WHATS_NEW_DM | 4 ++--
 4 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index dfbf5a300..0e6ab70a9 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.15(2)-git (2021-10-20)
+2.03.15(2) (2022-02-07)
diff --git a/VERSION_DM b/VERSION_DM
index 5e5c70a77..d6704212f 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.183-git (2021-10-20)
+1.02.183 (2022-02-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 16235514e..dda9954fe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.03.15 - 
-===================================
+Version 2.03.15 - 07th February 2022
+====================================
+  Remove service based autoactivation. global/event_activation = 0 is NOOP.
   Improve support for metadata profiles for --type writecache.
   Use cache or active DM device when available with new kernels.
   Introduce function to utilize UUIDs from DM_DEVICE_LIST.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dfb075dcc..778437262 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.183 - 
-====================================
+Version 1.02.183 - 07th February 2022
+=====================================
   Unmangle UUIDs for DM_DEVICE_LIST ioctl.
 
 Version 1.02.181 - 20th October 2021


