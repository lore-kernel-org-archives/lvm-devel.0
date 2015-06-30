From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 30 Jun 2015 16:17:23 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150630161723.55F0860E0E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3af8b062654efda7f07196ede6e25262c88852c
Commit:        a3af8b062654efda7f07196ede6e25262c88852c
Parent:        92138badd48efef74ecb16213ed8a322ef33119c
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jun 30 17:11:21 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jun 30 17:11:21 2015 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 +++-
 WHATS_NEW_DM |    4 ++--
 4 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/VERSION b/VERSION
index 737d5a2..ecebfae 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.123(2)-git (2015-06-20)
+2.02.123(2)-git (2015-06-30)
diff --git a/VERSION_DM b/VERSION_DM
index 7d2906a..812eaa3 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.100-git (2015-06-20)
+1.02.100-git (2015-06-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index 9a7ebe1..66fbfcf 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.123 - 
+Version 2.02.123 - 30th June 2015
 =================================
   Add report/time_format lvm.conf option to define time format for report.
   Fix makefile shell compare == when building lvmetad lvmpolld (2.02.120).
@@ -6,6 +6,8 @@ Version 2.02.123 -
   Add undocumented environment variables to lvm man page. (2.02.119)
   Add device synchronization point before activating a new snapshot.
   Add --withspaces to lvmconfig to add spaces in output for better readability.
+  Add custom main function to libdaemon.
+  Use lvmetad to track out-of-date metadata discovered.
 
 Version 2.02.122 - 20th June 2015
 =================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index bef2e0d..9d04847 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.100 - 
-================================
+Version 1.02.100 - 30th June 2015
+=================================
   Add since, after, until and before time operators to be used in selection.
   Add support for time in reports and selection: DM_REPORT_FIELD_TYPE_TIME.
   Support report reserved value ranges: DM_REPORT_FIELD_RESERVED_VALUE_RANGE.


