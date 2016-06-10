From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 10 Jun 2016 23:16:02 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160610231602.8BB5A61F24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f2d1f5e9273232fccc05cc819b28ea47f7da7ff9
Commit:        f2d1f5e9273232fccc05cc819b28ea47f7da7ff9
Parent:        2d384954adf6355364257045738c9bd6c5dedad5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 11 00:08:08 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 11 00:08:08 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    5 ++---
 WHATS_NEW_DM |    5 +++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index e2b1146..0802557 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.156(2)-git (2016-06-03)
+2.02.156(2)-git (2016-06-11)
diff --git a/VERSION_DM b/VERSION_DM
index fddb2ee..35c3a63 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.127-git (2016-06-03)
+1.02.127-git (2016-06-11)
diff --git a/WHATS_NEW b/WHATS_NEW
index 9c8ae71..046f77a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,9 @@
-Version 2.02.156 - 
-================================
+Version 2.02.156 - 11th June 2016
+=================================
   Don't allow duplicate orphan PVs to be used with vgcreate/vgextend/pvcreate.
   Improve handling of lvmetad update failures.
   Yes/No prompt accepts '^[ ^t]*([Yy]([Ee]([Ss]|)|)|[Nn]([Oo]|))[ ^t]*$'.
   If available, also collect output from lsblk command when running lvmdump -s.
-  Fix regression in blkdeactivate causing dm and md devices to be skipped. (2.02.155)
 
 Version 2.02.155 - 3rd June 2016
 ================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 371e8b5..1135a62 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
-Version 1.02.127 - 
-================================
+Version 1.02.127 - 11th June 2016
+=================================
+ Fix blkdeactivate regression causing skipping of dm + md devices. (1.02.126)
 
 Version 1.02.126 - 3rd June 2016
 ================================


