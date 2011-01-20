From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 20 Jan 2011 11:34:46 +0100
Subject: [PATCH] Print less scary message if pvmove already finished.
In-Reply-To: <1295476632-9949-1-git-send-email-mbroz@redhat.com>
References: <1295476632-9949-1-git-send-email-mbroz@redhat.com>
Message-ID: <4D380FC6.2020101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.1.2011 23:37, Milan Broz napsal(a):
> If other process finishes (ar aborts) pvmove operation and
> polling function cannot find any lv with PVMOVE flag return
> success and do not print  "aborting" message.
> 
> Fixes https://bugzilla.redhat.com/show_bug.cgi?id=602389
> ---
>  tools/polldaemon.c |   12 ++++++++++--
>  1 files changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/polldaemon.c b/tools/polldaemon.c
> index aac9c17..fdb3edd 100644
> --- a/tools/polldaemon.c
> +++ b/tools/polldaemon.c
> @@ -193,8 +193,16 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
>  			return 0;
>  		}
>  
> -		if (!(lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid,
> -							parms->lv_type))) {
> +		lv = parms->poll_fns->get_copy_lv(cmd, vg, name, uuid, parms->lv_type);
> +
> +		if (!lv && parms->lv_type == PVMOVE) {
> +			log_print("%s: pvmove finished or aborted by other process.",
> +				  name);
> +			unlock_and_free_vg(cmd, vg, vg->name);
> +			return 1;
> +		}
> +
> +		if (!lv) {
>  			log_error("ABORTING: Can't find LV in %s for %s",
>  				  vg->name, name);
>  			unlock_and_free_vg(cmd, vg, vg->name);


I would move it into the same 'if (!lv)'
and just add a sub if for   if (parms->...) { }


Zdenek


