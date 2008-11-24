From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 23 Nov 2008 23:10:30 -0500
Subject: [PATCH] (5/11) vg_read error returns, part 1
In-Reply-To: <87fxme3qo0.fsf@eriador.mornfall.net>
References: <87fxme3qo0.fsf@eriador.mornfall.net>
Message-ID: <1227499830.6608.32.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Thu, 2008-10-30 at 19:04 +0100, Petr Rockai wrote:
> diff -rN -p -u old-lvmlib-b/lib/metadata/metadata.c
> new-lvmlib-b/lib/metadata/metadata.c
> --- old-lvmlib-b/lib/metadata/metadata.c        2008-10-30
> 18:17:02.505837415 +0100
> +++ new-lvmlib-b/lib/metadata/metadata.c        2008-10-30
> 18:17:02.577837348 +0100
> @@ -2371,42 +2371,66 @@ int pv_analyze(struct cmd_context *cmd, 
>   * 0 - fail
>   * 1 - success
>   */
> -int vg_check_status(const struct volume_group *vg, uint32_t status)
> +static int _vg_check_status(const struct volume_group *vg, uint32_t
> status)
>  {
> +       uint32_t ret = 0;
>         if ((status & CLUSTERED) &&
>             (vg_is_clustered(vg)) && !locking_is_clustered() &&
>             !lockingfailed()) {
>                 log_error("Skipping clustered volume group %s",
> vg->name);
> -               return 0;
> +               ret |= FAILED_CLUSTERED;
> 

Need uint32_t for function return value consistency with internal
variable.  Probably want to move/fix the comment as well.


