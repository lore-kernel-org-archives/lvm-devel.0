From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 12 Aug 2009 23:35:51 +0100
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <87skfxtr89.fsf@twilight.int.mornfall.net.>
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
Message-ID: <20090812223551.GQ7033@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> +#define DEFAULT_WRITE_LOCK_PRIORITY 1
  
Naming should follow a consistent pattern throughout - the #define here,
the config option name, internal variables etc.

I'm still not sure what best to call it, without it becoming rather too long.
I reckon 'prioritisation' works better than 'priority' though with this
proposal i.e. global/write_lock_prioritisation.
That it only (currently) affects "local file-based locking (type 1)" can be
covered by the comments in example.conf.

> +static int _write_priority;

The names should all match, once one has been selected.

+	char *file_aux = alloca(strlen(file) + 5);
Use sizeof instead of 5.

+	strcpy(file_aux, file);
+	/* There is always a slash before the basename part of the filename. */
+	*(strrchr(file_aux, '/') + 1) = 0;
+	strcat(file_aux, "aux_");
Use #define (tie to the sizeof above).

+	strcat(file_aux, strrchr(file, '/') + 1);
 
Add a comment to show what the result of this code is.
"aux_" is a decent idea for the prefix: any other ideas?
Something based on 'waiting' or 'queue'?
Best might be a suffix on the existing name, with a separator
character that cannot appear in a VG name.
   V_vg1:queue
Then a sorted 'ls' will list them adacently.

@@ -207,7 +216,22 @@ static int _lock_file(const char *file, 
 	log_very_verbose("Locking %s %c%c", ll->res, state,
 			 nonblock ? ' ' : 'B');
 
We may be missing some further log messages here: I want
every flock operation logged.  Maybe the messages should move to
_do_flock / _undo_flock, or we should just have additional log_debug ones
at this level for the new calls.

-	r = _do_flock(file, &ll->lf, operation, nonblock);
+	if (!_write_priority) {
+		r = _do_flock(file, &ll->lf, operation, nonblock);
+	else {
+		if (flags & LCK_WRITE) {
+			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, nonblock))) {

Ah - something got missed here:  In the design, all these fd_aux locking
operations block if the lock is not available, so remove 'nonblock' from those 2
lines.  (I don't see that causing any deadlocks, and it removes avoidable
failure modes.)  Non-blocking locks in LVM are only used to avoid deadlocks -
waiting is always acceptable (but will permit the ctrl-c option).

+				r = _do_flock(file, &ll->lf, operation, nonblock);
+				_undo_flock(file_aux, fd_aux);
+			}
+		} else {
+			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, nonblock))) {
+				_undo_flock(file_aux, fd_aux);
+				r = _do_flock(file, &ll->lf, operation, nonblock);
+			}
+		}
+	}

Alasdair


