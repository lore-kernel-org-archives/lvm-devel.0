From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:49:11 +0000 (UTC)
Subject: master - lvcreate: add --activate ay (autoactivate)
Message-ID: <20120628134911.E9DB61687@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a2f4ccd83907590d16e6d06e1aea7e70efcf1fe5
Commit:        a2f4ccd83907590d16e6d06e1aea7e70efcf1fe5
Parent:        c9b9077b44119db0bfd926730cb79ebf0990c980
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 28 04:15:07 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:44:07 2012 -0400

lvcreate: add --activate ay (autoactivate)

One can use "lvcreate --aay" to have the newly created volume
activated or not activated based on the activation/auto_activation_volume_list
this way.

Note: -Z/--zero is not compatible with -aay, zeroing is not used in this case!
When using lvcreate -aay, a default warning message is also issued that zeroing
is not done.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    9 +++++++++
 tools/commands.h        |    2 +-
 tools/lvcreate.c        |    6 ++++++
 4 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ec554bf..152ec08 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add --activate ay to lvcreate.
   Add --activate ay to lvchange.
   Add --activate ay to pvscan.
   Add --activate ay to vgchange.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index a0be887..0666a51 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4433,6 +4433,15 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 
 	backup(vg);
 
+	/*
+	 * Check for autoactivation.
+	 * If the LV passes the auto activation filter, activate
+	 * it just as if CHANGE_AY was used, CHANGE_AN otherwise.
+	 */
+	if (lp->activate == CHANGE_AAY)
+		lp->activate = lv_passes_auto_activation_filter(cmd, lv) ?
+				CHANGE_ALY : CHANGE_ALN;
+
 	if (test_mode()) {
 		log_verbose("Test mode: Skipping activation and zeroing.");
 		goto out;
diff --git a/tools/commands.h b/tools/commands.h
index b863c66..3454951 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -159,7 +159,7 @@ xx(lvcreate,
    0,
    "lvcreate " "\n"
    "\t[-A|--autobackup {y|n}]\n"
-   "\t[-a|--activate [e|l]y|n]\n"
+   "\t[-a|--activate [a|e|l]{y|n}]\n"
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous {y|n}]\n"
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index a81e39d..ab217cf 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -567,6 +567,12 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 			log_error("--activate n requires --zero n");
 			return 0;
 		}
+	} else if (lp->activate == CHANGE_AAY) {
+		if (arg_count(cmd, zero_ARG)) {
+			log_error("-Z is incompatible with --activate a");
+			return 0;
+		}
+		lp->zero = 0;
 	}
 
 	/*


