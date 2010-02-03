From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 03 Feb 2010 17:29:13 -0600
Subject: [PATCH] up-convert of core log mirrors will resync twice (bug 510526)
Message-ID: <1265239753.23524.15.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When "up-converting" (i.e. adding a mirror leg) to an existing
core-logged mirror, two resyncs will take place.  The first happens
simply to bring the newly added leg into sync with the rest of the
mirror legs.  The second happens because the polling that is done to
wait for the conversion expects to collapse a two-level mirror into one
larger mirror.  [It turns out, that a two level mirror is not made when
a core-logged mirror is the starting point, however.]  There are two
potential fixes for this:

1) use 'init_mirror_in_sync(1)' to load the mirror table with SYNC after
the first resync is done - during the time when layered mirrors are
normally collapsed

2) Don't flag the mirror as 'CONVERTING', since it isn't converting in
the manor which is normally associated with that flag (i.e via mirror
stacking)

#2 is my favorite because there is less processing.  (#1 might be more
correct if we were properly stacking mirrors when converting core-logged
mirrors, but that isn't feasible at the moment.)  Below is option #2.

Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -335,6 +335,9 @@ static int _finish_lvconvert_mirror(stru
 {
 	int r = 0;
 
+	if (!(lv->status & CONVERTING))
+		return 1;
+
 	if (!collapse_mirrored_lv(lv)) {
 		log_error("Failed to remove temporary sync layer.");
 		return 0;
@@ -967,7 +970,8 @@ static int _lvconvert_mirrors(struct cmd
 			stack;
 			return failure_code;
 		}
-		lv->status |= CONVERTING;
+		if (seg->log_lv)
+			lv->status |= CONVERTING;
 		lp->need_polling = 1;
 	}
 



