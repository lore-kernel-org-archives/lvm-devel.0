From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 14:08:31 -0400
Subject: master - cmdline: fix missing NULL at end of array of args
Message-ID: <201706261808.v5QI8VpX008712@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52f4042f1a3b21054041298d7e50ded7ae366f44
Commit:        52f4042f1a3b21054041298d7e50ded7ae366f44
Parent:        4e4067dd94f52f90f0aaae30c522102ccbaa2826
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 20:03:05 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 26 20:07:21 2017 +0200

cmdline: fix missing NULL at end of array of args

lvm_run needs to place NULL as the last element into argv[].
Otherwise we get:

Conditional jump or move depends on uninitialised value(s)
 _command_required_pos_matches (lvmcmdline.c:1443)
 _find_command (lvmcmdline.c:1610)
 lvm_run_command (lvmcmdline.c:2770)
 lvm2_run (lvmcmdlib.c:91)
---
 WHATS_NEW          |    1 +
 test/api/test.c    |    3 +++
 tools/lvmcmdline.c |    3 +++
 3 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6a60f0b..2872dbb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Add missing NULL to argv array when spliting cmdline arguments.
   Add display_percent helper function for printing percent values.
   Lvconvert --repair handles failing raid legs (present but marked 'D'ead).
   Do not lvdisplay --maps unset settings of cache pool.
diff --git a/test/api/test.c b/test/api/test.c
index 1413030..a79afc1 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -51,6 +51,9 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 			break;
 	}
 
+	if (*argc < max)
+		argv[*argc] = NULL;
+
 	return *argc;
 }
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9e77d48..0aca37a 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3045,6 +3045,9 @@ int lvm_split(char *str, int *argc, char **argv, int max)
 			break;
 	}
 
+	if (*argc < max)
+		argv[*argc] = NULL;
+
 	return *argc;
 }
 


