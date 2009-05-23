From: Petr Rockai <prockai@redhat.com>
Date: Sat, 23 May 2009 11:34:23 +0200
Subject: [PATCH] [draft] add lvconvert --repair --auto that honours lvm.conf mirror policy
In-Reply-To: <873aaybhzz.fsf@mornfall.net> (Petr Rockai's message of "Thu, 21
	May 2009 17:20:00 +0200")
References: <873aaybhzz.fsf@mornfall.net>
Message-ID: <87pre040yo.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi again,

I have now tested the patch, and following is (obviously) also needed to make
it work. Other than that, everything seems to work as expected (most
importantly, the mirror_device_fault_policy is obeyed by dmeventd).

The missing patch bit:

===================================================================
RCS file: /cvs/lvm2/LVM2/tools/commands.h,v
retrieving revision 1.125
diff -u -p -r1.125 commands.h
--- tools/commands.h	25 Apr 2009 01:18:00 -0000	1.125
+++ tools/commands.h	23 May 2009 09:31:29 -0000
@@ -94,7 +94,7 @@ xx(lvconvert,
    0,
    "lvconvert "
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
-   "\t[--repair]\n"
+   "\t[--repair [--auto]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-b|--background]\n"
@@ -116,8 +116,8 @@ xx(lvconvert,
    "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n",
 
    alloc_ARG, background_ARG, chunksize_ARG, corelog_ARG, interval_ARG,
-   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, repair_ARG, snapshot_ARG,
-   test_ARG, zero_ARG)
+   mirrorlog_ARG, mirrors_ARG, regionsize_ARG, repair_ARG, auto_ARG,
+   snapshot_ARG, test_ARG, zero_ARG)
 
 xx(lvcreate,
    "Create a logical volume",

Is this version OK to commit, then? (Better option names than --repair --auto
are still solicited, but probably not such a high priority anyway...)

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


