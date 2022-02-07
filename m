From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon,  7 Feb 2022 17:08:26 +0000 (GMT)
Subject: main - post-release
Message-ID: <20220207170826.139963858423@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8dccc2314e2482370bc6e5cf007eb210994abdef
Commit:        8dccc2314e2482370bc6e5cf007eb210994abdef
Parent:        6987f318ec135ffd54a05872a8aa621726fe7acb
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Feb 7 18:02:07 2022 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Feb 7 18:02:07 2022 +0100

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 0e6ab70a9..fba090956 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.15(2) (2022-02-07)
+2.03.16(2)-git (2022-02-07)
diff --git a/VERSION_DM b/VERSION_DM
index d6704212f..d122183b2 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.183 (2022-02-07)
+1.02.185-git (2022-02-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index dda9954fe..006d0acb1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.03.16 - 
+====================================
+
 Version 2.03.15 - 07th February 2022
 ====================================
   Remove service based autoactivation. global/event_activation = 0 is NOOP.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 778437262..c63436221 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.185 - 
+=====================================
+
 Version 1.02.183 - 07th February 2022
 =====================================
   Unmangle UUIDs for DM_DEVICE_LIST ioctl.


