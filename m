From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 31 Mar 2010 17:20:45 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20100331172045.32459.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-31 17:20:44

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Remove vg_validate call when parsing cached metadata.
	
	vg_validate call is an adept to optimisation, it is very
	ineeficient and slow.
	
	Anyway, we should call it only before writing data to disk.
	
	The call in lvmcache was just temporary validation,
	we realy do not need to revalidate cached metadata
	every time.
	(Actually, I added that there just to prove that cache works
	properly and forgot to remove it.)
	
	Patch removes it from lvmcache completely, this can hit only
	internal bug in export function (and this bug must
	be detected in any vg_write call anyway before).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1493&r2=1.1494
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/WHATS_NEW	2010/03/31 17:20:02	1.1493
+++ LVM2/WHATS_NEW	2010/03/31 17:20:44	1.1494
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Remove vg_validate call when parsing cached metadata.
   Use hash table of LVs to speed up parsing of text metadata with many LVs.
   Fix two messages, add a whitespace and parentheses
   When dmeventd is not forking because of -d flag, don't kill the parent process
--- LVM2/lib/cache/lvmcache.c	2010/03/17 02:11:18	1.82
+++ LVM2/lib/cache/lvmcache.c	2010/03/31 17:20:44	1.83
@@ -610,8 +610,7 @@
 						      vgid, NULL)))
 		return_NULL;
 
-	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid)) ||
-	    !vg_validate(vg)) {
+	if (!(vg = import_vg_from_buffer(vginfo->vgmetadata, fid))) {
 		_free_cached_vgmetadata(vginfo);
 		vg_release(vg);
 		return_NULL;


