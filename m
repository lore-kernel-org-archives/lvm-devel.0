From: thornber@sourceware.org <thornber@sourceware.org>
Date: 9 Aug 2010 10:23:56 -0000
Subject: LVM2/unit-tests/regex matcher_t.c
Message-ID: <20100809102356.16047.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-08-09 10:23:55

Modified files:
	unit-tests/regex: matcher_t.c 

Log message:
	[REGEX] matcher_t unit test now takes a flag to turn on fingerprinting

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/unit-tests/regex/matcher_t.c	2010/07/20 15:32:07	1.2
+++ LVM2/unit-tests/regex/matcher_t.c	2010/08/09 10:23:54	1.3
@@ -109,9 +109,18 @@
 	char **regex;
 	int nregex;
 	int ret = 0;
+	int want_finger_print = 0, i;
+	const char *pattern_file = NULL;
 
-	if (argc < 2) {
-		fprintf(stderr, "Usage : %s <pattern_file>\n", argv[0]);
+	for (i = 1; i < argc; i++)
+		if (!strcmp(argv[i], "--fingerprint"))
+			want_finger_print = 1;
+
+		else
+			pattern_file = argv[i];
+
+	if (!pattern_file) {
+		fprintf(stderr, "Usage : %s [--fingerprint] <pattern_file>\n", argv[0]);
 		exit(1);
 	}
 
@@ -123,7 +132,7 @@
 		goto err;
 	}
 
-	if (!_read_spec(argv[1], &regex, &nregex)) {
+	if (!_read_spec(pattern_file, &regex, &nregex)) {
 		fprintf(stderr, "Couldn't read the lex specification\n");
 		ret = 3;
 		goto err;
@@ -135,7 +144,8 @@
 		goto err;
 	}
 
-        printf("fingerprint: %x\n", dm_regex_fingerprint(scanner));
+	if (want_finger_print)
+		printf("fingerprint: %x\n", dm_regex_fingerprint(scanner));
 	_scan_input(scanner, regex);
 	_free_regex(regex, nregex);
 


