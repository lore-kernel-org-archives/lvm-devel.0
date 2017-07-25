From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 25 Jul 2017 07:24:53 -0400
Subject: master - dmsetup: Add minor number to concise table output format.
Message-ID: <201707251124.v6PBOrJ7019253@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f9f75de3da98e0f6f43d46539e4c17781d209478
Commit:        f9f75de3da98e0f6f43d46539e4c17781d209478
Parent:        a1dbefe9c8cd7f9bcbf19d0516082a3f354703b4
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jul 25 12:22:46 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jul 25 12:22:46 2017 +0100

dmsetup: Add minor number to concise table output format.

When using this new format for input, it'll sometimes help to
be able to specify the minor number.
---
 man/dmsetup.8_main |    6 +++---
 tools/dmsetup.c    |    3 +--
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 1d0219f..c218f6c 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -826,9 +826,9 @@ target unless the \fB--showkeys\fP parameter is supplied. Kernel key
 references prefixed with \fB:\fP are not affected by the parameter and get
 displayed always.
 With \fB--concise\fP, the output is presented concisely on a single line.
-Commas then separate the name, uuid, flags ('ro' or 'rw') and the table
-(if present). Semi-colons separate devices. Backslashes escape any commas,
-semi-colons or backslashes.
+Commas then separate the name, uuid, minor device number, flags ('ro' or 'rw')
+and the table (if present). Semi-colons separate devices. Backslashes escape
+any commas, semi-colons or backslashes.
 .
 .HP
 .CMD_TARGETS
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 3514fc5..e92ba17 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2224,8 +2224,7 @@ static int _status(CMD_ARGS)
 				_print_string_quoted(name);
 				putchar(',');
 				_print_string_quoted(dm_task_get_uuid(dmt));
-				putchar(',');
-				printf("%s", info.read_only ? "ro" : "rw");
+				printf(",%u,%s", info.minor, info.read_only ? "ro" : "rw");
 			}
 			/* Next print any target-specific information */
 			if (target_type) {


