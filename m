From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Mar 2016 18:07:44 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160304180744.E139B60E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7b15ca5c9ac3645b8d714014f89dbcd6731b2b04
Commit:        7b15ca5c9ac3645b8d714014f89dbcd6731b2b04
Parent:        68ec240b99fca4e0860cb6e1b17ce4b888eb2585
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Mar 4 18:06:24 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Mar 4 18:06:24 2016 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 2b2c83e..4b10296 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.145(2)-git (2016-03-04)
+2.02.146(2)-git (2016-03-04)
diff --git a/VERSION_DM b/VERSION_DM
index 6307cc1..3c381cc 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.119-git (2016-03-04)
+1.02.120-git (2016-03-04)
diff --git a/WHATS_NEW b/WHATS_NEW
index 5452a0b..f29250e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.146 - 
+=================================
+
 Version 2.02.145 - 4th March 2016
 =================================
   Make it possible to use lvremove and lvrename on historical LVs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d54353d..4cdd97c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.120 - 
+=================================
+
 Version 1.02.119 - 4th March 2016
 =================================
   Fix dm_config_write_node and variants to return error on subsection failures.


