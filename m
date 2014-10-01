From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  1 Oct 2014 22:18:17 +0000 (UTC)
Subject: master - tools: Add ENABLE_ALL_DEVS flag.
Message-ID: <20141001221817.A38FA60FE8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1cdb8766a7cf500b6657cf6f6baf2d785a3708f5
Commit:        1cdb8766a7cf500b6657cf6f6baf2d785a3708f5
Parent:        e6ab275aa00beb9192684f580fcbc52757f63856
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 1 22:58:23 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Oct 1 22:58:23 2014 +0100

tools: Add ENABLE_ALL_DEVS flag.

The ENABLE_ALL_DEVS flag is added to the command structure
for commands that should process all devs (pvs and non-pvs)
when they call process_each_pv and the command includes the
--all arg.  This will be used in a later process_each_pv patch.
---
 tools/commands.h |    6 +++---
 tools/tools.h    |    4 +++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index a3c05b8..afdf4c3 100644
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
@@ -786,7 +786,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS,
    "pvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
diff --git a/tools/tools.h b/tools/tools.h
index b3dd799..134e584 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -104,7 +104,9 @@ struct arg_value_group_list {
 #define PERMITTED_READ_ONLY 	0x00000002
 /* Process all vgs if none specified on the command line. */
 #define ALL_VGS_IS_DEFAULT	0x00000004
-
+/* Process all devices with --all if none are specified on the command line. */
+#define ENABLE_ALL_DEVS		0x00000008	
+ 
 /* a register of the lvm commands */
 struct command {
 	const char *name;


