From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Nov 2016 15:59:58 +0000 (UTC)
Subject: master - lvconvert: repair accepts interval and background
Message-ID: <20161111155958.2433060E40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=59b29716e5fd0f490d28d2457cdebfc68eb9940e
Commit:        59b29716e5fd0f490d28d2457cdebfc68eb9940e
Parent:        f8b3b0bc9a5758ab3cacf0de79ee48bb851b07a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 17 11:16:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 11 16:51:33 2016 +0100

lvconvert: repair accepts interval and background

For mirror and raid we expose --interval and --background on
command line (instead of using just always using compiled-in defaults).
---
 WHATS_NEW          |    1 +
 man/lvconvert.8.in |    6 ++++++
 tools/lvconvert.c  |    1 +
 3 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 17fbdc0..2af2992 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.168 - 
 ====================================
+  lvconvert --repair accepts --interval and --background option.
   More efficiently prepare _rmeta devices when creating a new raid LV.
 
 Version 2.02.167 - 5th November 2016
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index bc4af80..0becc8a 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -365,6 +365,9 @@ See corresponding operation --splitmirrors.
 VG/RaidLV
 .br
 \[bu]
+Options \-\-background, \-\-interval.
+.br
+\[bu]
 Replace failed PVs in RaidLV.
 
 .B lvconvert \-\-replace
@@ -502,6 +505,9 @@ Change the type of log used by MirrorLV.
 VG/MirrorLV
 .br
 \[bu]
+Options \-\-background, \-\-interval.
+.br
+\[bu]
 Replace failed PVs in MirrorLV.
 
 .B lvconvert \-\-type linear
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4563ade..d6824d8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -534,6 +534,7 @@ static int _read_params(struct cmd_context *cmd, int argc, char **argv,
 		if (arg_outside_list_is_set(cmd, "cannot be used with --repair",
 					    repair_ARG,
 					    alloc_ARG, usepolicies_ARG,
+					    background_ARG, interval_ARG,
 					    force_ARG, noudevsync_ARG, test_ARG,
 					    -1))
 			return_0;


