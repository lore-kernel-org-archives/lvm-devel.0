From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 14 Oct 2011 14:21:33 -0000
Subject: LVM2/lib/metadata segtype.h
Message-ID: <20111014142133.7219.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-10-14 14:21:33

Modified files:
	lib/metadata   : segtype.h 

Log message:
	Use a more correct macro for 'seg_is_linear'
	
	It is better to check 'seg->area_count == 1' than '!seg->stripe_size'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/metadata/segtype.h	2011/10/07 14:52:27	1.43
+++ LVM2/lib/metadata/segtype.h	2011/10/14 14:21:32	1.44
@@ -47,7 +47,7 @@
 #define seg_is_replicator(seg)	((seg)->segtype->flags & SEG_REPLICATOR ? 1 : 0)
 #define seg_is_replicator_dev(seg) ((seg)->segtype->flags & SEG_REPLICATOR_DEV ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
-#define     seg_is_linear(seg)  (seg_is_striped(seg) && !(seg)->stripe_size)
+#define     seg_is_linear(seg)  (seg_is_striped(seg) && ((seg)->area_count == 1))
 #define seg_is_snapshot(seg)	((seg)->segtype->flags & SEG_SNAPSHOT ? 1 : 0)
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_is_raid(seg)	((seg)->segtype->flags & SEG_RAID ? 1 : 0)


