From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 10 Aug 2016 02:03:09 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160810020309.6484460F2C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=480c1c95993a1a2903e580ca402ba6368088decd
Commit:        480c1c95993a1a2903e580ca402ba6368088decd
Parent:        37b8b84fee7459f0a78562c281c405484f25b9db
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 10 03:01:55 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 10 03:01:55 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index ed95ad7..5e46ebc 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.163(2)-git (2016-08-10)
+2.02.164(2)-git (2016-08-10)
diff --git a/VERSION_DM b/VERSION_DM
index aecc584..a5de990 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.133-git (2016-08-10)
+1.02.134-git (2016-08-10)
diff --git a/WHATS_NEW b/WHATS_NEW
index 36bac09..8f4fe9c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.164 -
+===================================
+
 Version 2.02.163 - 10th August 2016
 ===================================
   Add profile for lvmdbusd which uses lvm shell json report output.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2b32d76..7bbfd88 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.134 - 
+===================================
+
 Version 1.02.133 - 10th August 2016
 ===================================
   Add dm_report_destroy_rows/dm_report_group_output_and_pop_all for lvm shell.


