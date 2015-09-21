From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 21 Sep 2015 22:11:54 +0000 (UTC)
Subject: master - lvchange: update help text
Message-ID: <20150921221154.D1A5860703@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e5bde4a77d672ff763b5134055d4d35a753de6d
Commit:        2e5bde4a77d672ff763b5134055d4d35a753de6d
Parent:        cfe869692f42ee2f4ac0f36c5337e7638ff01c29
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 00:06:40 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 00:08:44 2015 +0200

lvchange: update help text

Use <> for user specified options.
(meant to match 'Italic' style in man page).
---
 tools/commands.h |   34 +++++++++++++++++-----------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 4505d18..92d13fd 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -138,16 +138,16 @@ xx(lvchange,
    "Change the attributes of logical volume(s)",
    CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "lvchange\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[-a|--activate [a|e|l]{y|n}]\n"
+   "\t[-A|--autobackup {y|n}]\n"
+   "\t[-a|--activate [a][e|s|l]{y|n}]\n"
    "\t[--activationmode {complete|degraded|partial}"
-   "\t[--addtag Tag]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[-C|--contiguous y|n]\n"
-   "\t[--cachepolicy policyname] [--cachesettings parameter=value]\n"
-   "\t[--commandprofile ProfileName]\n"
+   "\t[--addtag <Tag>]\n"
+   "\t[--alloc <AllocationPolicy>]\n"
+   "\t[-C|--contiguous {y|n}]\n"
+   "\t[--cachepolicy <policyname>] [--cachesettings <parameter=value>]\n"
+   "\t[--commandprofile <ProfileName>]\n"
    "\t[-d|--debug]\n"
-   "\t[--deltag Tag]\n"
+   "\t[--deltag <Tag>]\n"
    "\t[--detachprofile]\n"
    "\t[--errorwhenfull {y|n}]\n"
    "\t[-f|--force]\n"
@@ -161,16 +161,16 @@ xx(lvchange,
    "\t[--monitor {y|n}]\n"
    "\t[--poll {y|n}]\n"
    "\t[--noudevsync]\n"
-   "\t[-M|--persistent y|n] [-j|--major major] [--minor minor]\n"
-   "\t[--metadataprofile ProfileName]\n"
+   "\t[-M|--persistent {y|n}] [-j|--major <major>] [--minor <minor>]\n"
+   "\t[--metadataprofile <ProfileName>]\n"
    "\t[-P|--partial]\n"
-   "\t[-p|--permission r|rw]\n"
-   "\t[--[raid]minrecoveryrate Rate]\n"
-   "\t[--[raid]maxrecoveryrate Rate]\n"
+   "\t[-p|--permission {r|rw}]\n"
+   "\t[--[raid]minrecoveryrate <Rate>]\n"
+   "\t[--[raid]maxrecoveryrate <Rate>]\n"
    "\t[--[raid]syncaction {check|repair}\n"
-   "\t[--[raid]writebehind IOCount]\n"
-   "\t[--[raid]writemostly PhysicalVolume[:{t|n|y}]]\n"
-   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
+   "\t[--[raid]writebehind <IOCount>]\n"
+   "\t[--[raid]writemostly <PhysicalVolume>[:{t|n|y}]]\n"
+   "\t[-r|--readahead <ReadAheadSectors>|auto|none]\n"
    "\t[--refresh]\n"
    "\t[--resync]\n"
    "\t[-S|--select Selection]\n"
@@ -180,7 +180,7 @@ xx(lvchange,
    "\t[--version]\n"
    "\t[-y|--yes]\n"
    "\t[-Z|--zero {y|n}]\n"
-   "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
+   "\t<LogicalVolume[Path]> [<LogicalVolume[Path]>...]\n",
 
    activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
    available_ARG, cachepolicy_ARG, cachesettings_ARG, contiguous_ARG, deltag_ARG,


