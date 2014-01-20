From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 20 Jan 2014 19:41:41 +0000 (UTC)
Subject: master - post-release
Message-ID: <20140120194141.64B8460E9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=899a079c8f36decd2fda42412091df57ab8f72cb
Commit:        899a079c8f36decd2fda42412091df57ab8f72cb
Parent:        aa21e79991da6f6583f708f81ff32a1e2c0c3a42
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jan 20 19:41:30 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jan 20 19:41:30 2014 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 07b56f1..13e0ce8 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.105(2)-git (2014-01-20)
+2.02.106(2)-git (2014-01-20)
diff --git a/VERSION_DM b/VERSION_DM
index 23b8f70..5c743b5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.84-git (2014-01-20)
+1.02.85-git (2014-01-20)
diff --git a/WHATS_NEW b/WHATS_NEW
index 26b63ae..982f44d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.106 - 
+====================================
+
 Version 2.02.105 - 20th January 2014
 ====================================
   Fix thin LV flagging for udev to skip scanning only if the LV is wiped.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ce302f3..448a7f0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.85 - 
+===================================
+
 Version 1.02.84 - 20th January 2014
 ===================================
   Revert activation of activated nodes if a node preload callback fails.


