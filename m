From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 03 Dec 2009 12:49:37 -0500
Subject: [PATCH] Remove newly created log volume if initial deactivation fails.
In-Reply-To: <1259847079-23268-1-git-send-email-mbroz@redhat.com>
References: <1259847079-23268-1-git-send-email-mbroz@redhat.com>
Message-ID: <1259862577.2283.7.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2009-12-03 at 14:31 +0100, Milan Broz wrote:
> If there is problem deactivate LV and
> _init_mirror_log is called with remove_on_failure = 1,
> remove the newly created log LV from metadata.
> 
> (This can happen if there is active device with the same name
> but different UUID.)
> 
> Signed-off-by: Milan Broz <mbroz@redhat.com>
> ---
>  lib/metadata/mirror.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
> index c331e0e..4c24058 100644
> --- a/lib/metadata/mirror.c
> +++ b/lib/metadata/mirror.c
> @@ -256,7 +256,7 @@ static int _init_mirror_log(struct cmd_context *cmd,
>  	/* If the LV is active, deactivate it first. */
>  	if (lv_info(cmd, log_lv, &info, 0, 0) && info.exists) {
>  		if (!deactivate_lv(cmd, log_lv))
> -			return_0;
> +			goto revert_new_lv;
>  		was_active = 1;
>  	}
>  

This doesn't look right based on my read of the function.
First, if we goto revert_new_lv, we do all this recovery which is based
on things that have not happened.  Also, later in the function we have
this:
	if (!deactivate_lv(cmd, log_lv)) {
		log_error("Aborting. Failed to deactivate mirror log. "
			  "Manual intervention required.");
		return 0;
	}

Do we just need a log_error() in your place above or is the recovery wrong later?


> @@ -1354,7 +1354,7 @@ static struct logical_volume *_set_up_mirror_log(struct cmd_context *cmd,
>  	}
>  
>  	if (!_init_mirror_log(cmd, log_lv, in_sync, &lv->tags, 1)) {
> -		log_error("Failed to create mirror log.");
> +		log_error("Failed to initialise mirror log.");
>  		return NULL;
>  	}
>  



