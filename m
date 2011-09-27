From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Sep 2011 12:33:37 -0000
Subject: LVM2/lib/report columns.h
Message-ID: <20110927123337.13233.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-27 12:33:37

Modified files:
	lib/report     : columns.h 

Log message:
	correct thin_pool width

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/lib/report/columns.h	2011/09/09 00:54:49	1.47
+++ LVM2/lib/report/columns.h	2011/09/27 12:33:36	1.48
@@ -80,7 +80,7 @@
 FIELD(LVS, lv, STR, "Convert", lvid, 7, convertlv, convert_lv, "For lvconvert, Name of temporary LV created by lvconvert.", 0)
 FIELD(LVS, lv, STR, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "Log", lvid, 3, loglv, mirror_log, "For mirrors, the LV holding the synchronisation log.", 0)
-FIELD(LVS, lv, STR, "Pool", lvid, 3, poollv, thin_pool, "For thinly-provisioned devices, the pool LV holding the data.", 0)
+FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, thin_pool, "For thinly-provisioned devices, the pool LV holding the data.", 0)
 FIELD(LVS, lv, STR, "Modules", lvid, 7, modules, modules, "Kernel device-mapper modules required for this LV.", 0)
 
 FIELD(LABEL, pv, STR, "Fmt", id, 3, pvfmt, pv_fmt, "Type of metadata.", 0)


