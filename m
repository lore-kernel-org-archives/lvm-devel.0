From: Thanos Makatos <thanos.makatos@citrix.com>
Date: Thu, 30 Jan 2014 15:50:19 +0000
Subject: [PATCH] Return non-zero on violation of global/metadata_read_only
In-Reply-To: <1389720145-29182-1-git-send-email-thanos.makatos@citrix.com>
References: <1389720145-29182-1-git-send-email-thanos.makatos@citrix.com>
Message-ID: <2368A3FCF9F7214298E53C823B0A48EC11EF2F@AMSPEX01CL02.citrite.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


> -----Original Message-----
> From: Thanos Makatos [mailto:thanos.makatos at citrix.com]
> Sent: 14 January 2014 17:22
> To: lvm-devel at redhat.com
> Cc: Thanos Makatos
> Subject: [PATCH] Return non-zero on violation of
> global/metadata_read_only
> 
> Signed-off-by: Thanos Makatos <thanos.makatos@citrix.com>
> ---
>  tools/lvmcmdline.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c index
> 6fe4670..c87cf4e 100644
> --- a/tools/lvmcmdline.c
> +++ b/tools/lvmcmdline.c
> @@ -1163,6 +1163,7 @@ int lvm_run_command(struct cmd_context *cmd, int
> argc, char **argv)
>  	    !(cmd->command->flags & PERMITTED_READ_ONLY)) {
>  		log_error("%s: Command not permitted while
> global/metadata_read_only "
>  			  "is set.", cmd->cmd_line);
> +		ret = ECMD_FAILED;
>  		goto out;
>  	}
> 
> --
> 1.7.9.5

Ping?


