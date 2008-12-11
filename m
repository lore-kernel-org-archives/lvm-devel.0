From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 11 Dec 2008 16:49:55 -0500
Subject: [PATCH] New public functions lvm2_reload_config, lvm2_set_config_option and lvm2_reset_config_option.
In-Reply-To: <1229013822-10809-4-git-send-email-twoerner@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
	<1229013822-10809-3-git-send-email-twoerner@redhat.com>
	<1229013822-10809-4-git-send-email-twoerner@redhat.com>
Message-ID: <1229032195.20795.34.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-12-11 at 17:43 +0100, Thomas Woerner wrote:
> ---
>  lib/lvm2.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>  lib/lvm2.h |   38 ++++++++++++++++++++++++++++++++++++++
>  2 files changed, 90 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/lvm2.c b/lib/lvm2.c
> index daf9a79..ac5e583 100644
> --- a/lib/lvm2.c
> +++ b/lib/lvm2.c
> @@ -15,6 +15,30 @@
>  #include "lvm2.h"
>  #include "lib.h"
>  #include "toolcontext.h"
> +#include "archiver.h"
> +#include "activate.h"
> +#include "../tools/tools.h"
> +

Do we need the relative path here?

> +
> +static void _apply_settings(struct cmd_context *cmd)
> +{
> +  init_debug(cmd->current_settings.debug);
> +  init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
> +  init_test(cmd->current_settings.test);
> +  init_full_scan_done(0);
> +  init_mirror_in_sync(0);
> +  
> +  init_msg_prefix(cmd->default_settings.msg_prefix);
> +  init_cmd_name(cmd->default_settings.cmd_name);
> +
> +  archive_enable(cmd, cmd->current_settings.archive);
> +  backup_enable(cmd, cmd->current_settings.backup);
> +
> +  set_activation(cmd->current_settings.activation);
> +
> +  cmd->fmt = cmd->current_settings.fmt;
> +  cmd->handles_missing_pvs = 0;
> +}
>  

We should avoid duplicating this code with lvmcmdline.c.  Did you check
the other callers to see if we could consolidate somehow?

> 
>  lvm2_handle_t lvm2_create(const char *sys_dir)
> @@ -30,6 +54,8 @@ lvm2_handle_t lvm2_create(const char *sys_dir)
>     * - bind logging to handle
>     */
>  
> +  _apply_settings(cmd);
> +
>    return (lvm2_handle_t) cmd;
>  }
>  
> @@ -40,3 +66,29 @@ void lvm2_destroy(lvm2_handle_t libh)
>  
>    return 1;
>  }
> +
> +
> +int lvm2_reload_config(lvm2_handle_t libh)
> +{
> +  int refresh;
> +  
> +  refresh = refresh_toolcontext((struct cmd_context *) libh);
> +

I think we need:
cmd->current_settings = cmd->default_settings;

either here or at the bottom of refresh_toolcontext().  This I think is
a bug in the existing code so it does not necessarily apply to this
patch.  It is a problem for callers of refresh_toolcontext() though, and
I believe clvmd has this problem (see do_refresh_cache() in
lvm-functions.c).


> +  if (refresh)
> +    _apply_settings((struct cmd_context *) libh);
> +


> +  return refresh;
> +}
> +
> +
> +int lvm2_set_config_option(lvm2_handle_t libh, const char *option,
> +			   const char *value)
> +{
> +  return 1;
> +}
> +
> +
> +int lvm2_reset_config_option(lvm2_handle_t libh, const char *option)
> +{
> +  return 1;
> +}
> diff --git a/lib/lvm2.h b/lib/lvm2.h
> index b131fd7..b2c97d0 100644
> --- a/lib/lvm2.h
> +++ b/lib/lvm2.h
> @@ -49,4 +49,42 @@ lvm2_handle_t lvm2_create(const char *sys_dir);
>   */
>  void lvm2_destroy(lvm2_handle_t h);
>  
> +/*
> + * lvm2_reload_config
> + *
> + * Description: Reload configuration files
> + *
> + * Returns:
> + *   0: error
> + *   1: success
> + */
> +int lvm2_reload_config(lvm2_handle_t h);
> +
> +/*
> + * lvm2_set_config_option
> + *
> + * Description: Load an lvm config option into the existing configuration.
> + *   The formation of the option parameter is similar to the names
> + *   in /etc/lvm/lvm.conf.
> + *   An option within a section is specified with a '/' between the
> + *   section name and option.  For example, the 'filter' option in the
> + *   devices section is specified by 'devices/filter'
> + *
> + * Returns:
> + *   0: error
> + *   1: success
> + */
> +int lvm2_set_config_option(lvm2_handle_t h, const char *option,
> +			   const char *value);
> +/*
> + * lvm2_remove_config_option
> + *
> + * Description:
> + *
> + * Returns:
> + *   0: error
> + *   1: success
> + */
> +int lvm2_reset_config_option(lvm2_handle_t h, const char *option);
> +

We should probably be consistent with return code types - uint32_t?

Then again, if we're going to try to use errno return values perhaps we
need int after all?


