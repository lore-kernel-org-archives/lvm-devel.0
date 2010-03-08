From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 08 Mar 2010 00:33:31 -0500
Subject: [PATCH 10 of 10] LVM: rework lvconvert_mirrors
In-Reply-To: <201003052359.o25Nxeg5012728@hydrogen.msp.redhat.com>
References: <201003052359.o25Nxeg5012728@hydrogen.msp.redhat.com>
Message-ID: <4B948C2B.6030702@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
> +static int _lvconvert_mirrors_parse_params(struct cmd_context *cmd,
> +					   struct logical_volume *lv,
> +					   struct lvconvert_params *lp,
> +					   uint32_t *old_mimage_count,
> +					   uint32_t *old_log_count,
> +					   uint32_t *new_mimage_count,
> +					   uint32_t *new_log_count)
> +{
...
> +
> +	/*
> +	 * Adjust log type
> +	 */
> +	*new_log_count = *old_log_count;
> +	if (!arg_count(cmd, corelog_ARG) && !arg_count(cmd, mirrorlog_ARG))
> +		return 1;
> +
> +	if (arg_count(cmd, corelog_ARG))
> +		*new_log_count = 0;
> +
> +	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
> +				  !*new_log_count ? "core" : DEFAULT_MIRRORLOG);
> +
> +	if (strcmp("core", mirrorlog) && !*new_log_count) {
> +		log_error("--mirrorlog and --corelog are incompatible");
> +		return 0;
> +	}

This check should be done after *new_log_count is properly set. At this point,
*new_log_count hasn't been set yet and *new_log_count could be "0" even if
the new log type is "disk" or "mirrored."

> +	if (!strcmp("mirrored", mirrorlog))
> +		*new_log_count = 2;
> +	else if (!strcmp("disk", mirrorlog))
> +		*new_log_count = 1;
> +	else if (!strcmp("core", mirrorlog))
> +		*new_log_count = 0;
> +	else {
> +		log_error("Unknown mirrorlog type: %s", mirrorlog);
> +		return 0;
> +	}

        *** I think the above check should here ***

You can reproduce this by converting a "core" log to a "disk" or "mirrored"
log.

Thanks,
Taka



