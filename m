From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 14 May 2016 01:12:33 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160514011233.50FB860D5D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57e9df7dc535bcba6124fce814323b63c6a0d779
Commit:        57e9df7dc535bcba6124fce814323b63c6a0d779
Parent:        15ca5883fb7911d231a3931d085cc593eab95a39
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat May 14 02:12:23 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat May 14 02:12:23 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 2380bd8..fc39fdb 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.154(2)-git (2016-05-14)
+2.02.155(2)-git (2016-05-14)
diff --git a/VERSION_DM b/VERSION_DM
index 41b15b7..fbe453d 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.125-git (2016-05-14)
+1.02.126-git (2016-05-14)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8ab4800..618e3dc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.155 - 
+================================
+
 Version 2.02.154 - 14th May 2016
 ================================
   Fix liblvm segfault after failure initialising lvmetad connection.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index beb3d46..b6703c7 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.126 - 
+================================
+
 Version 1.02.125 - 14th May 2016
 ================================
   Show library version in message even if dm driver version is unavailable.


