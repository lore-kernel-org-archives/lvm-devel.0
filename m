From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 22 Aug 2017 12:32:56 +0200
Subject: [PATCH] raid: stripes option is not allowed with RAID1
In-Reply-To: <1503395925-10213-1-git-send-email-mcsontos@redhat.com>
References: <1503395925-10213-1-git-send-email-mcsontos@redhat.com>
Message-ID: <a5130252-1537-e34b-37d7-218bacaec67f@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/22/2017 11:58 AM, Marian Csontos wrote:
> ---
>   tools/lvconvert.c | 5 +++--
>   1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/lvconvert.c b/tools/lvconvert.c
> index 94dee9d..a364103 100644
> --- a/tools/lvconvert.c
> +++ b/tools/lvconvert.c
> @@ -209,10 +209,11 @@ static int _read_params(struct cmd_context *cmd, struct lvconvert_params *lp)
>   		lp->type_str = SEG_TYPE_NAME_STRIPED;
>   
>   	if ((arg_is_set(cmd, stripes_long_ARG) || arg_is_set(cmd, stripesize_ARG)) &&
> -	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) || _striped_type_requested(lp->type_str) ||
> +	    !(_mirror_or_raid_type_requested(cmd, lp->type_str) && strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) ||
> +              _striped_type_requested(lp->type_str) ||
>   	      _raid0_type_requested(lp->type_str) || arg_is_set(cmd, thinpool_ARG))) {
>   		log_error("--stripes or --stripesize argument is only valid "
> -			  "with --mirrors/--type mirror/--type raid*/--type striped/--type linear, --repair and --thinpool");
> +			  "with --mirrors/--type mirror/--type raid{4,5,6,10}/--type striped/--type linear, --repair and --thinpool");
>   		return 0;
>   	}
>   
> 

NAK. I thought this should be as easy as this. Turns out it is not. Test 
is failing.


