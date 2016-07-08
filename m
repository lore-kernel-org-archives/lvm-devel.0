From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:27:08 +0000 (UTC)
Subject: master - doc: remove obsolete --statstype references from dmstats.8.in
Message-ID: <20160708182708.1095D610EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17cbcc85bdd31d6b1e0d3af8e43c39a8c58561b5
Commit:        17cbcc85bdd31d6b1e0d3af8e43c39a8c58561b5
Parent:        008c57714ae81986fbac0a2c5574b9891a481906
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 15:23:07 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

doc: remove obsolete --statstype references from dmstats.8.in

---
 man/dmstats.8.in |   39 +++++++++++----------------------------
 1 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 96aca01..ce1368f 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -148,8 +148,6 @@ dmstats \(em device-mapper statistics management
 .  RI [ device_name ]
 .  RB [ \-\-histogram ]
 .  OPT_PROGRAMS
-.  RB [ \-\-statstype
-.  IR type_list ]
 .  RB [ \-\-units
 .  IR units ]
 .  OPT_OBJECTS
@@ -193,8 +191,6 @@ dmstats \(em device-mapper statistics management
 .  IR sort_fields ]
 .  RB [ \-S | \-\-select
 .  IR selection ]
-.  RB [ \-\-statstype
-.  IR type_list ]
 .  RB [ \-\-units
 .  IR units ]
 .  RB [ \-\-nosuffix ]
@@ -469,20 +465,6 @@ the \fB\-\-nogroup\fP option is given. When grouping is enabled a group
 alias may be specified using the \fB\-\-alias\fP option.
 .
 .HP
-.BR \-\-statstype
-.IR type_list
-.br
-Filter the types of statistics object included in a report or listing
-according to the provided list. A report may include areas, regions,
-and user-defined groups of regions that report aggregate data for all
-group members.
-
-The list may be a single object type, a comma separated list of types,
-or the special value 'all'.
-
-The currently available object types are 'area', 'region' and 'group'.
-.
-.HP
 .BR \-\-units
 .RI [ units ] \c
 .RB [ h | H | \c
@@ -578,8 +560,8 @@ By default regions that map a file are placed into a group and the
 group alias is set to the basename of the file. This behaviour can be
 overridden with the \fB\-\-alias\fP and \fB\-\-nogroup\fP options.
 
-To display only group information when listing and reporting, use the
-\fB\-\-statstype\fP option with the 'group' type.
+Use the \fB\-\-group\fP option to only display information for groups
+when listing and reporting.
 .
 .HP
 .CMD_DELETE
@@ -635,13 +617,13 @@ regardless of region program ID values.
 By default only regions and groups are included in list output. If
 \fB\-v\fP or \fB\-\-verbose\fP is given the report will also include a
 row of information for each configured group and for each area contained
-in each region displayed (regions that contain a single area are by
-default omitted from the verbose list since their properties are
-identical to the area that they contain - to view all regions regardless
-of the number of areas they contain use \fB\-\-statstype\fP).
+in each region displayed.
 
-Specific combinations of objects may be selected using the
-\fB\-\-statstype\fP option.
+Regions that contain a single area are by default omitted from the
+verbose list since their properties are identical to the area that they
+contain - to view all regions regardless of the number of areas present
+use \fB\-\-region\fP). To also view the areas contained within regions
+use \fB\-\-area\fP.
 
 If \fB\-\-histogram\fP is given the report will include the bin count
 and latency boundary values for any configured histograms.
@@ -668,8 +650,9 @@ values and latency boundaries.
 If the \fB\-\-relative\fP is used the default histogram field displays
 bin values as a percentage of the total number of I/Os.
 
-Object types (areas, regions and groups) are selected using the
-\fB\-\-statstype\fP option.
+Object types (areas, regions and groups) to include in the report are
+selected using the \fB\-\-area\fP, \fB\-\-region\fP, and \fB\-\-group\fP
+options.
 .
 .HP
 .CMD_UNGROUP


