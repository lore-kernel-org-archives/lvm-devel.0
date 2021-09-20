From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 13:29:56 +0000 (GMT)
Subject: main - gcc-fanalyzer: drop zeroing of pointers
Message-ID: <20210920132956.51DE83858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=becffe4567543e3e0c51c728a4b266cf94fd2cdf
Commit:        becffe4567543e3e0c51c728a4b266cf94fd2cdf
Parent:        909401226cd7219fa07389bc396723b0c01cd9dd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 13:53:20 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 14:18:13 2021 +0200

gcc-fanalyzer: drop zeroing of pointers

This explicit pointer zeroing is not needed since
we use 'zalloced' buffers.
---
 lib/format_text/archiver.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index fae368784..87e4edc40 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -50,8 +50,6 @@ int archive_init(struct cmd_context *cmd, const char *dir,
 		return 0;
 	}
 
-	cmd->archive_params->dir = NULL;
-
 	if (!*dir)
 		return 1;
 
@@ -195,7 +193,6 @@ int backup_init(struct cmd_context *cmd, const char *dir,
 		return 0;
 	}
 
-	cmd->backup_params->dir = NULL;
 	if (!*dir)
 		return 1;
 


