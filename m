From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Jul 2013 23:41:29 +0000 (UTC)
Subject: master - post-release
Message-ID: <20130724234129.2433C611B0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06dce7d5398cf44a4502ff730987e99bc8b3b78a
Commit:        06dce7d5398cf44a4502ff730987e99bc8b3b78a
Parent:        76e617b1587b68b78f7ae5659e2293edcda630c3
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 25 00:38:53 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 25 00:38:53 2013 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index a3db87f..1716ee6 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.99(2)-git (2013-07-24)
+2.02.100(2)-git (2013-07-24)
diff --git a/VERSION_DM b/VERSION_DM
index 748468a..067a488 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.78-git (2013-07-24)
+1.02.79-git (2013-07-24)
diff --git a/WHATS_NEW b/WHATS_NEW
index 039ddec..3544f87 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.100 -
+================================
+
 Version 2.02.99 - 24th July 2013
 ================================
   Do not zero init 4KB of thin snapshot for non-zeroing thin pool (2.02.94).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3009427..cd77bc6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.79 -
+================================
+
 Version 1.02.78 - 24th July 2013
 ================================
   Process thin messages once to active thin pool target for dm_tree.


