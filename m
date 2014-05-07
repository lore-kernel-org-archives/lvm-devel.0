From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 7 May 2014 08:33:42 -0400 (EDT)
Subject: master - coverity: check for profile
In-Reply-To: <20140507121858.B603F607BC@fedorahosted.org>
References: <20140507121858.B603F607BC@fedorahosted.org>
Message-ID: <1880427768.1808643.1399466022604.JavaMail.zimbra@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/07/2014 02:19 PM, Zdenek Kabelac wrote:> -	str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile);
> +	if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
> +		log_error(INTERNAL_ERROR "Cannot find profile.");
> +		return 0;
> +	}
>  
>  	if (!strcasecmp(str, "generic"))
>  		chunk_size = DEFAULT_THIN_POOL_CHUNK_SIZE;
> diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
> index 78231a2..c1c90b4 100644
> --- a/lib/metadata/thin_manip.c
> +++ b/lib/metadata/thin_manip.c
> @@ -375,7 +375,10 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
>  
>  	if (!(passed_args & PASS_ARG_CHUNK_SIZE)) {
>  		if (!(*chunk_size = find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, profile) * 2)) {
> -			str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile);
> +			if (!(str = find_config_tree_str(cmd, allocation_thin_pool_chunk_size_policy_CFG, profile))) {
> +				log_error(INTERNAL_ERROR "Could not find profile.");
> +				return 0;
> +			}
>  			if (!strcasecmp(str, "generic"))
>  				*chunk_size_calc_method = THIN_CHUNK_SIZE_CALC_METHOD_GENERIC;
>  			else if (!strcasecmp(str, "performance"))
> @@ -397,7 +400,10 @@ int update_profilable_pool_params(struct cmd_context *cmd, struct profile *profi
>  	}
>  
>  	if (!(passed_args & PASS_ARG_DISCARDS)) {
> -		str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile);
> +		if (!(str = find_config_tree_str(cmd, allocation_thin_pool_discards_CFG, profile))) {
> +			log_error(INTERNAL_ERROR "Could not find profile.");
> +			return 0;
> +		}


Well, the message is not quite correct since it's not just about profile.
The actual sequence here when looking for the config value is:
 1 - --config
 2 - --profile
 3 - profile directly attached to VG/LV
 4 - lvm.conf (including tag configs)
 5 - default

(And default is always defined for thin_pool_chunk_size_policy and thin_pool_discards.
So actually, the error path there is never hit in real...)

-- 
Peter


