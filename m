From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:40:01 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: add ENABLE_ALL_DEVS flag
Message-ID: <20140922154001.456DC60D27@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=84b51035909394ad52010a4f7aaa5f9da22b0faa
Commit:        84b51035909394ad52010a4f7aaa5f9da22b0faa
Parent:        ced473a352ceca9ef9759c98eaaca8f9a9a7fe7c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 29 16:53:32 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

toollib: add ENABLE_ALL_DEVS flag

The ENABLE_ALL_DEVS flag is added to the command structure
for commands that should process all devs (pvs and non-pvs)
when they call process_each_pv and the command includes the
--all arg.  This will be used in a later process_each_pv patch.
---
 tools/commands.h |    6 +++---
 tools/tools.h    |    1 +
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index f723246..e456139 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -416,7 +416,7 @@ xx(lvmchange,
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
-   PERMITTED_READ_ONLY,
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS,
    "lvmdiskscan\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
@@ -700,7 +700,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[--commandprofile ProfileName]\n"
@@ -792,7 +792,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS,
    "pvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
diff --git a/tools/tools.h b/tools/tools.h
index 7b12797..2329d97 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -103,6 +103,7 @@ struct arg_value_group_list {
 #define CACHE_VGMETADATA	0x00000001
 #define PERMITTED_READ_ONLY 	0x00000002
 #define ALL_VGS_IS_DEFAULT	0x00000004 /* run cmd on all vgs if none are named */
+#define ENABLE_ALL_DEVS		0x00000008
 
 /* a register of the lvm commands */
 struct command {


