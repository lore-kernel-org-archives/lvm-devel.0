From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 30 Jun 2010 21:40:27 -0000
Subject: LVM2/daemons/clvmd lvm-functions.c
Message-ID: <20100630214027.27911.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-06-30 21:40:27

Modified files:
	daemons/clvmd  : lvm-functions.c 

Log message:
	Maintain memlock balance in clvmd.
	
	When a mirror is being downconverted in a cluster, a series of suspends and
	resumes is executed.
	
	With the change to using UUIDs in dev_manager instead of names, the behaviour
	has changed with regards to including an _mlog in the deptree of a logical
	volume. In the old (pre-UUID-enabled) code, the _mlog would appear in a deptree
	of any volume purely based on a name match: a linear volume foo would include
	foo_mlog in its dependencies if that happened to exist. This behaviour was
	fixed and the mlog is now only included for mirrors.
	
	By a coincidence, this mlog bug had been hiding a different bug in clvmd. When
	a mirror is being dismantled (and converted to a linear volume), it is first
	suspended as a whole, then later resumed in parts. Nevertheless, the overall
	memlock balance is maintained in this operation. The problem kicks in, because
	even though the mirror log was suspended as part of the mirror, when the
	dismantled mirror is resumed again, it is no longer a mirror and therefore the
	mirror log stays suspended. This would not be a problem in itself, since
	_delete_lv (from metadata/mirror.c) is called on it subsequently, which does an
	activate/deactivate cycle and removes the LV. The activate/deactivate cycle
	correctly prompts clvmd to resume the device: however, in doing this, it will
	issue an unpaired resume operation (the suspend that caused the mirror log to
	be suspended is paired with resuming the dismantled mirror later). We have
	concluded that the path in clvmd should never affect memlock_count, since there
	should never be an unmatched explicit suspend preceding this resume.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95

--- LVM2/daemons/clvmd/lvm-functions.c	2010/06/21 15:56:58	1.94
+++ LVM2/daemons/clvmd/lvm-functions.c	2010/06/30 21:40:27	1.95
@@ -354,9 +354,13 @@
 	if (!lv_info_by_lvid(cmd, resource, &lvi, 0, 0))
 		goto error;
 
-	if (lvi.suspended)
-		if (!lv_resume(cmd, resource))
+	if (lvi.suspended) {
+		memlock_inc(cmd);
+		if (!lv_resume(cmd, resource)) {
+			memlock_dec(cmd);
 			goto error;
+		}
+	}
 
 	/* Now activate it */
 	if (!lv_activate(cmd, resource, exclusive))


