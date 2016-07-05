From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue,  5 Jul 2016 18:55:32 +0000 (UTC)
Subject: master - doc: document --area, --region, and --group in dmstats.8.in
Message-ID: <20160705185532.6F72E61153@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=93034d0b695a72deebe51b3eb7075366728ba0f7
Commit:        93034d0b695a72deebe51b3eb7075366728ba0f7
Parent:        e9c6fd3cff806344f1d32bc16daadd732d0acef6
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Jul 5 19:28:19 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Jul 5 19:53:17 2016 +0100

doc: document --area, --region, and --group in dmstats.8.in

---
 man/dmstats.8.in |   42 ++++++++++++++++++++++++++++++++++--------
 1 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 8530cae..6bbcc63 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -9,6 +9,11 @@
 .  RB \%[ \-\-allregions | \-\-regionid
 .  IR id ]
 ..
+.de OPT_OBJECTS
+.  RB [ \-\-area ]
+.  RB [ \-\-region ]
+.  RB [ \-\-group ]
+..
 .
 .\" Print units suffix, use with arg to print human
 .\" man2html can't handle too many changes per command
@@ -144,6 +149,7 @@ dmstats \(em device-mapper statistics management
 .  IR type_list ]
 .  RB [ \-\-units
 .  IR units ]
+.  OPT_OBJECTS
 .  RB \%[ \-\-nosuffix ]
 .  RB [ \-\-notimesuffix ]
 .  RB \%[ \-v | \-\-verbose [ \-v | \-\-verbose ]]
@@ -179,6 +185,7 @@ dmstats \(em device-mapper statistics management
 .  RB [ \-\-histogram ]
 .  OPT_PROGRAMS
 .  OPT_REGIONS
+.  OPT_OBJECTS
 .  RB [ \-O | \-\-sort
 .  IR sort_fields ]
 .  RB [ \-S | \-\-select
@@ -252,6 +259,12 @@ Include all present regions for commands that normally accept a single
 region identifier.
 .
 .HP
+.BR \-\-area
+.br
+When peforming a list or report, include objects of type area in the
+results.
+.
+.HP
 .BR \-\-areas
 .IR nr_areas
 .br
@@ -268,14 +281,6 @@ optional suffix selects units of:
 .HELP_UNITS
 .
 .HP
-.BR \-\-userdata
-.IR user_data
-.br
-Specify user data (a word) to be stored with a new region. The value
-is added to any internal auxilliary data (for example, group
-information), and stored with the region in the aux_data field provided
-by the kernel. Whitespace is not permitted.
-.HP
 .BR \-\-clear
 .br
 When printing statistics counters, also atomically reset them to zero.
@@ -288,6 +293,12 @@ Specify the iteration count for repeating reports. If the count
 argument is zero reports will continue to repeat until interrupted.
 .
 .HP
+.BR \-\-group
+.br
+When peforming a list or report, include objects of type group in the
+results.
+.
+.HP
 .BR \-\-groupid
 .IR id
 .br
@@ -384,6 +395,12 @@ program ID in order to select only regions with a matching value. The
 default program ID for dmstats-managed regions is "dmstats".
 .
 .HP
+.BR \-\-region
+.br
+When peforming a list or report, include objects of type region in the
+results.
+.
+.HP
 .BR \-\-regionid
 .IR id
 .br
@@ -457,6 +474,15 @@ All sizes are output in these units:
 Can also specify custom units e.g. \fB\-\-units\ 3M\fP.
 .
 .HP
+.BR \-\-userdata
+.IR user_data
+.br
+Specify user data (a word) to be stored with a new region. The value
+is added to any internal auxilliary data (for example, group
+information), and stored with the region in the aux_data field provided
+by the kernel. Whitespace is not permitted.
+.
+.HP
 .BR \-u | \-\-uuid
 .br
 Specify the uuid.


