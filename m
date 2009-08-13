From: Petr Rockai <prockai@redhat.com>
Date: Thu, 13 Aug 2009 14:54:15 +0200
Subject: [PATCH] DRAFT! write lock priority
In-Reply-To: <20090812223551.GQ7033@agk-dp.fab.redhat.com> (Alasdair
	G. Kergon's message of "Wed, 12 Aug 2009 23:35:51 +0100")
References: <87skfxtr89.fsf@twilight.int.mornfall.net.>
	<20090812223551.GQ7033@agk-dp.fab.redhat.com>
Message-ID: <87fxbvub60.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair G Kergon <agk@redhat.com> writes:
> I'm still not sure what best to call it, without it becoming rather too long.
> I reckon 'prioritisation' works better than 'priority' though with this
> proposal i.e. global/write_lock_prioritisation.
> That it only (currently) affects "local file-based locking (type 1)" can be
> covered by the comments in example.conf.
Yes, that should be documented indeed.

> Add a comment to show what the result of this code is.
> "aux_" is a decent idea for the prefix: any other ideas?
> Something based on 'waiting' or 'queue'?
> Best might be a suffix on the existing name, with a separator
> character that cannot appear in a VG name.
>    V_vg1:queue
> Then a sorted 'ls' will list them adacently.
I have thought about that at first (it was actually easier to implement), but I
decided against because it feels fragile. So unless you think it's worth it,
I'd stick with the prefix solution, which is I think quite foolproof.

> @@ -207,7 +216,22 @@ static int _lock_file(const char *file, 
>  	log_very_verbose("Locking %s %c%c", ll->res, state,
>  			 nonblock ? ' ' : 'B');
>  
> We may be missing some further log messages here: I want
> every flock operation logged.  Maybe the messages should move to
> _do_flock / _undo_flock, or we should just have additional log_debug ones
> at this level for the new calls.
Ok.

>
> -	r = _do_flock(file, &ll->lf, operation, nonblock);
> +	if (!_write_priority) {
> +		r = _do_flock(file, &ll->lf, operation, nonblock);
> +	else {
> +		if (flags & LCK_WRITE) {
> +			if ((r = _do_flock(file_aux, &fd_aux, LOCK_EX, nonblock))) {
>
> Ah - something got missed here:  In the design, all these fd_aux locking
> operations block if the lock is not available, so remove 'nonblock' from those 2
> lines.  (I don't see that causing any deadlocks, and it removes avoidable
> failure modes.)  Non-blocking locks in LVM are only used to avoid deadlocks -
> waiting is always acceptable (but will permit the ctrl-c option).
Ok, that makes sense. I didn't realize right away we only want nonblocking for
deadlock avoidance.

I'll check the refactor patch in, and amend the actual-fix one and send it in a
while.

Yours,
   Petr.


