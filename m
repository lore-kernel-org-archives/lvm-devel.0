From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 23 Jul 2014 15:24:13 +0000 (UTC)
Subject: master - post-release
Message-ID: <20140723152413.CA2F460D56@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=321bed713727a81d743b42c98c1fd91c18ecddb5
Commit:        321bed713727a81d743b42c98c1fd91c18ecddb5
Parent:        52217f6ebd3dee25808344a9425fc085427075e4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 23 16:23:52 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 23 16:23:52 2014 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index fa96924..79c463f 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.108(2)-git (2014-07-23)
+2.02.109(2)-git (2014-07-23)
diff --git a/VERSION_DM b/VERSION_DM
index 307f41d..a6ea805 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.87-git (2014-07-23)
+1.02.88-git (2014-07-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index e443834..64b174b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.109 - 
+=================================
+
 Version 2.02.108 - 23rd July 2014
 =================================
   Add lvscan --cache which re-scans constituents of a particular LV.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a39099f..ad25215 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.88 - 
+================================
+
 Version 1.02.87 - 23rd July 2014
 ================================
   Fix dm_report_field_string_list to handle delimiter with multiple chars.


