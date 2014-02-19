From: Marian Csontos <mcsontos@redhat.com>
Date: Wed, 19 Feb 2014 07:54:58 +0100
Subject: master - cleanup: move verbose message to lv_activation_skip
In-Reply-To: <20140218202823.26E88602B0@fedorahosted.org>
References: <20140218202823.26E88602B0@fedorahosted.org>
Message-ID: <53045542.8060108@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/18/2014 09:28 PM, Zdenek Kabelac wrote:
> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fb519c35bbfae24a26346faf2b90d2a4189e8562
> Commit:        fb519c35bbfae24a26346faf2b90d2a4189e8562
> Parent:        fdcd95a3b3dd92ed219571467fdc235e1a6cb0b6
> Author:        Zdenek Kabelac <zkabelac@redhat.com>
> AuthorDate:    Tue Feb 18 20:49:32 2014 +0100
> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
> CommitterDate: Tue Feb 18 20:49:32 2014 +0100
>
> cleanup: move verbose message to lv_activation_skip
>
> Simplify code and put verbose message into a single place.
> ---
>   lib/metadata/lv_manip.c |   12 ++++++------
>   tools/lvchange.c        |    5 +----
>   tools/vgchange.c        |    5 +----
>   3 files changed, 8 insertions(+), 14 deletions(-)
>
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index 6b4c9a8..c2cc590 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -5675,14 +5675,14 @@ void lv_set_activation_skip(struct logical_volume *lv, int override_default,
>   int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
>   		      int override_lv_skip_flag, int skip)
>   {
> -	/* Do not skip deactivation! */
> -	if ((activate == CHANGE_AN) || (activate == CHANGE_ALN))
> +	if (!(lv->status & LV_ACTIVATION_SKIP) ||
> +	    !is_change_activating(activate) || /* Do not skip deactivation */
> +	    (override_lv_skip_flag && !skip))
>   		return 0;
>
> -	if (override_lv_skip_flag)
> -		return skip;
> -
> -	return (lv->status & LV_ACTIVATION_SKIP) ? 1 : 0;
> +	log_verbose("ACTIVATON_SKIP flag set for LV %s/%s, skipping activation.",
> +		    lv->vg->name, lv->name);
> +	return 1;

I am not convinced this is pure "cleanup".
When `!(lv->status & LV_ACTIVATION_SKIP)` this returns 0 and ignores 
`override_lv_skip_flag == 1 && skip == 1`.

-- Martian


>   }
>
>   /* Greatest common divisor */
> diff --git a/tools/lvchange.c b/tools/lvchange.c
> index a0e350f..5b6da56 100644
> --- a/tools/lvchange.c
> +++ b/tools/lvchange.c
> @@ -215,11 +215,8 @@ static int _lvchange_activate(struct cmd_context *cmd, struct logical_volume *lv
>
>   	activate = (activation_change_t) arg_uint_value(cmd, activate_ARG, CHANGE_AY);
>
> -	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0)) {
> -		log_verbose("ACTIVATON_SKIP flag set for LV %s/%s, skipping activation.",
> -			    lv->vg->name, lv->name);
> +	if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0))
>   		return 1;
> -	}
>
>   	if (lv_is_cow(lv) && !lv_is_virtual_origin(origin_from_cow(lv)))
>   		lv = origin_from_cow(lv);
> diff --git a/tools/vgchange.c b/tools/vgchange.c
> index af4b002..d862ec2 100644
> --- a/tools/vgchange.c
> +++ b/tools/vgchange.c
> @@ -121,11 +121,8 @@ static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
>   		    ((lv->status & PVMOVE) ))
>   			continue;
>
> -		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0)) {
> -			log_verbose("ACTIVATION_SKIP flag set for LV %s/%s, skipping activation.",
> -				    lv->vg->name, lv->name);
> +		if (lv_activation_skip(lv, activate, arg_count(cmd, ignoreactivationskip_ARG), 0))
>   			continue;
> -		}
>
>   		if ((activate == CHANGE_AAY) &&
>   		    !lv_passes_auto_activation_filter(cmd, lv))
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
>


