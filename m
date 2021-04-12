From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:48 +0000 (GMT)
Subject: main - man: hyphenation improvements
Message-ID: <20210412075548.B10C239FCC6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19ff0d983ee013711b88b66acc625a532f31b22b
Commit:        19ff0d983ee013711b88b66acc625a532f31b22b
Parent:        53fa1582d97713f33364e5f77c51ab412762e295
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 11 00:15:51 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

man: hyphenation improvements

---
 man/dmfilemapd.8_main | 11 ++++++-----
 man/dmsetup.8_main    | 49 +++++++++++++++++++++++++++++++++++++------------
 2 files changed, 43 insertions(+), 17 deletions(-)

diff --git a/man/dmfilemapd.8_main b/man/dmfilemapd.8_main
index 8e19e4b03..c93349ad4 100644
--- a/man/dmfilemapd.8_main
+++ b/man/dmfilemapd.8_main
@@ -7,6 +7,7 @@
 .de OPT_GROUP
 .  RB [ group_id ]
 ..
+.
 .de OPT_PATH
 .  RB [ abs_path ]
 ..
@@ -16,7 +17,7 @@
 ..
 .
 .de OPT_DEBUG
-.  RB [ foreground [ verbose ] ]
+.  RB [ foreground [ verbose ]]
 ..
 .
 .SH NAME
@@ -27,12 +28,14 @@ dmfilemapd \(em device-mapper filemap monitoring daemon
 .
 .de CMD_DMFILEMAPD
 .  ad l
+.  nh
 .  IR dmfilemapd
 .  OPT_FD
 .  OPT_GROUP
 .  OPT_PATH
 .  OPT_MODE
 .  OPT_DEBUG
+.  hy
 .  ad b
 ..
 .CMD_DMFILEMAPD
@@ -103,7 +106,6 @@ between 1 and 3, stdio will be retained and the daemon will log
 messages to stdout and stderr that match the specified verbosity
 level.
 .
-.
 .SH MODES
 .
 The file map monitoring daemon can monitor files in two distinct
@@ -113,7 +115,6 @@ cause the daemon to terminate.
 
 In both modes, the daemon will always shut down when the group
 being monitored is deleted.
-
 .P
 .B Follow inode
 .P
@@ -125,7 +126,6 @@ to the file.
 
 This mode is useful if the file is expected to be renamed, or moved
 within the file system, while it is being monitored.
-
 .P
 .B Follow path
 .P
@@ -173,6 +173,7 @@ Start the daemon in the background, in follow-path mode
 Start the daemon in follow-inode mode, disable forking and enable
 verbose logging
 .br
+.ad l
 #
 .B dmfilemapd 3 0 /var/tmp/data inode 1 3 3< /var/tmp/data
 .br
@@ -196,7 +197,7 @@ exiting _filemap_monitor_get_events() with deleted=0, check=0
 .br
 Waiting for check interval
 .br
-.P
+.ad b
 .
 .SH AUTHORS
 .
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 2e15e699c..528dc877a 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -21,15 +21,17 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_CREATE
 .  ad l
+.  nh
 .  BR create
 .  IR device_name
 .  RB [ -u | --uuid
 .  IR uuid ]
-.  RB \%[ --addnodeoncreate | --addnodeonresume ]
-.  RB \%[ -n | --notable | --table
-.  IR \%table | table_file ]
+.  RB [ --addnodeoncreate |\: --addnodeonresume ]
+.  RB [ -n | --notable |\: --table
+.  IR table |\: table_file ]
 .  RB [ --readahead
-.  RB \%[ + ] \fIsectors | auto | none ]
+.  RB [ + ] \fIsectors |\: auto | none ]
+.  hy
 .  ad b
 ..
 .CMD_CREATE
@@ -77,14 +79,15 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_INFOLONG
 .  ad l
+.  nh
 .  BR info
 .  BR -c | -C | --columns
 .  RB [ --count
 .  IR count ]
 .  RB [ --interval
 .  IR seconds ]
