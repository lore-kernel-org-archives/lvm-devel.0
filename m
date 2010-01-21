From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 21 Jan 2010 12:23:23 -0500
Subject: [PATCH] Do not print "-1" as locking type if locking fails.
In-Reply-To: <1264091865-4776-1-git-send-email-mbroz@redhat.com>
References: <1264091865-4776-1-git-send-email-mbroz@redhat.com>
Message-ID: <1264094603.4120.3.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2010-01-21 at 17:37 +0100, Milan Broz wrote:
> Move error message to locking constructor and print
> more descriptive message if locking fails instead of
> "Locking type -1 initialisation failed."
> ---
>  lib/locking/locking.c |   16 ++++++++++++----
>  liblvm/lvm_base.c     |    1 -
>  tools/lvmcmdline.c    |    2 --
>  3 files changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/lib/locking/locking.c b/lib/locking/locking.c
> index a2c6a3e..54e5e25 100644
> --- a/lib/locking/locking.c
> +++ b/lib/locking/locking.c
> @@ -224,7 +224,7 @@ int init_locking(int type, struct cmd_context *cmd)
>  
>  	_blocking_supported = find_config_tree_int(cmd,
>  	    "global/wait_for_locks", DEFAULT_WAIT_FOR_LOCKS);
> -	
> +
>  	switch (type) {
>  	case 0:
>  		init_no_locking(&_locking, cmd);
> @@ -236,8 +236,10 @@ int init_locking(int type, struct cmd_context *cmd)
>  		log_very_verbose("%sFile-based locking selected.",
>  				 _blocking_supported ? "" : "Non-blocking ");
>  
> -		if (!init_file_locking(&_locking, cmd))
> +		if (!init_file_locking(&_locking, cmd)) {
> +			log_error("File-based locking initialisation failed.");
>  			break;
> +		}
>  		return 1;
>  
>  #ifdef HAVE_LIBDL
> @@ -249,8 +251,10 @@ int init_locking(int type, struct cmd_context *cmd)
>  		}
>  		if (!find_config_tree_int(cmd, "locking/fallback_to_clustered_locking",
>  			    find_config_tree_int(cmd, "global/fallback_to_clustered_locking",
> -						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING)))
> +						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING))) {
> +			log_error("External locking initialisation failed.");
>  			break;
> +		}
>  #endif

This looks strange and inconsistent with the rest of the code.
IMO the message be directly under the above code when
init_external_locking() fails, as the others are.

>  
>  #ifdef CLUSTER_LOCKING_INTERNAL
> @@ -259,8 +263,10 @@ int init_locking(int type, struct cmd_context *cmd)
>  
>  	case 3:
>  		log_very_verbose("Cluster locking selected.");
> -		if (!init_cluster_locking(&_locking, cmd))
> +		if (!init_cluster_locking(&_locking, cmd)) {
> +			log_error("Internal cluster locking initialisation failed.");
>  			break;
> +		}
>  		return 1;
>  #endif
>  
> @@ -285,6 +291,8 @@ int init_locking(int type, struct cmd_context *cmd)
>  			  "be inaccessible.");
>  		if (init_file_locking(&_locking, cmd))
>  			return 1;
> +		else
> +			log_error("File-based locking initialisation failed.");
>  	}
>  
>  	if (!ignorelockingfailure())
> diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
> index b4be906..ac94692 100644
> --- a/liblvm/lvm_base.c
> +++ b/liblvm/lvm_base.c
> @@ -51,7 +51,6 @@ lvm_t lvm_init(const char *system_dir)
>  	/* initialize locking */
>  	if (!init_locking(-1, cmd)) {
>  		/* FIXME: use EAGAIN as error code here */
> -		log_error("Locking initialisation failed.");
>  		lvm_quit((lvm_t) cmd);
>  		return NULL;
>  	}
> diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
> index e4b56da..ad1513d 100644
> --- a/tools/lvmcmdline.c
> +++ b/tools/lvmcmdline.c
> @@ -1027,8 +1027,6 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
>  		locking_type = -1;
>  
>  	if (!init_locking(locking_type, cmd)) {
> -		log_error("Locking type %d initialisation failed.",
> -			  locking_type);
>  		ret = ECMD_FAILED;
>  		goto out;
>  	}

The rest of the patch looks fine.  Ack.


