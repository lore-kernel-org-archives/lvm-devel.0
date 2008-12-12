From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 12 Dec 2008 01:04:33 +0000
Subject: [PATCH] Renamed create_toolcontext function to _create_context and added sys_dir as argument, new functions create_librarycontext and create_toolcontext.
In-Reply-To: <1229013822-10809-2-git-send-email-twoerner@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
Message-ID: <20081212010433.GT24785@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Dec 11, 2008 at 05:43:40PM +0100, Thomas Woerner wrote:
> +++ b/lib/commands/toolcontext.c
> @@ -990,9 +990,10 @@ static void _init_rand(struct cmd_context *cmd)

> -struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
> -				       unsigned is_long_lived)
> +static struct cmd_context *_create_context(struct arg *the_args,
> +					   unsigned is_static,
> +					   unsigned is_long_lived,
> +					   const char *sys_dir)

> @@ -1024,7 +1025,10 @@ struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
> -	strcpy(cmd->sys_dir, DEFAULT_SYS_DIR);
> +	strncpy(cmd->sys_dir, DEFAULT_SYS_DIR, PATH_MAX);

No need for that one - I think it's safe to assume DEFAULT_SYS_DIR is shorter
than PATH_MAX or else it would be impossible to use!

> +	if (sys_dir)
> +		strncpy(cmd->sys_dir, sys_dir, PATH_MAX);

Oops - trailing NULL if it's too long?

> @@ -1101,6 +1105,19 @@ struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
  
> +/* Library Entry point */
> +struct cmd_context *create_librarycontext(const char *sys_dir)
> +{
> +	return _create_context(NULL, 0, 1, sys_dir);
> +}

> +/* Tool Entry point */
> +struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static,
> +				       unsigned is_long_lived)
> +{
> +	return _create_context(the_args, is_static, is_long_lived, NULL);
> +}

Please don't separate these.  All tools will use the same library interface -
there is to be nothing privileged about the existing tools in the tools dir or
anaconda - they will both share the same interface.  So work out where those
parameters should live.

Alasdair
-- 
agk at redhat.com


