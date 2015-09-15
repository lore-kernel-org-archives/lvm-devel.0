From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 15 Sep 2015 13:09:22 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150915130922.26EA8605B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a729b1aa294ab4525e09c83f392560bcf59a5b81
Commit:        a729b1aa294ab4525e09c83f392560bcf59a5b81
Parent:        548c09acfca8970cafe74f43e1944b5f20f540be
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 15 13:17:50 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 15 13:17:50 2015 +0100

pre-release

---
 VERSION             |    2 +-
 VERSION_DM          |    2 +-
 WHATS_NEW           |    4 ++--
 WHATS_NEW_DM        |    4 ++--
 libdm/libdm-stats.c |    2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 4f600d1..fbf246a 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.131(2)-git (2015-09-05)
+2.02.131(2)-git (2015-09-15)
diff --git a/VERSION_DM b/VERSION_DM
index 25d799d..1c01d02 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.108-git (2015-09-05)
+1.02.108-git (2015-09-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index 8f87617..b15ae48 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.131 - 
-=====================================
+Version 2.02.131 - 15th September 2015
+======================================
   Rename 'make install_full_man' to install_all_man and add all_man target.
   Fix vgimportclone cache_dir path name (2.02.115).
   Swapping of LV identifiers handles more complex LVs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9e30786..4e2f515 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.108 - 
-=====================================
+Version 1.02.108 - 15th September 2015
+======================================
   Do not check for full thin pool when activating without messages (1.02.107).
 
 Version 1.02.107 - 5th September 2015
diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index ee62fe6..d3ae1f2 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -199,7 +199,7 @@ static void _stats_histograms_destroy(struct dm_pool *mem,
 		return;
 
 	/*
-	 * Only the first histogram needs to be freed explicitly.
+	 * Free everything in the pool back to the first histogram.
 	 */
 	if (region->counters[0].histogram)
 		dm_pool_free(mem, region->counters[0].histogram);


