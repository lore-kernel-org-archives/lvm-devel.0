From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 31 Jul 2015 21:54:30 +0000 (UTC)
Subject: master - dmsetup: Use argcp and argvp.
Message-ID: <20150731215430.4C141607A8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=519c309952245a0d6221a3297399a310acdb8144
Commit:        519c309952245a0d6221a3297399a310acdb8144
Parent:        a161e29c59e01605401c9096f5ad5ace2ae03d9a
Author:        Bryn M. Reeves <breeves@redhat.com>
AuthorDate:    Fri Jul 31 22:53:38 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 31 22:53:38 2015 +0100

dmsetup: Use argcp and argvp.

---
 tools/dmsetup.c |   66 +++++++++++++++++++++++++++---------------------------
 1 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 4b23d72..bc71b35 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3371,7 +3371,7 @@ error:
 	return 0;
 }
 
-static int _process_losetup_switches(const char *base, int *argc, char ***argv,
+static int _process_losetup_switches(const char *base, int *argcp, char ***argvp,
 				     const char *dev_dir)
 {
 	int c;
@@ -3388,7 +3388,7 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((c = GETOPTLONG_FN(*argc, *argv, "ade:fo:v",
+	while ((c = GETOPTLONG_FN(*argcp, *argvp, "ade:fo:v",
 				  long_options, NULL)) != -1 ) {
 		if (c == ':' || c == '?')
 			return 0;
@@ -3406,8 +3406,8 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 			_switches[VERBOSE_ARG]++;
 	}
 
-	*argv += optind ;
-	*argc -= optind ;
+	*argvp += optind ;
+	*argcp -= optind ;
 
 	if (encrypt_loop){
 		fprintf(stderr, "%s: Sorry, cryptoloop is not yet implemented "
@@ -3424,33 +3424,33 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 	if (find) {
 		fprintf(stderr, "%s: Sorry, find is not yet implemented "
 				"in this version.\n", base);
-		if (!*argc)
+		if (!*argcp)
 			return 0;
 	}
 
-	if (!*argc) {
+	if (!*argcp) {
 		fprintf(stderr, "%s: Please specify loop_device.\n", base);
 		_losetup_usage(stderr);
 		return 0;
 	}
 
-	if (!(device_name = parse_loop_device_name((*argv)[0], dev_dir))) {
+	if (!(device_name = parse_loop_device_name((*argvp)[0], dev_dir))) {
 		fprintf(stderr, "%s: Could not parse loop_device %s\n",
-			base, (*argv)[0]);
+			base, (*argvp)[0]);
 		_losetup_usage(stderr);
 		return 0;
 	}
 
 	if (delete) {
-		*argc = 2;
+		*argcp = 2;
 
-		(*argv)[1] = device_name;
-		(*argv)[0] = (char *) "remove";
+		(*argvp)[1] = device_name;
+		(*argvp)[0] = (char *) "remove";
 
 		return 1;
 	}
 
-	if (*argc != 2) {
+	if (*argcp != 2) {
 		fprintf(stderr, "%s: Too few arguments\n", base);
 		_losetup_usage(stderr);
 		dm_free(device_name);
@@ -3458,9 +3458,9 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 	}
 
 	/* FIXME move these to make them available to native dmsetup */
-	if (!(loop_file = _get_abspath((*argv)[(find) ? 0 : 1]))) {
+	if (!(loop_file = _get_abspath((*argvp)[(find) ? 0 : 1]))) {
 		fprintf(stderr, "%s: Could not parse loop file name %s\n",
-			base, (*argv)[1]);
+			base, (*argvp)[1]);
 		_losetup_usage(stderr);
 		dm_free(device_name);
 		return 0;
@@ -3469,14 +3469,14 @@ static int _process_losetup_switches(const char *base, int *argc, char ***argv,
 	_table = dm_malloc(LOOP_TABLE_SIZE);
 	if (!_table ||
 	    !_loop_table(_table, (size_t) LOOP_TABLE_SIZE, loop_file, device_name, offset)) {
-		fprintf(stderr, "Could not build device-mapper table for %s\n", (*argv)[0]);
+		fprintf(stderr, "Could not build device-mapper table for %s\n", (*argvp)[0]);
 		dm_free(device_name);
 		return 0;
 	}
 	_switches[TABLE_ARG]++;
 
-	(*argv)[0] = (char *) "create";
-	(*argv)[1] = device_name ;
+	(*argvp)[0] = (char *) "create";
+	(*argvp)[1] = device_name ;
 
 	return 1;
 }
@@ -3525,7 +3525,7 @@ static int _process_options(const char *options)
 	return 1;
 }
 
-static int _process_switches(int *argc, char ***argv, const char *dev_dir)
+static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 {
 	const char *base;
 	char *namebase, *s;
@@ -3593,7 +3593,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 	memset(&_int_args, 0, sizeof(_int_args));
 	_read_ahead_flags = 0;
 
-	if (!(namebase = strdup((*argv)[0]))) {
+	if (!(namebase = strdup((*argvp)[0]))) {
 		fprintf(stderr, "Failed to duplicate name.\n");
 		return 0;
 	}
@@ -3608,28 +3608,28 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		_switches[MINOR_ARG]++;
 		_string_args[OPTIONS_ARG] = (char *) "name";
 
-		if (*argc == 3) {
-			_int_args[MAJOR_ARG] = atoi((*argv)[1]);
-			_int_args[MINOR_ARG] = atoi((*argv)[2]);
-			*argc -= 2;
-			*argv += 2;
-		} else if ((*argc == 2) &&
-			   (2 == sscanf((*argv)[1], "%i:%i",
+		if (*argcp == 3) {
+			_int_args[MAJOR_ARG] = atoi((*argvp)[1]);
+			_int_args[MINOR_ARG] = atoi((*argvp)[2]);
+			*argcp -= 2;
+			*argvp += 2;
+		} else if ((*argcp == 2) &&
+			   (2 == sscanf((*argvp)[1], "%i:%i",
 					&_int_args[MAJOR_ARG],
 					&_int_args[MINOR_ARG]))) {
-			*argc -= 1;
-			*argv += 1;
+			*argcp -= 1;
+			*argvp += 1;
 		} else {
 			fprintf(stderr, "Usage: devmap_name <major> <minor>\n");
 			return 0;
 		}
 
-		(*argv)[0] = (char *) "info";
+		(*argvp)[0] = (char *) "info";
 		return 1;
 	}
 
 	if (!strcmp(base, "losetup") || !strcmp(base, "dmlosetup")){
-		r = _process_losetup_switches(base, argc, argv, dev_dir);
+		r = _process_losetup_switches(base, argcp, argvp, dev_dir);
 		free(namebase);
 		return r;
 	}
@@ -3638,7 +3638,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:hj:m:M:no:O:rS:u:U:vy",
+	while ((ind = -1, c = GETOPTLONG_FN(*argcp, *argvp, "cCfG:hj:m:M:no:O:rS:u:U:vy",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;
@@ -3828,8 +3828,8 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		return 0;
 	}
 
-	*argv += optind;
-	*argc -= optind;
+	*argvp += optind;
+	*argcp -= optind;
 	return 1;
 }
 


