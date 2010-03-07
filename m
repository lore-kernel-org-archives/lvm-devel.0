From: Milan Broz <mbroz@redhat.com>
Date: Sun,  7 Mar 2010 11:32:43 +0100
Subject: [PATCH 1/2] Add --showkeys parameter description into dmsetup man page.
Message-ID: <1267957964-2436-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Also fix minor warning (-c is parameter) in man page formatting.
---
 WHATS_NEW_DM     |    1 +
 man/dmsetup.8.in |    9 ++++++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index dd9ed07..425ab88 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.45 -
 ====================================
+  Add --showkeys parameter description into dmsetup man page.
 
 Version 1.02.44 - 15th February 2010
 ====================================
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index af5422e..8a5eca8 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -54,7 +54,7 @@ dmsetup \- low level logical volume management
 .I [device_name]
 .br
 .B dmsetup table
-.I [--target target_type]
+.I [--target target_type] [--showkeys]
 .I [device_name]
 .br
 .B dmsetup wait
@@ -210,7 +210,8 @@ Outputs some brief information about the device in the form:
     Number of targets in the live table
 .br
     UUID
-.IP \fBinfo -c|-C|--columns
+.IP \fBinfo
+.I -c|-C|--columns
 .I [--noheadings] [--separator separator] [-o fields] [-O|--sort sort_fields]
 .I [device_name]
 .br
@@ -312,13 +313,15 @@ Some targets such as recent (October 2006) versions of multipath may support
 the --noflush option.  This lets outstanding I/O that has not yet reached the
 device to remain unflushed.
 .IP \fBtable
-.I [--target target_type]
+.I [--target target_type] [--showkeys]
 .I [device_name]
 .br
 Outputs the current table for the device in a format that can be fed
 back in using the create or load commands.
 With --target, only information relating to the specified target type
 is displayed.
+By default encryption keys are suppressed in table output (crypt target)
+unless --showkeys parameter is supplied.
 .IP \fBtargets
 .br
 Displays the names and versions of the currently-loaded targets.
-- 
1.7.0


