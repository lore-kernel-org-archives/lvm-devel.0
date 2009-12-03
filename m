From: Petr Rockai <prockai@redhat.com>
Date: Thu, 03 Dec 2009 21:27:14 +0100
Subject: [PATCH] Fix memory lock imbalance in lv_suspend if already suspended.
In-Reply-To: <1259857400-5778-1-git-send-email-mbroz@redhat.com> (Milan Broz's
	message of "Thu, 3 Dec 2009 17:23:20 +0100")
References: <1259857073-5036-1-git-send-email-mbroz@redhat.com>
	<1259857400-5778-1-git-send-email-mbroz@redhat.com>
Message-ID: <87my1z247x.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Milan Broz <mbroz@redhat.com> writes:
> pvmove suspends all moved LVs + pvmoveX mirrored LV itself.
>
> This suspends even underlying pvmoveX and following explicit
> suspend call is just noop.
>
> But in resume the pvmoveX volume is no longer underlying
> device for moved LVs, so it performs full resume with memlock
> decrease.
>
> Code must call memlock_inc() if suspend is requested, volume
> is already suspended and error is not requested.
could you please attach (maybe shortened version) of the above as a
comment in the code? I think the memlock_inc() there really deserves a
statement of purpose.

It also seems a little suspect to tie in the memlock with
"error_if_not_suspended". Actually, what exactly does that variable
mean? Does it really mean error_if_already_suspended? That seems to be
the case from my reading of that code. Hm. Now I see it's also invoked
if the device does not exist. So what you say is that memlock_inc()
needs to be called when the suspend fails due to the device already
being suspended and this error is being ignored.

I am not entirely sure this is the right fix -- it seems to imply that
when a suspend is called twice on a device (knowingly ignoring errors
due to double suspend), resume will be called twice and will trigger two
memlock_dec() operations.

I think this is similar to what happens in the mirror image removal case
that I fixed earlier: a device is suspended (as a single tree) and then
resumed in two steps (since it has been dismantled into two pieces). I
think it would be more appropriate to fix the imbalance at the callsite
if that's possible, like we have done in the mirror case. This proposed
fix seems to me to be introducing certain subtlety in how suspend/resume
tracks memlocks, which is not that unlikely to backfire later.

A proper fix would probably involve calling memlock for each
suspended/resumed tree *node* not per tree. That way, if tree is split
in two, it should maintain the number of nodes. But this would need
further checking, I haven't verified the precondition.

Anyway, I'd propose fixing this higher up the stack, if that's feasible.

> --- a/lib/activate/activate.c
> +++ b/lib/activate/activate.c
> @@ -879,7 +879,11 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
>  		goto_out;
>  
>  	if (!info.exists || info.suspended) {
> -		r = error_if_not_suspended ? 0 : 1;
> +		if (!error_if_not_suspended) {
> +			r = 1;
> +			if (info.suspended)
> +				memlock_inc();
> +		}
>  		goto out;
>  	}

Yours,
   Petr.


