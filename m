From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:08:29 +0000 (UTC)
Subject: master - dmstats: add --notimesuffix switch
Message-ID: <20150903210829.A0A6B603F2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84d88cb2cf11ecb3c186477cd3c79cef0fa1c378
Commit:        84d88cb2cf11ecb3c186477cd3c79cef0fa1c378
Parent:        f09e4f7b10db5051b40fe50b5d6a99a171ce04ca
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Sep 3 21:55:25 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Sep 3 22:04:10 2015 +0100

dmstats: add --notimesuffix switch

Add a switch to disable the printing of time unit suffixes in
histogram bounds descriptions.
---
 man/dmstats.8.in |    8 +++++++-
 tools/dmsetup.c  |    6 +++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index daa489d..1e19524 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -79,6 +79,7 @@ dmstats \(em device-mapper statistics management
 .RB [ \-\-units
 .IR units ]
 .RB [ \-\-nosuffix ]
+.RB [ \-\-notimesuffix ]
 .br
 .B dmstats list
 .RI [ device_name ]
@@ -88,7 +89,7 @@ dmstats \(em device-mapper statistics management
 .RB [ \-\-units
 .IR units ]
 .RB [ \-\-nosuffix ]
-.RB [ \-\-nosuffix ]
+.RB [ \-\-notimesuffix ]
 .RB [ \-v | \-\-verbose \ [ \-v | \-\-verbose ]
 .br
 .B dmstats print
@@ -121,6 +122,7 @@ dmstats \(em device-mapper statistics management
 .RB [ \-\-units
 .IR units ]
 .RB [ \-\-nosuffix ]
+.RB [ \-\-notimesuffix ]
 .br
 .ad b
 .SH DESCRIPTION
@@ -206,6 +208,10 @@ Specify the minor number.
 Suppress the suffix on output sizes.  Use with \fB\-\-units\fP
 (except h and H) if processing the output.
 .TP
+.B \-\-notimesuffix
+Suppress the suffix on output time values. Histogram boundary values
+will be reported in units of nanoseconds.
+.TP
 .BR \-o | \-\-options
 Specify which report fields to display.
 .TP
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 9c9711d..ea30a3c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -187,6 +187,7 @@ enum {
 	NOOPENCOUNT_ARG,
 	NOSUFFIX_ARG,
 	NOTABLE_ARG,
+	NOTIMESUFFIX_ARG,
 	UDEVCOOKIE_ARG,
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
@@ -3456,7 +3457,7 @@ static const char *_get_histogram_string(const struct dm_stats *dms, int rel,
 	flags |= (rel) ? DM_HISTOGRAM_PERCENT
 			: 0;
 
-	flags |= DM_HISTOGRAM_SUFFIX;
+	flags |= (_switches[NOTIMESUFFIX_ARG]) ? 0 : DM_HISTOGRAM_SUFFIX;
 
 	/* FIXME: make unit conversion optional. */
 	return dm_histogram_to_string(dmh, -1, 0, flags);
@@ -5704,6 +5705,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		{"noopencount", 0, &ind, NOOPENCOUNT_ARG},
 		{"nosuffix", 0, &ind, NOSUFFIX_ARG},
 		{"notable", 0, &ind, NOTABLE_ARG},
+		{"notimesuffix", 0, &ind, NOTIMESUFFIX_ARG},
 		{"udevcookie", 1, &ind, UDEVCOOKIE_ARG},
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
@@ -5857,6 +5859,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 			_switches[NOSUFFIX_ARG]++;
 		if (c == 'n' || ind == NOTABLE_ARG)
 			_switches[NOTABLE_ARG]++;
+		if (ind == NOTIMESUFFIX_ARG)
+			_switches[NOTIMESUFFIX_ARG]++;
 		if (c == 'o' || ind == OPTIONS_ARG) {
 			_switches[OPTIONS_ARG]++;
 			_string_args[OPTIONS_ARG] = optarg;


