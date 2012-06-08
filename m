From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Jun 2012 21:14:06 +0000 (UTC)
Subject: master - WHATS_NEW_DM: Update for release.
Message-ID: <20120608211406.3AB9C4036@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=389498764a5bd9b223a7c53a49a7061da1efa462
Commit:        389498764a5bd9b223a7c53a49a7061da1efa462
Parent:        e892557ac646f042b491cd27d1d9d39002ad7ee7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 8 22:13:33 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 8 22:13:33 2012 +0100

WHATS_NEW_DM: Update for release.

---
 WHATS_NEW_DM |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b5d110e..1246f19 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,17 +1,17 @@
-Version 1.02.75 - 
-================================
+Version 1.02.75 - 8th June 2012
+===============================
   Upstream source repo now fedorahosted.org git not sources.redhat.com CVS.
   Remove unsupported udev_get_dev_path libudev call used for checking udev dir.
   Set delay_resume_if_new on deptree snapshot origin.
   Log value chosen in _find_config_bool like other variable types do.
-  Synchronize with dead of dmeventd.
-  Rename (Blk)DevNames/DevNos dmsetup header to (Blk)DevNamesUsed/DevNosUsed.
+  Wait for dmeventd to exit after sending it DM_EVENT_CMD_DIE when restarting.
+  Append 'Used' to {Blk}DevNames/DevNos dmsetup report headers for clarity.
   Add configure --with-veritysetup for independent veritysetup tool.
-  Properly support passed in dmevent path in dm_event_register_handler().
+  Properly support supplied dmevent path in dm_event_register_handler().
   Remove dmeventd fifos on exit if they are not managed by systemd.
-  Use SD_ACTIVATION env. var. in systemd units to better detect systemd in use.
-  Do not run a new dmeventd instance on restart if there's no existing one.
-  Make the time window for reading fifo longer 5sec (1.02.73).
+  Use SD_ACTIVATION environment variable in systemd units to detect systemd.
+  Only start a new dmeventd instance on restart if one was already running.
+  Extend the time waited for input from dmeventd fifo to 5 secs. (1.02.73)
 
 Version 1.02.74 - 6th March 2012
 ================================


