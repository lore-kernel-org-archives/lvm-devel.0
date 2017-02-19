From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 19 Feb 2017 23:46:58 +0000 (UTC)
Subject: master - man: dmstats update
Message-ID: <20170219234658.5747760563@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cd24e6de898f9f20a56430d4a6d55c635a65bc65
Commit:        cd24e6de898f9f20a56430d4a6d55c635a65bc65
Parent:        665479b818a7e43ca8176fcfdbe34f0fad03451e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 19 15:51:06 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 19 22:59:43 2017 +0100

man: dmstats update

Fixing colorization bugs
---
 man/dmstats.8.in |   27 +++++++++++----------------
 1 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 167711c..ba828dc 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -44,7 +44,7 @@ dmstats \(em device-mapper statistics management
 .B dmsetup
 .B stats
 .I command
-.RB [ options ]
+[OPTIONS]
 .sp
 .
 .PD 0
@@ -53,13 +53,13 @@ dmstats \(em device-mapper statistics management
 .de CMD_COMMAND
 .  ad l
 .  IR command
-.  RI [ device_name |
-.  RB [ \-u | \-\-uuid
-.  IR uuid ]
-.  RB | [ \-\-major
+.  IR device_name " |"
+.  BR \-\-major
 .  IR major
 .  BR \-\-minor
-.  IR minor ]
+.  IR minor " |"
+.  BR \-u | \-\-uuid
+.  IR uuid
 .  RB \%[ \-v | \-\-verbose]
 .  ad b
 ..
@@ -82,9 +82,7 @@ dmstats \(em device-mapper statistics management
 .de CMD_CREATE
 .  ad l
 .  BR create
-.  RB [ device_name...
-.  RB | file_path...
-.  RB | [ \-\-alldevices ]]
+.  IR device_name... | file_path... | \fB\-\-alldevices
 .  RB [ \-\-areas
 .  IR nr_areas | \fB\-\-areasize
 .  IR area_size ]
@@ -110,8 +108,7 @@ dmstats \(em device-mapper statistics management
 .de CMD_DELETE
 .  ad l
 .  BR delete
-.  RI [ device_name ]
-.  RB [ \-\-alldevices ]
+.  IR device_name | \fB\-\-alldevices
 .  OPT_PROGRAMS
 .  OPT_REGIONS
 .  ad b
@@ -123,10 +120,9 @@ dmstats \(em device-mapper statistics management
 .de CMD_GROUP
 .  ad l
 .  BR group
-.  RI [ device_name ]
+.  RI [ device_name | \fB\-\-alldevices ]
 .  RB [ \-\-alias
 .  IR name ]
-.  RB [ \-\-alldevices ]
 .  RB [ \-\-regions
 .  IR regions ]
 .  ad b
@@ -205,8 +201,7 @@ dmstats \(em device-mapper statistics management
 .de CMD_UNGROUP
 .  ad l
 .  BR ungroup
-.  RI [ device_name ]
-.  RB [ \-\-alldevices ]
+.  RI [ device_name | \fB\-\-alldevices ]
 .  RB [ \-\-groupid
 .  IR id ]
 .  ad b
@@ -217,7 +212,7 @@ dmstats \(em device-mapper statistics management
 .de CMD_UPDATE_FILEMAP
 .  ad l
 .  BR update_filemap
-.  RI file_path
+.  IR file_path
 .  RB [ \-\-groupid
 .  IR id ]
 .  ad b


