From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 10 Jun 2016 23:16:04 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160610231604.B37EA61F24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49a8d1a85eb035a0dfb1febd76e3ae4fa5e976d5
Commit:        49a8d1a85eb035a0dfb1febd76e3ae4fa5e976d5
Parent:        f2d1f5e9273232fccc05cc819b28ea47f7da7ff9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Jun 11 00:14:00 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Jun 11 00:14:00 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 0802557..a7628a4 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.156(2)-git (2016-06-11)
+2.02.157(2)-git (2016-06-11)
diff --git a/VERSION_DM b/VERSION_DM
index 35c3a63..a1416c0 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.127-git (2016-06-11)
+1.02.128-git (2016-06-11)
diff --git a/WHATS_NEW b/WHATS_NEW
index 046f77a..61b58b4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.157 - 
+=================================
+
 Version 2.02.156 - 11th June 2016
 =================================
   Don't allow duplicate orphan PVs to be used with vgcreate/vgextend/pvcreate.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1135a62..bd17f1b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.128 - 
+=================================
+
 Version 1.02.127 - 11th June 2016
 =================================
  Fix blkdeactivate regression causing skipping of dm + md devices. (1.02.126)


