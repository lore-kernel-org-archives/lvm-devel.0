From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 15 Mar 2013 09:17:01 +0100
Subject: [PATCH 4/5] lvm2app: Move core lv re-size code (v2)
In-Reply-To: <1363284884-20506-4-git-send-email-tasleson@redhat.com>
References: <1363284884-20506-1-git-send-email-tasleson@redhat.com>
	<1363284884-20506-4-git-send-email-tasleson@redhat.com>
Message-ID: <5142D8FD.5000107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 14.3.2013 19:14, Tony Asleson napsal(a):
> Moved to allow use from command line and for library use.
>
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>   lib/metadata/lv_manip.c          | 734 +++++++++++++++++++++++++++++++++++++
>   lib/metadata/metadata-exported.h |  46 +++
>   tools/lvresize.c                 | 773 +--------------------------------------
>   3 files changed, 781 insertions(+), 772 deletions(-)
>
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
> index ad8160e..a6825ed 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -27,6 +27,8 @@
>   #include "activate.h"
>   #include "str_list.h"
>   #include "defaults.h"
> +#include "lvm-exec.h"
> +#include "errors.h"


hmmm - now the 'error.h' change.

So far nothing in the /lib  was using this. The API here is - 1 Ok, 0 False.


> +static int _adjust_policy_params(struct cmd_context *cmd,
> +				 struct logical_volume *lv, struct lvresize_params *lp)
> +{
> +	percent_t percent;
> +	int policy_threshold, policy_amount;
> +
> +	if (lv_is_thin_pool(lv)) {
> +		policy_threshold =
> +			find_config_tree_int(cmd, activation_thin_pool_autoextend_threshold_CFG) * PERCENT_1;
> +		policy_amount =
> +			find_config_tree_int(cmd, activation_thin_pool_autoextend_percent_CFG);
> +		if (!policy_amount && policy_threshold < PERCENT_100)
> +                        return 0;
> +	} else {
> +		policy_threshold =
> +			find_config_tree_int(cmd, activation_snapshot_autoextend_threshold_CFG) * PERCENT_1;
> +		policy_amount =
> +			find_config_tree_int(cmd, activation_snapshot_autoextend_percent_CFG);
> +	}
> +
> +	if (policy_threshold >= PERCENT_100)
> +		return 1; /* nothing to do */
> +
> +	if (lv_is_thin_pool(lv)) {
> +		if (!lv_thin_pool_percent(lv, 1, &percent))
> +			return_0;
> +		if (percent > policy_threshold) {
> +			/* FIXME: metadata resize support missing */
> +			log_error("Resize for %s/%s is not yet supported.",
> +				  lp->vg_name, lp->lv_name);
> +			return ECMD_FAILED;
> +		}


However now the code inside /lib  would have start to generate errors not 
really related to current /lib functionality - i.e.  command failure,


> +
> +	if (lp->ac_stripesize &&
> +	    !_validate_stripesize(cmd, vg, lp))
> +		return EINVALID_CMD_LINE;
> +


command line args parsing problems and many other pieces which so far belongs 
to /tools.   So the plain code move doesn't work here.

The issue is of course bigger - since the current   1/0  internal lvm logic 
doesn't support well the public API where you really want to know the 'reason' 
for failure - which ATM is just logged with log_error() deeply from 
liblvm/libdm code.


We need here some decision  -  I guess - the best would be probably to define
the list of error codes we want to expose to the lvm2api users first.

Should the API user know about dm errors?
Parameter errors ?
Memory errors ?
Internal errors ?

Zdenek


