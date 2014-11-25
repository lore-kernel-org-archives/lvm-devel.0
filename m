From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 25 Nov 2014 14:10:01 +0000 (UTC)
Subject: master - post-release
Message-ID: <20141125141001.A547460D02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd3b6070aab5b50ab60f8434ca6efd3736e927be
Commit:        cd3b6070aab5b50ab60f8434ca6efd3736e927be
Parent:        2aca8347243b64751a98052d1a9801b489d48c4c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 24 17:48:25 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 24 17:48:25 2014 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 77c461d..0f1a69f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.113(2)-git (2014-11-24)
+2.02.114(2)-git (2014-11-24)
diff --git a/VERSION_DM b/VERSION_DM
index 1b591a5..13ce0a0 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.92-git (2014-11-24)
+1.02.93-git (2014-11-24)
diff --git a/WHATS_NEW b/WHATS_NEW
index 780050d..a19cdb9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.114 - 
+=====================================
+
 Version 2.02.113 - 24th November 2014
 =====================================
   Add --cachepolicy and --cachesettings options to lvchange.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 45d3ece..6eafed6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.93 - 
+====================================
+
 Version 1.02.92 - 24th November 2014
 ====================================
   Fix memory corruption with sorting empty string lists (1.02.86).


