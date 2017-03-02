From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Mar 2017 17:58:55 -0500
Subject: master - man lvcreate: remove the extents prefix
Message-ID: <201703022258.v22Mwtqw023963@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a62767f2d44c9d9a9004ffe08a6f21a153c2a8f
Commit:        9a62767f2d44c9d9a9004ffe08a6f21a153c2a8f
Parent:        5d39927f2251edbb60db5af55ddf06ef50331e49
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 2 16:42:46 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Mar 2 16:58:19 2017 -0600

man lvcreate: remove the extents prefix

This applies the same hack to --extents (dropping
the [+|-] prefix), as commit b7831fc14a did for --size.
---
 tools/command.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 2e8299b..d2d7a26 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1908,6 +1908,10 @@ static void print_val_man(struct command_name *cname, const char *str)
 		printf("\\fISize\\fP[m|UNIT]");
 		return;
 	}
+	if (!strcmp(cname->name, "lvcreate") && !strcmp(str, "[+|-]Number[%VG|%PVS|%FREE]")) {
+		printf("\\fINumber\\fP[\\fB%%VG\\fP|\\fB%%PVS\\fP|\\fB%%FREE\\fP]");
+		return;
+	}
 
 	/*
 	 * Doing bold k before UNIT creates a lot of


