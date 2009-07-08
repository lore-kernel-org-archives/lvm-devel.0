From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 08 Jul 2009 12:56:44 -0400
Subject: [PATCH 1/2] Add cmd logging for liblvm error reporting: All logging functions have an additional argument: The error code This makes the functions incompatible with the old ones.
In-Reply-To: <1246998001-17258-2-git-send-email-twoerner@redhat.com>
References: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
	<1246998001-17258-2-git-send-email-twoerner@redhat.com>
Message-ID: <1247072204.2507.26.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm taking a few more review passes and have a couple more comments -
see below.

> --- a/daemons/clvmd/lvm-functions.c
> +++ b/daemons/clvmd/lvm-functions.c
> @@ -788,7 +788,12 @@ void lvm_do_backup(const char *vgname)
>  int init_lvm(int using_gulm)
>  {
>  	if (!(cmd = create_toolcontext(1, NULL))) {
> -		log_error("Failed to allocate command context");
> +		log_error(0, "Failed to allocate command context");
> +		return 0;
> +	}
> +
> +	if (lvm_error(cmd) != 0) {
> +		log_error(0, "Failed to create command context");
>  		return 0;
>  	}
>  

We need that non-zero error code in log_error() to catch
create_toolcontext() errors.


> diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
> index 4f6cf98..12b881b 100644
> --- a/lib/commands/toolcontext.c
> +++ b/lib/commands/toolcontext.c
> @@ -1031,6 +1031,9 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
>  	dm_list_init(&cmd->tags);
>  	dm_list_init(&cmd->config_files);
>  
> +	/* Log to command */
> +	init_log_cmd(cmd);
> +
>  	/*
>  	 * Environment variable LVM_SYSTEM_DIR overrides this below.
>  	 */
> @@ -1112,16 +1115,7 @@ struct cmd_context *create_toolcontext(unsigned is_long_lived,
>  	return cmd;
>  
>        error:
> -	_destroy_tag_configs(cmd);
> -	dev_cache_exit();
> -	if (cmd->filter)
> -		cmd->filter->destroy(cmd->filter);
> -	if (cmd->mem)
> -		dm_pool_destroy(cmd->mem);
> -	if (cmd->libmem)
> -		dm_pool_destroy(cmd->libmem);
> -	dm_free(cmd);
> -	return NULL;
> +	return cmd;
>  }
>  

Ok, so this cleanup gets moved to destroy_toolcontext() and we always
return a handle from create_toolcontext() (unless we could not allocate,
in which case we return NULL).


>  static void _destroy_formats(struct dm_list *formats)
> @@ -1240,12 +1234,15 @@ void destroy_toolcontext(struct cmd_context *cmd)
>  	label_exit();
>  	_destroy_segtypes(&cmd->segtypes);
>  	_destroy_formats(&cmd->formats);
> -	cmd->filter->destroy(cmd->filter);
> -	dm_pool_destroy(cmd->mem);
> +	if (cmd->filter)
> +		cmd->filter->destroy(cmd->filter);
> +	if (cmd->mem)
> +		dm_pool_destroy(cmd->mem);
>  	dev_cache_exit();
>  	_destroy_tags(cmd);
>  	_destroy_tag_configs(cmd);
> -	dm_pool_destroy(cmd->libmem);
> +	if (cmd->libmem)
> +		dm_pool_destroy(cmd->libmem);
>  	dm_free(cmd);

Strange why the cleanup order is different in this function than
create_toolcontext() but that is not an issue with your patch.  Ok.

The bottom of this function looks a bit strange though it might be best
to leave it:
	cmd->config_valid = 1;
	return cmd;

      error:
	return cmd;


>  }
> diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
> index 1ad14d0..555be8f 100644
> --- a/tools/lvmcmdline.c
> +++ b/tools/lvmcmdline.c
> @@ -1179,6 +1179,11 @@ struct cmd_context *init_lvm(void)
>  	if (!(cmd = create_toolcontext(0, NULL)))
>  		return_NULL;
>  
> +	if (cmd_error(cmd) != 0) {
> +		destroy_toolcontext(cmd);
> +		return_NULL;
> +	}
> +
>  	return cmd;
>  }

This is another example of why we need the non-zero default.  If you use
0 everywhere, we could get an error in create_toolcontext(), then never
realize it and not cleanup properly.

Maybe we can add a couple tests to catch initialization problems and
make sure certain error paths get hit.

>  
> diff --git a/tools/pvchange.c b/tools/pvchange.c
> index efc780b..def78cc 100644
> --- a/tools/pvchange.c
> +++ b/tools/pvchange.c
> @@ -64,9 +64,8 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
>  		}
>  
>  		if (!(pvl = find_pv_in_vg(vg, pv_name))) {
> -			log_error
> -			    ("Unable to find \"%s\" in volume group \"%s\"",
> -			     pv_name, vg->name);
> +			log_error("Unable to find \"%s\" in volume group \"%s\"",
> +				  pv_name, vg->name);
>  			goto out;
>  		}
>  		if (tagarg && !(vg->fid->fmt->features & FMT_TAGS)) {
> diff --git a/tools/pvmove.c b/tools/pvmove.c
> index 65b7606..2490863 100644
> --- a/tools/pvmove.c
> +++ b/tools/pvmove.c
> @@ -400,15 +400,13 @@ static int _set_up_pvmove(struct cmd_context *cmd, const char *pv_name,
>  			log_error("Ignoring remaining command line arguments");
>  
>  		if (!(lvs_changed = lvs_using_lv(cmd, vg, lv_mirr))) {
> -			log_error
> -			    ("ABORTING: Failed to generate list of moving LVs");
> +			log_error("ABORTING: Failed to generate list of moving LVs");
>  			goto out;
>  		}
>  
>  		/* Ensure mirror LV is active */
>  		if (!_activate_lv(cmd, lv_mirr, exclusive)) {
> -			log_error
> -			    ("ABORTING: Temporary mirror activation failed.");
> +			log_error("ABORTING: Temporary mirror activation failed.");
>  			goto out;
>  		}
>  

These probably belong in another tiny cleanup patch that can go in
immediately.

I believe the convention in lvm source is to break long quoted strings
into two quotes on two lines.  For example:
log_error("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
log_error("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	  "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
So if you find anything like that you can just checkin the fixup I
believe.


