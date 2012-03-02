From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Mar 2012 21:50:03 -0000
Subject: LVM2/lib/cache lvmetad.h
Message-ID: <20120302215003.23673.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-02 21:50:03

Modified files:
	lib/cache      : lvmetad.h 

Log message:
	fix non-lvmetad pvscan macro

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/lib/cache/lvmetad.h	2012/03/02 20:46:37	1.5
+++ LVM2/lib/cache/lvmetad.h	2012/03/02 21:50:02	1.6
@@ -120,7 +120,7 @@
 #    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
-#    define pvscan_lvmetad(cmd, argc, argv)	(0)
+#    define pvscan_lvmetad_single(cmd, pv_name)	(0)
 
 #  endif	/* LVMETAD_SUPPORT */
 


