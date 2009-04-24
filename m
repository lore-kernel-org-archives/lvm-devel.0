From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 24 Apr 2009 12:42:38 +0200
Subject: [PATCH] Fix segfault when using -U, -G and -M options in dmsetup
Message-ID: <49F1979E.7030108@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It seems nobody uses these options :) Permissions will be covered
by udev anyway...

We have to define ":" in getopt for options that require parameters.

Peter


diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0d6a371..1194c5f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2565,7 +2565,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfGj:m:Mno:O:ru:Uv",
+	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:j:m:M:no:O:ru:U:v",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;


