From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 24 Jul 2013 23:18:50 +0000 (UTC)
Subject: master - release 2.02.99
Message-ID: <20130724231850.33E15610FB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=76e617b1587b68b78f7ae5659e2293edcda630c3
Commit:        76e617b1587b68b78f7ae5659e2293edcda630c3
Parent:        929d5f3563d0ca0acbbb220e8c212f9441260d68
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 24 23:59:03 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 24 23:59:03 2013 +0100

release 2.02.99

 363 files changed, 19863 insertions(+), 9055 deletions(-)

This is a very large release - so expect bugs!

Please treat this release like a release candidate.
Changes to the external interfaces since 2.02.98 are not yet frozen.

Updated releases will follow quickly (days not weeks) as any problems
are handled.
---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index f8dcbdc..a3db87f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.99(2)-git (2012-10-22)
+2.02.99(2)-git (2013-07-24)
diff --git a/VERSION_DM b/VERSION_DM
index 75d1302..748468a 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.78-git (2012-10-22)
+1.02.78-git (2013-07-24)
diff --git a/WHATS_NEW b/WHATS_NEW
index 587b53d..039ddec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.99 - 
-===================================
+Version 2.02.99 - 24th July 2013
+================================
   Do not zero init 4KB of thin snapshot for non-zeroing thin pool (2.02.94).
   Issue an error msg if lvconvert --type used incorrectly with other options.
   Use LOG_DEBUG/ERR msg severity instead default for lvm2-activation-generator.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b269f55..3009427 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.78 - 
-===================================
+Version 1.02.78 - 24th July 2013
+================================
   Process thin messages once to active thin pool target for dm_tree.
   Optimize out setting the same value or read_ahead.
   Add DM_ARRAY_SIZE public macro.


