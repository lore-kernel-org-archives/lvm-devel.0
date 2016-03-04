From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  4 Mar 2016 18:07:42 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160304180742.CA32B60E29@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=68ec240b99fca4e0860cb6e1b17ce4b888eb2585
Commit:        68ec240b99fca4e0860cb6e1b17ce4b888eb2585
Parent:        6c781751261a6e75f8e3e63f5efbecf467d63476
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Mar 4 17:59:21 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Mar 4 17:59:21 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 10d6493..2b2c83e 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.145(2)-git (2016-02-26)
+2.02.145(2)-git (2016-03-04)
diff --git a/VERSION_DM b/VERSION_DM
index d930b03..6307cc1 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.119-git (2016-02-26)
+1.02.119-git (2016-03-04)
diff --git a/WHATS_NEW b/WHATS_NEW
index cbdd14f..5452a0b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.145 - 
-=====================================
+Version 2.02.145 - 4th March 2016
+=================================
   Make it possible to use lvremove and lvrename on historical LVs.
   For historical LVs, report 'none' for lv_layout and 'history' for lv_role.
   Add full_{ancestors,descendants} fields to report LV ancestry with history.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 109249a..d54353d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.119 -
-=====================================
+Version 1.02.119 - 4th March 2016
+=================================
   Fix dm_config_write_node and variants to return error on subsection failures.
   Remove 4096 char limit due to buffer size if writing dm_config_node.
 


