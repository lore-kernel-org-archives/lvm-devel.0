From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Jun 2010 22:55:50 +0200
Subject: [PATCH] maintain memlock balance in clvmd
Message-ID: <87tyokjl49.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is the first of two patches that are result of today's debugging
session with Milan. When a mirror is being downconverted in a cluster, a
series of suspends and resumes is executed.

With the change of using UUIDs in dev_manager instead of names, the
behaviour has changed with regards to including an _mlog in the deptree
of a logical volume. In the old (pre-UUID-enabled) code, the _mlog would
appear in a deptree of any volume purely based on a name match: a linear
volume foo would include foo_mlog in its dependencies if that happened
to exist. This behaviour was fixed and the mlog is now only included for
mirrors.

By a coincidence, this mlog bug had been hiding a different bug in
clvmd. When a mirror is being dismantled (and converted to a linear
volume), it is first suspended as a whole, then later resumed in
parts. Nevertheless, the overall memlock balance is maintained in this
operation. The problem kicks in, because even though the mirror log was
suspended as part of the mirror, when the dismantled mirror is resumed
again, it is no longer a mirror and therefore the mirror log stays
suspended. This would not be a problem in itself, since _delete_lv (from
metadata/mirror.c) is called on it subsequently, which does an
activate/deactivate cycle and removes the LV. The activate/deactivate
cycle correctly prompts clvmd to resume the device: however, in doing
this, it will issue an unpaired resume operation (the suspend that
caused the mirror log to be suspended is paired with resuming the
dismantled mirror later). We have concluded that the path in clvmd
should never affect memlock_count, since there should never be an
unmatched explicit suspend preceding this resume. The following patch
implements this fix.

This should address some of the recent bugzillas, although I don't have
a list of candidates handy. Milan would probably know though.

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 8128728..257e29c 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -354,9 +354,13 @@ static int do_activate_lv(char *resource, unsigned char lock_flags, int mode)
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


