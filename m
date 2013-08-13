From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 13 Aug 2013 11:47:00 +0000 (UTC)
Subject: master - post-release
Message-ID: <20130813114700.2E99B61198@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32148369d12750dbf85cfd5c21a8bc7f9e6b5ec5
Commit:        32148369d12750dbf85cfd5c21a8bc7f9e6b5ec5
Parent:        297907899c389fef074eeb56fd0d7b60d66dbb35
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 13 11:54:48 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 13 11:54:48 2013 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index c7d4f06..4aa9105 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.100(2)-git (2013-08-13)
+2.02.101(2)-git (2013-08-13)
diff --git a/VERSION_DM b/VERSION_DM
index a11b7cd..2fe4e25 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.79-git (2013-08-13)
+1.02.80-git (2013-08-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index 20331c3..66cf20e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.101 - 
+===================================
+
 Version 2.02.100 - 13th August 2013
 ===================================
   Fix inability to remove a VG's cluster flag if it contains a mirror.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0ef1755..67b7d46 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.80 - 
+==================================
+
 Version 1.02.79 - 13th August 2013
 ==================================
   Create dmeventd timeout threads as "detached" so exit status is freed.


