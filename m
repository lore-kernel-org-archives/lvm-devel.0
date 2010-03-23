From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 23 Mar 2010 11:30:52 -0400
Subject: improve dmeventd monitoring option processing
In-Reply-To: <1268276705-29311-1-git-send-email-snitzer@redhat.com>
References: <1268276705-29311-1-git-send-email-snitzer@redhat.com>
Message-ID: <20100323153052.GA16552@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair,

This patch hasn't been commited yet.  The duplicate code in
{vg,lv}change.c is comparable to what would be need to enable monitoring
control in lvcreate too.

Should I put that code in toollib and enable its use in lvcreate.c too?

Also, is it reasonable to have clvmd consult lvm.conf like I've done?

Mike

On Wed, Mar 10 2010 at 10:05pm -0500,
Mike Snitzer <snitzer@redhat.com> wrote:

> Add "monitoring" option to "dmeventd" section of lvm.conf
> 
> Have clvmd consult the lvm.conf "dmeventd/monitoring" too.
> 
> Error out when both --monitor and --ignoremonitoring are provided.
> 
> Clarify that '--monitor' controls the start and stop of monitoring in
> the {vg,lv}change man pages.
> 
> NOTE: should this identical code in {vg,lv}change.c be split out into
> toollib.c?
> 
> Signed-off-by: Mike Snitzer <snitzer@redhat.com>
> ---
>  daemons/clvmd/lvm-functions.c |    8 ++++++--
>  doc/example.conf              |    5 +++++
>  man/lvchange.8.in             |    3 +--
>  man/vgchange.8.in             |    3 +--
>  tools/lvchange.c              |   21 +++++++++++++++++----
>  tools/vgchange.c              |   21 +++++++++++++++++----
>  6 files changed, 47 insertions(+), 14 deletions(-)
> 
> diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
> index 02d401b..5d4b867 100644
> --- a/daemons/clvmd/lvm-functions.c
> +++ b/daemons/clvmd/lvm-functions.c
> @@ -542,8 +542,12 @@ int do_lock_lv(unsigned char command, unsigned char lock_flags, char *resource)
>  	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
>  		init_mirror_in_sync(0);
>  
> -	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE))
> -		init_dmeventd_monitor(DEFAULT_DMEVENTD_MONITOR);
> +	if (!(lock_flags & LCK_DMEVENTD_MONITOR_MODE)) {
> +		int dmeventd_mode =
> +			find_config_tree_bool(cmd, "dmeventd/monitoring",
> +					      DEFAULT_DMEVENTD_MONITOR);
> +		init_dmeventd_monitor(dmeventd_mode);
> +	}
>  
>  	cmd->partial_activation = 0;
>  
> diff --git a/doc/example.conf b/doc/example.conf
> index 511e20c..2f9d5ee 100644
> --- a/doc/example.conf
> +++ b/doc/example.conf
> @@ -469,6 +469,11 @@ activation {
>  # Event daemon
>  #
>  dmeventd {
> +    # Monitoring is enabled by default when using vgchange or
> +    # lvchange.  Set to 0 to disable monitoring or use the
> +    # --ignoremonitoring option.
> +    monitoring = 1
> +
>      # mirror_library is the library used when monitoring a mirror device.
>      #
>      # "libdevmapper-event-lvm2mirror.so" attempts to recover from
> diff --git a/man/lvchange.8.in b/man/lvchange.8.in
> index 08a83c4..99f9bf3 100644
> --- a/man/lvchange.8.in
> +++ b/man/lvchange.8.in
> @@ -56,8 +56,7 @@ of your data.
>  Set the minor number.
>  .TP
>  .I \-\-monitor y|n
> -Controls whether or not a mirrored logical volume is monitored by
> -dmeventd, if it is installed.
> +Start or stop monitoring a logical volume, if dmeventd is installed.
>  If a device used by a monitored mirror reports an I/O error,
>  the failure is handled according to 
>  \fBmirror_image_fault_policy\fP and \fBmirror_log_fault_policy\fP
> diff --git a/man/vgchange.8.in b/man/vgchange.8.in
> index 5013c1e..e01158a 100644
> --- a/man/vgchange.8.in
> +++ b/man/vgchange.8.in
> @@ -78,8 +78,7 @@ are not marked as clustered.
>  Generate new random UUID for specified Volume Groups.
>  .TP
>  .BR \-\-monitor " " { y | n }
> -Controls whether or not a mirrored logical volume is monitored by
> -dmeventd, if it is installed.
> +Start or stop monitoring a logical volume, if dmeventd is installed.
>  If a device used by a monitored mirror reports an I/O error,
>  the failure is handled according to 
>  .BR mirror_image_fault_policy
> diff --git a/tools/lvchange.c b/tools/lvchange.c
> index 2d7955e..711217f 100644
> --- a/tools/lvchange.c
> +++ b/tools/lvchange.c
> @@ -518,7 +518,7 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
>  			   void *handle __attribute((unused)))
>  {
>  	int doit = 0, docmds = 0;
> -	int archived = 0;
> +	int dmeventd_mode, archived = 0;
>  	struct logical_volume *origin;
>  
>  	if (!(lv->vg->status & LVM_WRITE) &&
> @@ -575,9 +575,22 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
>  		return ECMD_FAILED;
>  	}
>  
> -	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
> -					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
> -					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
> +	if (arg_count(cmd, monitor_ARG) &&
> +	    arg_count(cmd, ignoremonitoring_ARG)) {
> +		log_error("Conflicting monitor and ignoremonitoring options");
> +		return ECMD_FAILED;
> +	}
> +
> +	dmeventd_mode = DEFAULT_DMEVENTD_MONITOR;
> +	if (arg_count(cmd, monitor_ARG))
> +		dmeventd_mode = arg_int_value(cmd, monitor_ARG,
> +					      DEFAULT_DMEVENTD_MONITOR);
> +	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
> +		 !find_config_tree_bool(cmd, "dmeventd/monitoring",
> +					DEFAULT_DMEVENTD_MONITOR))
> +		dmeventd_mode = DMEVENTD_MONITOR_IGNORE;
> +
> +	init_dmeventd_monitor(dmeventd_mode);
>  
>  	/*
>  	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
> diff --git a/tools/vgchange.c b/tools/vgchange.c
> index 6d869f9..f343584 100644
> --- a/tools/vgchange.c
> +++ b/tools/vgchange.c
> @@ -522,16 +522,29 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
>  			   struct volume_group *vg,
>  			   void *handle __attribute((unused)))
>  {
> -	int r = ECMD_FAILED;
> +	int dmeventd_mode, r = ECMD_FAILED;
>  
>  	if (vg_is_exported(vg)) {
>  		log_error("Volume group \"%s\" is exported", vg_name);
>  		return ECMD_FAILED;
>  	}
>  
> -	init_dmeventd_monitor(arg_int_value(cmd, monitor_ARG,
> -					    (is_static() || arg_count(cmd, ignoremonitoring_ARG)) ?
> -					    DMEVENTD_MONITOR_IGNORE : DEFAULT_DMEVENTD_MONITOR));
> +	if (arg_count(cmd, monitor_ARG) &&
> +	    arg_count(cmd, ignoremonitoring_ARG)) {
> +		log_error("Conflicting monitor and ignoremonitoring options");
> +		return ECMD_FAILED;
> +	}
> +
> +	dmeventd_mode = DEFAULT_DMEVENTD_MONITOR;
> +	if (arg_count(cmd, monitor_ARG))
> +		dmeventd_mode = arg_int_value(cmd, monitor_ARG,
> +					      DEFAULT_DMEVENTD_MONITOR);
> +	else if (is_static() || arg_count(cmd, ignoremonitoring_ARG) ||
> +		 !find_config_tree_bool(cmd, "dmeventd/monitoring",
> +					DEFAULT_DMEVENTD_MONITOR))
> +		dmeventd_mode = DMEVENTD_MONITOR_IGNORE;
> +
> +	init_dmeventd_monitor(dmeventd_mode);
>  
>  	/*
>  	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


