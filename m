From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 10 Aug 2015 00:08:10 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150810000810.3707060664@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0b05048341c6ededae7b271c08101decd7d0d184
Commit:        0b05048341c6ededae7b271c08101decd7d0d184
Parent:        41001dbfdd54674ead6051d06a8b89701dce68c5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Aug 10 00:40:42 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Aug 10 00:40:42 2015 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    9 ++++++---
 WHATS_NEW_DM |   20 +++++++++++---------
 4 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/VERSION b/VERSION
index 131a92a..2d1f7f0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.127(2)-git (2015-07-24)
+2.02.127(2)-git (2015-08-10)
diff --git a/VERSION_DM b/VERSION_DM
index f28fdfe..be3c65b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.104-git (2015-07-24)
+1.02.104-git (2015-08-10)
diff --git a/WHATS_NEW b/WHATS_NEW
index 1e04acb..85288e0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,11 @@
-Version 2.02.127 - 
-=================================
+Version 2.02.127 - 10th August 2015
+===================================
   Do not init filters, locking, lvmetad, lvmpolld if command doesn't use it.
-  Recognise vg/lv name format in dmsetup.
+  Order fields in struct cmd_context more logically.
+  Add lock_type to lvmcache VG summary and info structs.
   Fix regression in cache causing some PVs to bypass filters (2.02.105).
+  Make configure --enable-realtime the default now.
+  Update .gitignore and configure.in files to reflect usage of current tree.
 
 Version 2.02.126 - 24th July 2015
 =================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1753322..59a559f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,25 +1,27 @@
-Version 1.02.104 -
-=================================
+Version 1.02.104 - 10th August 2015
+===================================
   Add dmstats.8 man page
+  Add dmstats --segments switch to create one region per device segment.
+  Add dmstats --regionid, --allregions to specify a single / all stats regions.
+  Add dmstats --allprograms for stats commands that filter by program ID.
+  Add dmstats --auxdata and --programid args to specify aux data and program ID.
   Add report stats sub-command to provide repeating stats reports.
   Add clear, delete, list, and print stats sub-commands.
-  Add --segments switch to create one region per device segment.
   Add create stats sub-command and --start, --length, --areas and --areasize.
   Recognize 'dmstats' as an alias for 'dmsetup stats' when run with this name.
   Add a 'stats' command to dmsetup to configure, manage and report stats data.
-  Add --regionid, --allregions to specify a single stats region or all regions.
-  Add --allprograms for stats commands that filter by program ID.
-  Add --auxdata and --programid arguments to specify aux data and program ID.
-  Add statistics fields to -o <field>
+  Add statistics fields to dmsetup -o.
   Add libdm-stats library to allow management of device-mapper statistics.
-  Add --nosuffix to suppress unit suffixes in report output.
-  Add --units to control report field output units.
+  Add --nosuffix to suppress dmsetup unit suffixes in report output.
+  Add --units to control dmsetup report field output units.
   Add support to redisplay column headings for repeating column reports.
   Fix report header and row resource leaks.
   Report timestamps of ioctls with dmsetup -vvv.
   Recognize report field name variants without any underscores too.
   Add dmsetup --interval and --count to repeat reports at specified intervals.
   Add dm_timestamp functions to libdevmapper.
+  Recognise vg/lv name format in dmsetup.
+  Move size display code to libdevmapper as dm_size_to_string.
 
 Version 1.02.103 - 24th July 2015
 =================================


