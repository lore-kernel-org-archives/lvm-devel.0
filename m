From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Sep 2013 00:26:32 +0000 (UTC)
Subject: master - tools: Avoid overflow in _get_int_arg.
Message-ID: <20130918002632.1184F6119B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e912d949b5f68dbf522c4ddb48b93461bdacfdd
Commit:        6e912d949b5f68dbf522c4ddb48b93461bdacfdd
Parent:        a0ca2c11ee69b51a99644955cb4daa8ca50c8034
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 18 01:16:48 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 18 01:16:48 2013 +0100

tools: Avoid overflow in _get_int_arg.

Use strtoull instead of strtol so that argument size is not cut
to 31 bytes on machines with 32-bit long.

(Mikulas)
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index df893ae..0b53a9e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Use strtoull instead of strtol in _get_int_arg.
   Add devtypes report command to display built-in recognised block device types.
   Fix CC Makefile override which had reverted to using built-in value. (2.02.75)
   Recognise bcache block devices in filter (experimental).
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 116e963..e004f61 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -241,7 +241,7 @@ int metadatatype_arg(struct cmd_context *cmd, struct arg_values *av)
 static int _get_int_arg(struct arg_values *av, char **ptr)
 {
 	char *val;
-	long v;
+	unsigned long long v;
 
 	av->percent = PERCENT_NONE;
 
@@ -262,9 +262,10 @@ static int _get_int_arg(struct arg_values *av, char **ptr)
 	if (!isdigit(*val))
 		return 0;
 
-	v = strtol(val, ptr, 10);
+	errno = 0;
+	v = strtoull(val, ptr, 10);
 
-	if (*ptr == val)
+	if (*ptr == val || errno)
 		return 0;
 
 	av->i_value = (int32_t) v;


