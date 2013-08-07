From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  7 Aug 2013 21:01:57 +0000 (UTC)
Subject: master - Mirror/RAID1: When up|down-converting default to segtype of current LV
Message-ID: <20130807210157.95E9960FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b15278c3dca14d7ee09a2ebcca4b91cbdf8428af
Commit:        b15278c3dca14d7ee09a2ebcca4b91cbdf8428af
Parent:        ea4c0ea34f4c4cba53f4426dbbff39bee475a2f5
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Aug 7 16:01:45 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Aug 7 16:01:45 2013 -0500

Mirror/RAID1: When up|down-converting default to segtype of current LV

If there is no RAID support in the kernel but the default mirror
segtype is "raid1", converting legacy mirrors can be problematic.
For example, changing the log type or converting a mirror to a linear
LV does not require the RAID modules to be present.  However, because
lp->segtype is set to be RAID1 by the configuration file, the command
fails.

We should only be setting lp->segtype when converting mirrors if it is
going to change (e.g. to linear or between mirror types).
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   14 ++++++++++----
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3590e64..4515be7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.100 -
 ================================
+  When converting mirrors, default segtype should be the same unless specified.
   Make "raid1" the default mirror segment type.
   Fix clogd descriptor leak when daemonizing.
   Fix clvmd descriptor leak on restart.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5d796e7..6a243c3 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -518,10 +518,16 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
 			return_0;
 
-		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG,
-			find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)));
-		if (!lp->segtype)
-			return_0;
+		if (arg_count(cmd, mirrors_ARG) && !lp->mirrors) {
+			/* down-converting to linear/stripe? */
+			if (!(lp->segtype =
+			      get_segtype_from_string(cmd, "striped")))
+				return_0;
+		} else if (arg_count(cmd, type_ARG)) {
+			/* changing mirror type? */
+			if (!(lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG, NULL)))))
+				return_0;
+		} /* else segtype will default to current type */
 	}
 
 	/* TODO: default in lvm.conf ? */


