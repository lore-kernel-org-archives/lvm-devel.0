From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:15 -0400
Subject: master - dmfilemapd: cast return value of strto* functions when needed
Message-ID: <201703300904.v2U94Frn019946@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e74e43896c3b35584e3edfb76fa407adbed862c
Commit:        5e74e43896c3b35584e3edfb76fa407adbed862c
Parent:        834574cc27851266bd288163cddcab36b4db22cb
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:32:55 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:02:31 2017 +0100

dmfilemapd: cast return value of strto* functions when needed

---
 daemons/dmfilemapd/dmfilemapd.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 7939c48..88f8af2 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -225,7 +225,7 @@ static int _is_open(const char *path)
 	while ((proc_dp = readdir(proc_d)) != NULL) {
 		if (!isdigit(proc_dp->d_name[0]))
 			continue;
-		pid = strtol(proc_dp->d_name, NULL, 10);
+		pid = (pid_t) strtol(proc_dp->d_name, NULL, 10);
 		if (!pid)
 			continue;
 		if (_is_open_in_pid(pid, path)) {
@@ -280,7 +280,7 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 	fm->nr_regions = 1;
 
 	/* parse <fd> */
-	fm->fd = strtol(argv[0], &endptr, 10);
+	fm->fd = (int) strtol(argv[0], &endptr, 10);
 	if (*endptr) {
 		_early_log("Could not parse file descriptor: %s", argv[0]);
 		return 0;
@@ -334,7 +334,7 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 
 	/* parse [<foreground>[<verbose>]] */
 	if (argc) {
-		_foreground = strtol(argv[0], &endptr, 10);
+		_foreground = (int) strtol(argv[0], &endptr, 10);
 		if (*endptr) {
 			_early_log("Could not parse debug argument: %s.",
 				   argv[0]);
@@ -343,7 +343,7 @@ static int _parse_args(int argc, char **argv, struct filemap_monitor *fm)
 		argc--;
 		argv++;
 		if (argc) {
-			_verbose = strtol(argv[0], &endptr, 10);
+			_verbose = (int) strtol(argv[0], &endptr, 10);
 			if (*endptr) {
 				_early_log("Could not parse verbose "
 					   "argument: %s", argv[0]);


