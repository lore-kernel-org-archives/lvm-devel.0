From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Nov 2015 20:53:15 +0000 (UTC)
Subject: master - cleanup: clean gcc shadow declaration of version warning
Message-ID: <20151126205315.D2AB5611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec647f1d431214264aaa396b6d0ba8e97738f00b
Commit:        ec647f1d431214264aaa396b6d0ba8e97738f00b
Parent:        4afe43e1a326d50296b6ad4a7ed836d4b0ae6b26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 26 21:52:22 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 26 21:52:22 2015 +0100

cleanup: clean gcc shadow declaration of version warning

---
 tools/dumpconfig.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 72129c2..85cd619 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -17,17 +17,17 @@
 
 static int _get_vsn(struct cmd_context *cmd, uint16_t *version_int)
 {
-	const char *version;
+	const char *vsn;
 	unsigned int major, minor, patchlevel;
 
 	if (arg_count(cmd, atversion_ARG))
-		version = arg_str_value(cmd, atversion_ARG, NULL);
+		vsn = arg_str_value(cmd, atversion_ARG, NULL);
 	else if (arg_count(cmd, sinceversion_ARG))
-		version = arg_str_value(cmd, sinceversion_ARG, NULL);
+		vsn = arg_str_value(cmd, sinceversion_ARG, NULL);
 	else
-		version = LVM_VERSION;
+		vsn = LVM_VERSION;
 
-	if (sscanf(version, "%u.%u.%u", &major, &minor, &patchlevel) != 3) {
+	if (sscanf(vsn, "%u.%u.%u", &major, &minor, &patchlevel) != 3) {
 		log_error("Incorrect version format.");
 		return 0;
 	}


