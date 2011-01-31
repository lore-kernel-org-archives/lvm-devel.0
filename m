From: Petr Rockai <prockai@redhat.com>
Date: Mon, 31 Jan 2011 16:12:54 +0100
Subject: [PATCH 1/1] Fix udev synchronization for no-locking mode
In-Reply-To: <4782409942e1848995a1f1abd3f9eb83ffb43de0.1296484980.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Mon, 31 Jan 2011 15:44:10 +0100")
References: <cover.1296484980.git.zkabelac@redhat.com>
	<4782409942e1848995a1f1abd3f9eb83ffb43de0.1296484980.git.zkabelac@redhat.com>
Message-ID: <87bp2xnm2x.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

looks OK, although one thing is definitely puzzling: the udev wait is
mentioned in 3 places (2 removals and 1 addition) in the patch:
nevertheless, no two places agree on which function to use for
that. It'd be good to know why is that? (I can sort of understand that
clvmd has a wrapper, but the removed functions still don't agree with
the added one.)

Other than that, ack.

On a second thought: are we sure this is not going to break clvmd?
Please double-check that. There was trouble with that recently, IIRC.

Zdenek Kabelac <zkabelac@redhat.com> writes:

> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
Reviewed-by: Petr Rockai <prockai@redhat.com>

> diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
> index 3872702..6d0dee4 100644
> --- a/daemons/clvmd/clvmd-command.c
> +++ b/daemons/clvmd/clvmd-command.c
> @@ -217,7 +217,6 @@ static int lock_vg(struct local_client *client)
>  	if (lkid == 0)
>  	    return EINVAL;
>  
> -	lvm_do_fs_unlock(); /* Wait for devices */
>  	status = sync_unlock(lockname, lkid);
>  	if (status)
>  	    status = errno;
> diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
> index 0c8bbed..68b0420 100644
> --- a/lib/locking/file_locking.c
> +++ b/lib/locking/file_locking.c
> @@ -215,7 +215,6 @@ static int _lock_file(const char *file, uint32_t flags)
>  		state = 'W';
>  		break;
>  	case LCK_UNLOCK:
> -		fs_unlock(); /* Wait until devices are available */
>  		return _release_lock(file, 1);
>  	default:
>  		log_error("Unrecognised lock type: %d", flags & LCK_TYPE_MASK);
> diff --git a/lib/locking/locking.c b/lib/locking/locking.c
> index 645f25d..c923610 100644
> --- a/lib/locking/locking.c
> +++ b/lib/locking/locking.c
> @@ -442,6 +442,10 @@ int lock_vol(struct cmd_context *cmd, const char *vol, uint32_t flags)
>  		/* If LVM1 driver knows about the VG, it can't be accessed. */
>  		if (!check_lvm1_vg_inactive(cmd, vol))
>  			return_0;
> +
> +		/* Before unlocking VG wait until devices are available. */
> +		if ((flags & LCK_TYPE_MASK) == LCK_UNLOCK)
> +			sync_local_dev_names(cmd);
>  		break;
>  	case LCK_LV:
>  		/* All LV locks are non-blocking. */


