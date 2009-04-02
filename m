From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:31 -0400
Subject: [RFC PATCH 6/7] individual lvm command settings
In-Reply-To: <49D3D9F5.902@redhat.com>
References: <49D3D9F5.902@redhat.com>
Message-ID: <49D4F3A3.1090605@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Several lvm commands should not work based on metadata cache data. They
need to scan real metadata on devices. lvm commands with MCACHE_DISABLE
flag do not use metadata cache.

Currently the metadata cache feature is disabled in the following commands.

  * scan commands: vgscan and lvscan
      pvscan destroys lvmcache before its procedure, and MCACHE_DISABLE
      flag is not needed.

  * physical volume commands: pvdisplay, pvs
      Metadata cache files contain physical volume data which belong to
      a volume group, and orphan physical volumes can not be handled.
      To support these volumes, a kind of orphan physical volume cache
      need to be introduced.

As a next step, I'm planning to set MCACHE_CLEANUP flag to vgscan command
to refresh all metadata cache files in the cache directory.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 tools/commands.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: LVM2.02.46-cvs-20090324/tools/commands.h
===================================================================
--- LVM2.02.46-cvs-20090324.orig/tools/commands.h
+++ LVM2.02.46-cvs-20090324/tools/commands.h
@@ -390,7 +390,7 @@ xx(lvs,
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   0,
+   MCACHE_DISABLE,
    "lvscan " "\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice] " "\n"
@@ -497,7 +497,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   0,
+   MCACHE_DISABLE,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[-d|--debug]\n"
@@ -571,7 +571,7 @@ xx(pvremove,
 
 xx(pvs,
    "Display information about physical volumes",
-   0,
+   MCACHE_DISABLE,
    "pvs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
@@ -925,7 +925,7 @@ xx(vgs,
 
 xx(vgscan,
    "Search for all volume groups",
-   0,
+   MCACHE_DISABLE,
    "vgscan "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"





