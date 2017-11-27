From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Nov 2017 04:49:53 -0500
Subject: master - cmdline: avoid overrun on very large numbers.
Message-ID: <201711270949.vAR9nrbP022976@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=efa17cae24190d1178a9dac1473b8757c412292c
Commit:        efa17cae24190d1178a9dac1473b8757c412292c
Parent:        34eb082bbcd57deb954ff4221c9320126c2096f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 27 10:21:21 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 27 10:34:30 2017 +0100

cmdline: avoid overrun on very large numbers.

When large size number (>2^31) is given on command line it could be
misdetected and in certain cases lead to wrongly casted number.

So make sure all cases always do set _MAX number in case the value would
not fit within the supported range instead of getting some random value
within the range.

In most cases this was not a problem to detect, but i.e. stripesize
parameter might have been fooled by certain large numbers.
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |   17 +++++++++--------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9b9e7a8..5937bad 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Ensure very large numbers used as arguments are not casted to lower values. 
   Enhance reading and validation of options stripes and stripes_size.
   Fix printing of default stripe size when user is not using stripes.
   Activation code for pvmove automatically discovers holding LVs for resume.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 22f1c60..b693722 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -508,10 +508,10 @@ static int _get_int_arg(struct arg_values *av, char **ptr)
 	if (*ptr == val || errno)
 		return 0;
 
-	av->i_value = (int32_t) v;
-	av->ui_value = (uint32_t) v;
-	av->i64_value = (int64_t) v;
-	av->ui64_value = (uint64_t) v;
+	av->i_value = (v < INT32_MAX) ? (int32_t) v : INT32_MAX;
+	av->ui_value = (v < UINT32_MAX) ? (uint32_t) v : UINT32_MAX;
+	av->i64_value = (v < INT64_MAX) ? (int64_t) v : INT64_MAX;
+	av->ui64_value = (v < UINT64_MAX) ? (uint64_t) v : UINT64_MAX;
 
 	return 1;
 }
@@ -641,10 +641,11 @@ static int _size_arg(struct cmd_context *cmd __attribute__((unused)),
 		log_error("Size is too big (>=16EiB).");
 		return 0;
 	}
-	av->i_value = (int32_t) v;
-	av->ui_value = (uint32_t) v;
-	av->i64_value = (int64_t) v;
-	av->ui64_value = (uint64_t) v;
+
+	av->i_value = (v < INT32_MAX) ? (int32_t) v : INT32_MAX;
+	av->ui_value = (v < UINT32_MAX) ? (uint32_t) v : UINT32_MAX;
+	av->i64_value = (v < INT64_MAX) ? (int64_t) v : INT64_MAX;
+	av->ui64_value = (v < UINT64_MAX) ? (uint64_t) v : UINT64_MAX;
 
 	return 1;
 }


