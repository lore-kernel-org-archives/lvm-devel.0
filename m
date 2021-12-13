From: David Teigland <teigland@sourceware.org>
Date: Mon, 13 Dec 2021 15:31:23 +0000 (GMT)
Subject: main - lvcreate: include recent options
Message-ID: <20211213153123.EF3833858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c28541eccdbf76191f7728035cd2a48d26d06922
Commit:        c28541eccdbf76191f7728035cd2a48d26d06922
Parent:        d803d9202c7c11548c7ab81afb61ad738802b8f8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Dec 13 08:59:31 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 13 08:59:31 2021 -0600

lvcreate: include recent options

The permitted option list in lvcreate has not kept
up with command-lines.in.
---
 tools/lvcreate.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0121c09a8..79af42685 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -824,12 +824,16 @@ static int _lvcreate_params(struct cmd_context *cmd,
 	autobackup_ARG,\
 	available_ARG,\
 	contiguous_ARG,\
+	devices_ARG,\
+	devicesfile_ARG,\
 	ignoreactivationskip_ARG,\
 	ignoremonitoring_ARG,\
+	journal_ARG,\
 	metadataprofile_ARG,\
 	monitor_ARG,\
 	mirrors_ARG,\
 	name_ARG,\
+	nohints_ARG,\
 	noudevsync_ARG,\
 	permission_ARG,\
 	persistent_ARG,\


