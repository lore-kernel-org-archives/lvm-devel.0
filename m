From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:25 +0000 (GMT)
Subject: main - commands.h: keep entries alphabetically sorted
Message-ID: <20210302215825.A6EC33834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f87d1a2abb9102f47d240bd0e6f2c343ddb47310
Commit:        f87d1a2abb9102f47d240bd0e6f2c343ddb47310
Parent:        6846af6612674d854613e9936deb358f6c1b3cfe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 25 22:24:32 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

commands.h: keep entries alphabetically sorted

For binary search usage commands need to be sorted.
Later patch also adds check if the order would be broken.
---
 tools/commands.h | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index b12e451f2..fa5359afe 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -29,14 +29,14 @@ xx(formats,
    "List available metadata formats",
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
-xx(help,
-   "Display help for commands",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
-
 xx(fullreport,
    "Display full report",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS | ALLOW_EXPORTED)
 
+xx(help,
+   "Display help for commands",
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
+
 xx(lastlog,
    "Display last command's log report",
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
@@ -85,6 +85,10 @@ xx(lvmsar,
    "Create activity report",
    0)
 
+xx(lvpoll,
+   "Continue already initiated poll operation on a logical volume",
+   0)
+
 xx(lvreduce,
    "Reduce the size of a logical volume",
    ALLOW_HINTS)
@@ -113,10 +117,6 @@ xx(pvchange,
    "Change attributes of physical volume(s)",
    0)
 
-xx(pvresize,
-   "Resize physical volume(s)",
-   0)
-
 xx(pvck,
    "Check metadata on physical volumes",
    LOCKD_VG_SH | ALLOW_EXPORTED)
@@ -139,14 +139,14 @@ xx(pvmove,
    "Move extents from one physical volume to another",
    ALL_VGS_IS_DEFAULT | DISALLOW_TAG_ARGS)
 
-xx(lvpoll,
-   "Continue already initiated poll operation on a logical volume",
-   0)
-
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
    ENABLE_ALL_DEVS)
 
+xx(pvresize,
+   "Resize physical volume(s)",
+   0)
+
 xx(pvs,
    "Display information about physical volumes",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED)
@@ -167,6 +167,10 @@ xx(tags,
    "List tags defined on this host",
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
+xx(version,
+   "Display software and driver version information",
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
+
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
    PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_EXPORTED)
@@ -246,7 +250,3 @@ xx(vgscan,
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
    0)
-
-xx(version,
-   "Display software and driver version information",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)


