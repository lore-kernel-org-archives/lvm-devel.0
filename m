From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Oct 2013 13:42:08 +0000 (UTC)
Subject: master - post-release
Message-ID: <20131004134208.E665E6138C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=761b5245193be548698495f2b2d2c089a5a72975
Commit:        761b5245193be548698495f2b2d2c089a5a72975
Parent:        04d9a526843dcb93fc0110e6e9dfbb12143a3930
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 4 14:41:32 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 4 14:41:32 2013 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index f4bbdb9..8e798d0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.103(2)-git (2013-10-04)
+2.02.104(2)-git (2013-10-04)
diff --git a/VERSION_DM b/VERSION_DM
index f4e8c0b..0e6eddb 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.82-git (2013-10-04)
+1.02.83-git (2013-10-04)
diff --git a/WHATS_NEW b/WHATS_NEW
index d69e74e..ef2181d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.104
+===================================
+
 Version 2.02.103 - 4th October 2013
 ===================================
   Ensure vgid matches before removing vgname entry from lvmetad cache.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9dfd9bf..6287fb4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.83
+==================================
+
 Version 1.02.82 - 4th October 2013
 ==================================
   Define symbolic names for subsystem udev flags in libdevmapper for easier use.


