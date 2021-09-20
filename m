From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:30:17 +0000 (GMT)
Subject: main - cov: hide reports from optarg being NULL
Message-ID: <20210920133017.BEDD13858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=548c69f58174b3cb3997c0fcff09276bd7502796
Commit:        548c69f58174b3cb3997c0fcff09276bd7502796
Parent:        efaab93491751ccf39108d076745c6774b263232
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 19 20:19:52 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:26:09 2021 +0200

cov: hide reports from optarg being NULL

It's basically irrelavant which value we assing to optarg,
since it's set by getopt() function, but Coverity tool
is incorrectly reporting possibly dereference of NULL.
---
 libdm/dm-tools/dmsetup.c | 4 ++--
 tools/lvmcmdline.c       | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index f6d1ecf90..0f260b3f4 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -6680,7 +6680,7 @@ static int _process_losetup_switches(const char *base, int *argcp, char ***argvp
 	};
 #endif
 
-	optarg = 0;
+	optarg = (char*) "";
 	optind = OPTIND_INIT;
 	while ((c = GETOPTLONG_FN(*argcp, *argvp, "ade:fo:v",
 				  long_options, NULL)) != -1 ) {
@@ -6976,7 +6976,7 @@ static int _process_switches(int *argcp, char ***argvp, const char *dev_dir)
 		return r;
 	}
 
-	optarg = 0;
+	optarg = (char*) "";
 	optind = OPTIND_INIT;
 	while ((ind = -1, c = GETOPTLONG_FN(*argcp, *argvp, "cCfG:hj:m:M:no:O:rS:u:U:vy",
 					    long_options, NULL)) != -1) {
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index de70e63c9..7c5930006 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2236,7 +2236,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc, char ***arg
 	*ptr = '\0';
 	memset(o, 0, sizeof(*o));
 
-	optarg = 0;
+	optarg = (char*) "";
 	optind = OPTIND_INIT;
 	while ((goval = GETOPTLONG_FN(*argc, *argv, str, opts, NULL)) >= 0) {
 


