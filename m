From: Petr Rockai <prockai@redhat.com>
Date: Tue, 24 Nov 2009 16:44:11 +0100
Subject: [PATCH] Do not try to unlock VG which is not locked.
In-Reply-To: <1259077083-707-1-git-send-email-mbroz@redhat.com> (Milan Broz's
	message of "Tue, 24 Nov 2009 16:38:03 +0100")
References: <1259077083-707-1-git-send-email-mbroz@redhat.com>
Message-ID: <87ocmsudv8.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Milan Broz <mbroz@redhat.com> writes:
> # vgchange -a y x --ignorelockingfailure
>   Volume group "x" not found
>   Internal error: Attempt to unlock unlocked VG x
>
> Signed-off-by: Milan Broz <mbroz@redhat.com>
> ---
>  tools/toollib.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>
> diff --git a/tools/toollib.c b/tools/toollib.c
> index 39a6d69..33daf30 100644
> --- a/tools/toollib.c
> +++ b/tools/toollib.c
> @@ -452,8 +452,7 @@ static int _process_one_vg(struct cmd_context *cmd, const char *vg_name,
>  		ret_max = ret;
>  
>  out:
> -	if ((vg_read_error(vg) == FAILED_ALLOCATION)||
> -	    (vg_read_error(vg) == FAILED_LOCKING))
> +	if (vg_read_error(vg))
>  		vg_release(vg);
>  	else
>  		unlock_and_release_vg(cmd, vg, vg_name);
looks good to me. The error path in vg_read (metadata.c) makes sure that
the VG is unlocked if any errors have happened.

=> ACK.

Yours,
    Petr.


