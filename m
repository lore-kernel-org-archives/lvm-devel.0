From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 18 Mar 2014 10:11:41 +0000 (UTC)
Subject: master - dumpconfig: fix memleak when using --mergedconfig
Message-ID: <20140318101141.D19B960C21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25f5e2da8d6b447d26395e610e55192d2d8a16b4
Commit:        25f5e2da8d6b447d26395e610e55192d2d8a16b4
Parent:        aed36c12f8ceb55d3290519215adecc03d54978e
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 18 11:04:21 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 18 11:11:31 2014 +0100

dumpconfig: fix memleak when using --mergedconfig

Check whether lvm dumpconfig --mergedconfig is used only
with --type current (where we're merging current config and
the config supplied on command line). With other types
the config was merged, but it was thrown away since we're
generating other type of config anyway. This lead to a memleak.

Error out if --mergedconfig is used with anything else than
--type current (or without specifying --type in which case
the --type current is used by default).
---
 WHATS_NEW          |    1 +
 tools/dumpconfig.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a20331b..de96f8a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Don't allow --mergedconfig without --type current in dumpconfig. Fix memleak.
   Make global/lvdisplay_shows_full_device_path lvm.conf setting profilable.
   Make global/{units|si_unit_consistency|suffix} lvm.conf setting profilable.
   Validate minimal chunk size for snapshot COW volume in lvconvert.
diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index dd86733..d9aebd9 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -126,6 +126,9 @@ int dumpconfig(struct cmd_context *cmd, int argc, char **argv)
 				  "no effect with --type current");
 			return EINVALID_CMD_LINE;
 		}
+	} else if (arg_count(cmd, mergedconfig_ARG)) {
+		log_error("--mergedconfig has no effect without --type current");
+		return EINVALID_CMD_LINE;
 	}
 
 	if (!_get_vsn(cmd, &tree_spec.version))


