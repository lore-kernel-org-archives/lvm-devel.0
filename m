From: Bryn Reeves <bmr@fedoraproject.org>
Date: Thu, 13 Aug 2015 18:06:29 +0000 (UTC)
Subject: master - dmstats: replace --force with new stats-specific --alldevices
Message-ID: <20150813180629.6A22C61373@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b81ac5807bdbfdd0063db4f53cc6d310c2fe4fc
Commit:        6b81ac5807bdbfdd0063db4f53cc6d310c2fe4fc
Parent:        988ca743519839b283ebdbaaf06243cb0541b935
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Aug 13 14:42:55 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Aug 13 19:05:46 2015 +0100

dmstats: replace --force with new stats-specific --alldevices

The '--force' switch is only used by dmstats to allow either
creation or deletion of one or more regions on all devices.

These operations do not carry any risk: just a possible mess of
region IDs to be cleaned up.

Remove the use of '--force' for stats commands and change current
uses to a new '--alldevices' switch.
---
 WHATS_NEW_DM     |    1 +
 man/dmstats.8.in |   16 +++++++++++-----
 tools/dmsetup.c  |   16 ++++++++++------
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a72d3e0..45db0e4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,7 @@
 Version 1.02.105 - 
 ===================================
   Add more arg validation for dm_tree_node_add_cache_target().
+  Add --alldevices switch to replace use of --force for stats create / delete.
 
 Version 1.02.104 - 10th August 2015
 ===================================
diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index c5ef47f..3b9f032 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -27,6 +27,7 @@ dmstats \(em device-mapper statistics management
 .br
 .B dmstats create
 .I device_name
+.RB [ \-\-alldevices ]
 .RB [[ \-\-areas
 .IR nr_areas ]
 .RB |[ \-\-areasize
@@ -43,7 +44,7 @@ dmstats \(em device-mapper statistics management
 .br
 .B dmstats delete
 .I device_name
-.RB [ \-\-force ]
+.RB [ \-\-alldevices ]
 .RB [ \-\-allregions
 .RB | \-\-regionid
 .IR id ]
@@ -115,10 +116,14 @@ when run as 'dmsetup stats'.
 
 When no device argument is given dmstats will by default operate on all
 device-mapper devices present. The \fBcreate\fP and \fBdelete\fP
-commands require the use of \fB--force\fP when used in this way.
+commands require the use of \fB--alldevices\fP when used in this way.
 
 .SH OPTIONS
 .TP
+.B \-\-alldevices
+If no device arguments are given allow operation on all devices when
+creating or deleting regions.
+.TP
 .B \-\-allprograms
 Include regions from all program IDs for list and report operations.
 .TP
@@ -267,7 +272,7 @@ stdout.
 .TP
 .B delete
 .I [ device_name ]
-.RB [ \-\-force ]
+.RB [ \-\-alldevices ]
 .RB [ \-\-allregions
 .RB | \-\-regionid
 .IR id ]
@@ -282,7 +287,8 @@ of subsequent list, print, or report operations.
 All regions registered on a device may be removed using
 \fB\-\-allregions\fP.
 
-To remove all regions on all devices \fB\-\-force\fP must be used.
+To remove all regions on all devices both \fB--allregions\fP and
+\fB\-\-alldevices\fP must be used.
 .br
 .TP
 .B help
@@ -601,7 +607,7 @@ Created region: 0
 Delete all regions on all devices
 .br
 .br
-# dmstats delete --allregions --force
+# dmstats delete --alldevices --allregions
 .br
 .br
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 420e263..20ab3a0 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -120,6 +120,7 @@ enum {
 	READ_ONLY = 0,
 	ADD_NODE_ON_CREATE_ARG,
 	ADD_NODE_ON_RESUME_ARG,
+	ALL_DEVICES_ARG,
 	ALL_PROGRAMS_ARG,
 	ALL_REGIONS_ARG,
 	AREAS_ARG,
@@ -4418,9 +4419,9 @@ static int _stats_create(CMD_ARGS)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
-			if (!_switches[FORCE_ARG]) {
-				log_error("Creating regions on all devices "
-					  "requires --force.");
+			if (!_switches[ALL_DEVICES_ARG]) {
+				log_error("Please specify device(s) or use "
+					  "--alldevices.");
 				return 0;
 			}
 			return _process_all(cmd, subcommand, argc, argv, 0, _stats_create);
@@ -4506,9 +4507,9 @@ static int _stats_delete(CMD_ARGS)
 		name = names->name;
 	else {
 		if (argc == 1 && !_switches[UUID_ARG] && !_switches[MAJOR_ARG]) {
-			if (!_switches[FORCE_ARG]) {
-				log_error("Deleting regions from all devices "
-					  "requires --force.");
+			if (!_switches[ALL_DEVICES_ARG]) {
+				log_error("Please specify device(s) or use "
+					  "--alldevices.");
 				return 0;
 			}
 			return _process_all(cmd, subcommand, argc, argv, 0, _stats_delete);
@@ -5355,6 +5356,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 #ifdef HAVE_GETOPTLONG
 	static struct option long_options[] = {
 		{"readonly", 0, &ind, READ_ONLY},
+		{"alldevices", 0, &ind, ALL_DEVICES_ARG},
 		{"allprograms", 0, &ind, ALL_PROGRAMS_ARG},
 		{"allregions", 0, &ind, ALL_REGIONS_ARG},
 		{"areas", 1, &ind, AREAS_ARG},
@@ -5479,6 +5481,8 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 	optind = OPTIND_INIT;
 	while ((ind = -1, c = GETOPTLONG_FN(*argcp, *argvp, "cCfG:hj:m:M:no:O:rS:u:U:vy",
 					    long_options, NULL)) != -1) {
+		if (ind == ALL_DEVICES_ARG)
+			_switches[ALL_DEVICES_ARG]++;
 		if (ind == ALL_PROGRAMS_ARG)
 			_switches[ALL_PROGRAMS_ARG]++;
 		if (ind == ALL_REGIONS_ARG)


