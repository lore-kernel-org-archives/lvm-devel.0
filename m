From: meyering@sourceware.org <meyering@sourceware.org>
Date: Fri, 20 Jul 2007 12:13:01 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/file_locking.c
Message-ID: <20070720121253.12048.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-20 12:12:52

Modified files:
	.              : WHATS_NEW 
	lib/locking    : file_locking.c 

Log message:
	Don't leak a file descriptor in _lock_file when flock fails.
	
	* lib/locking/file_locking.c (_lock_file): Close fd upon flock failure.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.661&r2=1.662
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/file_locking.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/WHATS_NEW	2007/07/19 07:06:47	1.661
+++ LVM2/WHATS_NEW	2007/07/20 12:12:52	1.662
@@ -1,5 +1,6 @@
 Version 2.02.28 -
 ================================
+  Don't leak a file descriptor in _lock_file(), when flock fails.
   Add SUN's LDOM virtual block device to filters
   Split metadata-external.h out from metadata.h for the tools to use.
 
@@ -928,7 +929,7 @@
 
 You need to update libdevmapper before using 'vgmknodes' or 'vgscan --mknodes'.
 If your root filesystem is on an LV, you should run one of those two
-commands to fix up the special files in /dev in your real root filesystem 
+commands to fix up the special files in /dev in your real root filesystem
 after finishing with your initrd.  Also, remember you can use
 'vgchange --ignorelockingfailure' on your initrd if the tool fails because
 it can't write a lock file to a read-only filesystem.
@@ -938,7 +939,7 @@
 A pvmove implementation is now available for the new metadata format.
 
 When running a command that allocates space (e.g. lvcreate), you can now
-restrict not only which disk(s) may be used but also the Physical Extents 
+restrict not only which disk(s) may be used but also the Physical Extents
 on those disks.  e.g. lvcreate -L 10 vg1 /dev/hda6:1000-2000:3000-4000
 
 
@@ -950,12 +951,12 @@
   It's more compact and supports transactional changes and replication.
   Should things go wrong on a system, it's human-readable (and editable).
 
-Please report any problems you find to the mailing list, 
+Please report any problems you find to the mailing list,
 linux-lvm at sistina.com.  The software has NOT yet been thoroughly
 tested and so quite possibly there'll still be some bugs in it.
 Be aware of the disclaimer in the COPYING file.
 
-While testing, we recommend turning logging on in the configuration file 
+While testing, we recommend turning logging on in the configuration file
 to provide us with diagnostic information:
   log {
         file="/tmp/lvm2.log"
@@ -966,7 +967,7 @@
 You should schedule regular backups of your configuration file and
 metadata backups and archives (normally kept under /etc/lvm).
 
-Please read docs/example.conf and "man lvm.conf" to find out more about 
+Please read docs/example.conf and "man lvm.conf" to find out more about
 the configuration file.
 
 To convert an existing volume group called vg1 to the new format using
@@ -995,7 +996,7 @@
 LVM2 maintains a backup of the current metadata for each volume group
 in /etc/lvm/backup, and puts copies of previous versions in
 /etc/lvm/archive.  "vgcfgbackup" and "vgcfgrestore" can be used to
-create and restore from these files.  If you fully understand what 
+create and restore from these files.  If you fully understand what
 you're doing, metadata can be changed by editing a copy of a current
 backup file and using vgcfgrestore to reload it.
 
@@ -1012,8 +1013,8 @@
 The internal cache.  If you turn on debugging output you'll see lots of
 repeated messages, many of which will eventually get optimised out.
 
---test sometimes causes a command to fail (e.g. vgconvert --test) even 
-though the real command would work: again, fixing this is waiting for 
+--test sometimes causes a command to fail (e.g. vgconvert --test) even
+though the real command would work: again, fixing this is waiting for
 the work on the cache.
 
 Several of the tools do not yet contain the logic to handle full
@@ -1026,4 +1027,3 @@
 
 Recovery tools to salvage "lost" metadata directly from the disks:
 but we hope the new format will mean such tools are hardly ever needed!
-
--- LVM2/lib/locking/file_locking.c	2007/01/25 14:37:48	1.26
+++ LVM2/lib/locking/file_locking.c	2007/07/20 12:12:52	1.27
@@ -185,6 +185,7 @@
 		if (r) {
 			errno = old_errno;
 			log_sys_error("flock", ll->res);
+			close(ll->lf);
 			goto err;
 		}
 


