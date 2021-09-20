From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:50 +0000 (GMT)
Subject: main - gcc-fanalyzer: use zeroed memory
Message-ID: <20210920132950.ABE703858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93d565eda992abc0460cc8fc7b9998bd1996a447
Commit:        93d565eda992abc0460cc8fc7b9998bd1996a447
Parent:        5126ac7c3aa4f9f47a36c66095246d5b13871e61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 18 21:01:48 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 13:58:57 2021 +0200

gcc-fanalyzer: use zeroed memory

Analyzer here was rather confused about possiblity of loosing previously
assigned device pointers - fixed by passing zero initialize memory
before first assign.
---
 daemons/dmeventd/dmeventd.c | 2 +-
 tools/vgimportclone.c       | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 041718c7a..c44fa4ed9 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -2069,7 +2069,7 @@ static void _restart_dmeventd(void)
 			++count;
 		}
 
-	if (!(_initial_registrations = malloc(sizeof(char*) * (count + 1)))) {
+	if (!(_initial_registrations = zalloc(sizeof(char*) * (count + 1)))) {
 		fprintf(stderr, "Memory allocation registration failed.\n");
 		goto bad;
 	}
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 8aa0dbba9..23bb6271f 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -194,7 +194,7 @@ static int _get_other_devs(struct cmd_context *cmd, struct dm_list *new_devs, st
 	while ((dev = dev_iter_get(cmd, iter))) {
 		if (_get_device_list(new_devs, dev))
 			continue;
-		if (!(devl = malloc(sizeof(*devl)))) {
+		if (!(devl = zalloc(sizeof(*devl)))) {
 			r = 0;
 			goto_bad;
 		}
@@ -278,7 +278,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 			goto out;
 		}
 
-		if (!(devl = malloc(sizeof(*devl))))
+		if (!(devl = zalloc(sizeof(*devl))))
 			goto_out;
 
 		devl->dev = dev;


