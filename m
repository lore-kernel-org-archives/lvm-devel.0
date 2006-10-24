From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 23 Oct 2006 20:17:40 -0400
Subject: LVM2 ./WHATS_NEW man/lvchange.8 tools/args.h t ...
In-Reply-To: <20061023230356.28539.qmail@sourceware.org>
References: <20061023230356.28539.qmail@sourceware.org>
Message-ID: <453D5BA4.9000107@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Jonathan, Alasdair,

Thanks for updating forcesync patch.
I have 2 comments, one for man page and the other for a minor bug.

agk at sourceware.org wrote:
> +.I \-\-forcesync
> +This option only make sense if the logical volume being operated
> +on is a mirrored logical volume.  This option is used to
> +resynchronize the devices in a mirrored logical volume.  Since
> +resynchronization can take considerable time and resources, you
> +should consider using this option only if you have reason to
> +believe that the devices in your mirror are no longer the same.
> +.TP

I think it's better to emphasize that
  - resynchronization is generally done automatically based on
    persistent mirror log or upon activation if there is no log.
  - resynchronization is done in background, so the completion of
    'lvchange --forcesync' doesn't mean the devices are resynchronized.

So how about something like this?

This option only makes sense if the logical volume being operated
on is a mirrored logical volume.  This option is used to reset
the sync status and start resynchronization of the devices in a
mirrored logical volume. Please note that generally resynchronization
is done automatically based on persistent log or upon every activation
in case of in-memory log. Since resynchronization can take considerable
time and resources, you should consider using this option only if
you have reason to believe that the devices in your mirror are no
longer the same.

> +static int lvchange_forcesync(struct cmd_context *cmd,
> +			      struct logical_volume *lv)
> +{
> +	int active = 0;
...
> +
> +	if (lv_info(cmd, lv, &info, 1)) {
> +		if (info.open_count) {
> +			log_error("Can't resync open logical volume \"%s\"",
> +				  lv->name);
> +			return ECMD_FAILED;
> +		}
> +
> +		if (info.exists && !arg_count(cmd, yes_ARG)) {
> +			if (yes_no_prompt("Do you really want to deactivate "
> +					  "logical volume %s to resync it? [y/n]: ",
> +					  lv->name) == 'n') {
> +				log_print("Logical volume \"%s\" not resynced",
> +					  lv->name);
> +				return ECMD_FAILED;
> +			}
> +		}
> +
> +		active = 1;
> +	}

This "active = 1" should be set only if info.exists is true,
because lv_info() succeeds even if the lv is not activated.


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


