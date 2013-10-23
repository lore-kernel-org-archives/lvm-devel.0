From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Oct 2013 09:52:07 +0200
Subject: [PATCH]: Mirror: warn when activating mirror and !ignore_lvm_mirrors
In-Reply-To: <1382485318.19061.6.camel@f16>
References: <1382394852.4860.4.camel@f16> <1382485318.19061.6.camel@f16>
Message-ID: <52678027.2080703@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 23.10.2013 01:41, Jonathan Brassow napsal(a):
> Not sure if I care for the static variable, but I don't want it printed
> for every mirror on every command that activates...
>
>   brassow
>
>
> Mirror: Print warning on activation if mirrors exists and !ignore_lvm_mirrors
>
> Print a warning if mirrors are present and config file settings indicate
> that they can be scanned for labels.  (A process that has the potential
> to block indefinitely if it happens just after a failure.)
>
> Index: lvm2/lib/activate/activate.c
> ===================================================================
> --- lvm2.orig/lib/activate/activate.c
> +++ lvm2/lib/activate/activate.c
> @@ -1077,9 +1077,18 @@ static int _lv_open_count(struct cmd_con
>
>   static int _lv_activate_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
>   {
> +	static int mirror_warning_printed = 0;
>   	int r;
>   	struct dev_manager *dm;
>
> +	if (lv_is_mirrored(lv) && !lv_is_raid(lv) &&
> +	    !mirror_warning_printed && !ignore_lvm_mirrors()) {
> +		log_print("Scanning mirrors for LVM labels is enabled.\n"
> +			  "  It is possible for this to cause I/O hangs and stuck LVM processes.\n"
> +			  "  See 'ignore_lvm_mirrors' in the LVM configuation file for details.");
> +		mirror_warning_printed = 1;
> +	}
> +
>   	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))

We should probably introduce    log_print_once()
(Just like we have  log_error_once())

Zdenek



