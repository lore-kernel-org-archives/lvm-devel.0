From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  9 Dec 2014 09:52:23 +0000 (UTC)
Subject: master - WHATS_NEW: f94f846 actually fixes DM issue, not LVM issue
Message-ID: <20141209095223.691896030E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5378a1a63e8a8d89cca9460051d473b7547404f9
Commit:        5378a1a63e8a8d89cca9460051d473b7547404f9
Parent:        f94f8463b0d3dddaa0e429123aba673d106f783e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 9 10:52:07 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 9 10:52:07 2014 +0100

WHATS_NEW: f94f846 actually fixes DM issue, not LVM issue

---
 WHATS_NEW    |    1 -
 WHATS_NEW_DM |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ff06b7b..9201f36 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,5 @@
 Version 2.02.115 -
 =====================================
-  Fix segfault while using --select with regex and --unbuffered for reporting.
   Fix automatic use of configure --enable-udev-systemd-background-jobs.
   Correctly rename active split LV with -splitmirrors for raid1.
   Add report/compact_output to lvm.conf to enable/disable compact report output.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dcd35fa..02b8045 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.93 -
 ====================================
+  Fix segfault while using selection with regex and unbuffered reporting.
   Add dm_report_compact_fields to remove empty fields from report output.
   Remove unimplemented dm_report_set_output_selection from libdevmapper.h.
 


