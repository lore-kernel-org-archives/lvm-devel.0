From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:35:19 +0000 (UTC)
Subject: master - doc: update dmstats.8.in for groups
Message-ID: <20160705183519.B86B660E50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e69a34c15e96f5d329d55f0d5796d5370de39d9a
Commit:        e69a34c15e96f5d329d55f0d5796d5370de39d9a
Parent:        3914229d603e903cb6b33b50aedf2cf8185e74e8
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jun 22 18:36:10 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:29:50 2016 +0100

doc: update dmstats.8.in for groups

---
 WHATS_NEW_DM     |    5 ++
 man/dmstats.8.in |  156 +++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 149 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 79ac489..76a4106 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,10 @@
 Version 1.02.129 - 
 =================================
+  Update default dmstats field selections for groups.
+  Add 'obj_type', 'group_id', and 'statsname' fields to dmstats reports.
+  Add --area, --region, and --group to dmstats to control object selection.
+  Add --alias, --groupid, --regions to dmstats for group creation and deletion.
+  Add 'group' and 'ungroup' commands to dmstats.
   Allow dm_stats_delete_group() to optionally delete all group members.
   Add dm_stats_get_object_type() to return the type of object present.
   Add dm_stats_walk_init() allowing control of objects visited by walks.
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 1b7a499..5d8e910 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -1,4 +1,4 @@
-.TH DMSTATS 8 "Jul 25 2015" "Linux" "MAINTENANCE COMMANDS"
+.TH DMSTATS 8 "Jun 23 2016" "Linux" "MAINTENANCE COMMANDS"
 
 .de OPT_PROGRAMS
 .  RB \%[ \-\-allprograms | \-\-programid
@@ -110,6 +110,20 @@ dmstats \(em device-mapper statistics management
 .
 .HP
 .B dmstats
+.de CMD_GROUP
+.  ad l
+.  BR group
+.  RI [ device_name ]
+.  RB [ \-\-alias
+.  IR name ]
+.  RB [ \-\-alldevices ]
+.  RB [ \-\-regions
+.  IR regions ]
+.  ad b
+..
+.CMD_GROUP
+.HP
+.B dmstats
 .de CMD_HELP
 .  ad l
 .  BR help
@@ -126,6 +140,8 @@ dmstats \(em device-mapper statistics management
 .  RI [ device_name ]
 .  RB [ \-\-histogram ]
 .  OPT_PROGRAMS
+.  RB [ \-\-statstype
+.  IR type_list ]
 .  RB [ \-\-units
 .  IR units ]
 .  RB \%[ \-\-nosuffix ]
@@ -167,6 +183,8 @@ dmstats \(em device-mapper statistics management
 .  IR sort_fields ]
 .  RB [ \-S | \-\-select
 .  IR selection ]
+.  RB [ \-\-statstype
+.  IR type_list ]
 .  RB [ \-\-units
 .  IR units ]
 .  RB [ \-\-nosuffix ]
@@ -174,6 +192,18 @@ dmstats \(em device-mapper statistics management
 .  ad b
 ..
 .CMD_REPORT
+.HP
+.B dmstats
+.de CMD_UNGROUP
+.  ad l
+.  BR ungroup
+.  RI [ device_name ]
+.  RB [ \-\-alldevices ]
+.  RB [ \-\-groupid
+.  IR id ]
+.  ad b
+..
+.CMD_UNGROUP
 .
 .PD
 .ad b
@@ -199,6 +229,12 @@ commands require the use of \fB\-\-alldevices\fP when used in this way.
 .SH OPTIONS
 .
 .HP
+.BR \-\-alias
+.IR name
+.br
+Specify an alias name for a group.
+.
+.HP
 .BR \-\-alldevices
 .br
 If no device arguments are given allow operation on all devices when
@@ -250,6 +286,12 @@ Specify the iteration count for repeating reports. If the count
 argument is zero reports will continue to repeat until interrupted.
 .
 .HP
+.BR \-\-groupid
+.IR id
+.br
+Specify the group to operate on.
+.
+.HP
 .BR \-\-bounds
 .IR histogram_boundaries \c
 .RB [ ns | us | ms | s ]
@@ -346,6 +388,14 @@ default program ID for dmstats-managed regions is "dmstats".
 Specify the region to operate on.
 .
 .HP
+.BR \-\-regions
+.IR region_list
+.br
+Specify a list of regions to group. The group list is a comma-separated
+list of region identifiers. Continuous sequences of identifiers may be
+expressed as a hyphen separated range, for example: '1-10'.
+.
+.HP
 .BR \-\-relative
 .br
 If displaying the histogram report show relative (percentage) values
@@ -379,6 +429,20 @@ device. This causes a separate region to be allocated for each segment
 of the device.
 .
 .HP
+.BR \-\-statstype
+.IR type_list
+.br
+Filter the types of statistics object included in a report or listing
+according to the provided list. A report may include areas, regions,
+and user-defined groups of regions that report aggregate data for all
+group members.
+
+The list may be a single object type, a comma separated list of types,
+or the special value 'all'.
+
+The currently available object types are 'area', 'region' and 'group'.
+.
+.HP
 .BR \-\-units
 .RI [ units ] \c
 .RB [ h | H | \c
@@ -461,6 +525,28 @@ All regions registered on a device may be removed using
 
 To remove all regions on all devices both \fB\-\-allregions\fP and
 \fB\-\-alldevices\fP must be used.
+
+If a \fB\-\-groupid\fP is given instead of a \fB\-\-regionid\fP the
+command will attempt to delete the group and all regions that it
+contains.
+
+If a deleted region is the first member of a group of regions the group
+will also be removed.
+.
+.HP
+.CMD_GROUP
+.br
+Combine one or more statistics regions on the specified device into a
+group.
+
+The list of regions to be grouped is specified with \fB\-\-regions\fP
+and an optional alias may be assigned with \fB\-\-alias\fP. The set of
+regions is given as a comma-separated list of region identifiers. A
+continuous range of identifers spanning from \fBR1\fP to \fBR2\fP may
+be expressed as '\fBR1\fP-\fBR2\fP'.
+
+On success the group list and newly created \fBgroup_id\fP are
+printed to stdout.
 .
 .HP
 .CMD_HELP
@@ -471,16 +557,23 @@ the list of report fields.
 .HP
 .CMD_LIST
 .br
-List the statistics regions registered on the device. If the
-\fB\-\-allprograms\fP switch is given all regions will be listed
+List the statistics regions, areas, or groups registered on the device.
+If the \fB\-\-allprograms\fP switch is given all regions will be listed
 regardless of region program ID values.
 
-If \fB\-v\fP or \fB\-\-verbose\fP is given the report will include
-a row of information for each area contained in each region displayed.
+By default only regions and groups are included in list output. If
+\fB\-v\fP or \fB\-\-verbose\fP is given the report will also include a
+row of information for each configured group and for each area contained
+in each region displayed (regions that contain a single area are by
+default omitted from the verbose list since their properties are
+identical to the area that they contain - to view all regions regardless
+of the number of areas they contain use \fB\-\-statstype\fP).
+
+Specific combinations of objects may be selected using the
+\fB\-\-statstype\fP option.
 
 If \fB\-\-histogram\fP is given the report will include the bin count
 and latency boundary values for any configured histograms.
-.
 .HP
 .CMD_PRINT
 .br
@@ -490,7 +583,7 @@ present regions.
 .HP
 .CMD_REPORT
 .br
-Start a report for the specified region or for all present regions. If
+Start a report for the specified object or for all present objects. If
 the count argument is specified, the report will repeat at a fixed
 interval set by the \fB\-\-interval\fP option. The default interval is
 one second.
@@ -503,19 +596,41 @@ values and latency boundaries.
 
 If the \fB\-\-relative\fP is used the default histogram field displays
 bin values as a percentage of the total number of I/Os.
+
+Object types (areas, regions and groups) are selected using the
+\fB\-\-statstype\fP option.
 .
-.SH REGIONS AND AREAS
+.HP
+.CMD_UNGROUP
+.br
+Remove an existing group and return all the group's regions to their
+original state.
+
+The group to be removed is specified using \fB\-\-groupid\fP.
+.
+.SH REGIONS, AREAS, AND GROUPS
 .
 The device-mapper statistics facility allows separate performance
 counters to be maintained for arbitrary regions of devices. A region may
 span any range: from a single sector to the whole device. A region may
 be further sub-divided into a number of distinct areas (one or more),
-each with its own counter set.
+each with its own counter set. In this case a summary value for the
+entire region is also available for use in reports.
+
+In addition, one or more regions on one device can be combined into
+a statistics group allowing reporting of aggregate values for all
+regions and areas making up the group.
 
 By default new regions span the entire device. The \fB\-\-start\fP and
 \fB\-\-length\fP options allows a region of any size to be placed at any
 location on the device.
 
+Using offsets it is possible to create regions that map individual
+objects within a block device (for example: partitions, files in a file
+system, or stripes or other structures in a RAID volume). Groups allow
+several non-contiguous regions to be assembled together for reporting
+and data aggregation.
+
 A region may be either divided into the specified number of equal-sized
 areas, or into areas of the given size by specifying one of
 \fB\-\-areas\fP or \fB\-\-areasize\fP when creating a region with the
@@ -531,6 +646,19 @@ values).
 
 Depending on the sequence of create and delete operations, gaps may
 exist in the sequence of \fBregion_id\fP values for a particular device.
+
+The \fBregion_id\fP should be treated as an opaque identifier used to
+reference the region.
+.
+.P
+.B Group identifiers
+.P
+Groups are also assigned an integer identifier at creation time;
+like region identifiers, group identifiers are unique within the
+containing device.
+
+The \fBgroup_id\fP should be treated as an opaque identifier used to
+reference the group.
 .
 .SH REPORT FIELDS
 .
@@ -591,10 +719,10 @@ Percentage of CPU time during which I/O requests were issued to the
 device (bandwidth utilization for the device). Device saturation occurs
 when this value is close to 100%.
 .
-.SS Region and area meta fields
+.SS Group, region and area meta fields
 .
-Meta fields provide information about the region or area that the
-statistics values relate to. This includes the region and area
+Meta fields provide information about the groups, regions, or areas that
+the statistics values relate to. This includes the region and area
 identifier, start, length, and counts, as well as the program ID and
 auxiliary data values.
 .TP
@@ -636,6 +764,10 @@ The program ID value associated with this region.
 .B aux_data
 The auxiliary data value associated with this region.
 .TP
+.B group_id
+Group identifier. This is a non-negative integer returned by the dmstats
+\fBgroup\fP command when a statistics group is created.
+.TP
 .B interval_ns
 The estimated interval over which the current counter values have
 accumulated. The value is reported as an interger expressed in units


