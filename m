From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  9 Apr 2016 01:14:04 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160409011404.2FE7C6067A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3aab784aa5cbbe4f86cbc1c8a33579dc32c991eb
Commit:        3aab784aa5cbbe4f86cbc1c8a33579dc32c991eb
Parent:        af148a9d7715a8026d3d51a4c4c176bf59d3cc5f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Apr 9 02:08:44 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Apr 9 02:08:44 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    2 +-
 WHATS_NEW_DM |    6 +++---
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 3a2d7d1..78b4a66 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.150(2)-git (2016-04-01)
+2.02.150(2)-git (2016-04-09)
diff --git a/VERSION_DM b/VERSION_DM
index 77d3356..8eb5316 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.122-git (2016-04-01)
+1.02.122-git (2016-04-09)
diff --git a/WHATS_NEW b/WHATS_NEW
index 0fa9f50..bf2972f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.150 -
+Version 2.02.150 - 9th April 2016
 =================================
   Avoid using flushing dm status ioctl when checking for usable DM device.
   Check for devices without LVM- uuid prefix only with kernels < 3.X.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6bd857e..08d7d45 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,6 @@
-Version 1.02.122 - 
-==================================
-  Improve log_debug ioctl bit attrs.
+Version 1.02.122 - 9th April 2016
+=================================
+  Change log_debug ioctl flags from single characters into words.
 
 Version 1.02.121 - 26th March 2016
 ==================================