-.  RB \%[ --nameprefixes ]
-.  RB \%[ --noheadings ]
+.  RB [ --nameprefixes ]
+.  RB [ --noheadings ]
 .  RB [ -o
 .  IR fields ]
 .  RB [ -O | --sort
@@ -92,6 +95,7 @@ dmsetup \(em low level logical volume management
 .  RB [ --separator
 .  IR separator ]
 .  RI [ device_name ]
+.  hy
 .  ad b
 ..
 .CMD_INFOLONG
@@ -112,6 +116,7 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_LS
 .  ad l
+.  nh
 .  BR ls
 .  RB [ --target
 .  IR target_type ]
@@ -120,6 +125,7 @@ dmsetup \(em low level logical volume management
 .  RB [ --tree ]
 .  RB [ -o
 .  IR options ]
+.  hy
 .  ad b
 ..
 .CMD_LS
@@ -222,12 +228,14 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_SETGEOMETRY
 .  ad l
+.  nh
 .  BR setgeometry
 .  IR device_name
 .  IR cyl
 .  IR head
 .  IR sect
 .  IR start
+.  hy
 .  ad b
 ..
 .CMD_SETGEOMETRY
@@ -267,10 +275,12 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_SUSPEND
 .  ad l
+.  nh
 .  BR suspend
 .  RB [ --nolockfs ]
 .  RB [ --noflush ]
 .  IR device_name ...
+.  hy
 .  ad b
 ..
 .CMD_SUSPEND
@@ -279,12 +289,14 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_TABLE
 .  ad l
+.  nh
 .  BR table
 .  RB [ --concise ]
 .  RB [ --target
 .  IR target_type ]
 .  RB [ --showkeys ]
 .  RI [ device_name ...]
+.  hy
 .  ad b
 ..
 .CMD_TABLE
@@ -353,10 +365,12 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_WAIT
 .  ad l
+.  nh
 .  BR wait
 .  RB [ --noflush ]
 .  IR device_name
 .  RI [ event_nr ]
+.  hy
 .  ad b
 ..
 .CMD_WAIT
@@ -365,11 +379,13 @@ dmsetup \(em low level logical volume management
 .B dmsetup
 .de CMD_WIPE_TABLE
 .  ad l
+.  nh
 .  BR wipe_table
 .  IR device_name ...
 .  RB [ -f | --force ]
 .  RB [ --noflush ]
 .  RB [ --nolockfs ]
+.  hy
 .  ad b
 ..
 .CMD_WIPE_TABLE
@@ -1032,8 +1048,11 @@ A concise representation of one of more devices.
 - A semi-colon separates devices.
 .TP
 The representation of a device takes the form:
-.sp
-<name>,<uuid>,<minor>,<flags>,<table>[,<table>+][;<dev_name>,<uuid>,<minor>,<flags>,<table>[,<table>+]]
+.ad l
+.nh
+<name>,<uuid>,\:<minor>,<flags>,\:<table>\:[,<table>+]\:[;<dev_name>,<uuid>,\:<minor>,<flags>,<table>\:[,<table>+]]
+.hy
+.ad b
 .TP
 The fields are:
 .
@@ -1063,13 +1082,19 @@ One line of the table. See TABLE FORMAT above.
 .
 # A simple linear read-only device
 .br
-test-linear-small,,,ro,0 2097152 linear /dev/loop0 0, 2097152 2097152 linear /dev/loop1 0
-.br
+.ad l
+.nh
+test-linear-small,,,ro,\:0 2097152 linear /dev/loop0 0,\:2097152 2097152 linear /dev/loop1 0
+.hy
+.ad b
 .sp
 # Two linear devices
 .br
-test-linear-small,,,,0 2097152 linear /dev/loop0 0;test-linear-large,,,, 0 2097152 linear /dev/loop1 0, 2097152 2097152 linear /dev/loop2 0
-.br
+.ad l
+.nh
+test-linear-small,,,,\:0 2097152 linear /dev/loop0 0;\:test-linear-large,\:,,,\:0 2097152 linear /dev/loop1 0, 2097152 2097152 linear /dev/loop2 0
+.hy
+.ad b
 .
 .SH ENVIRONMENT VARIABLES
 .


