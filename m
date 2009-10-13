From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Mon, 12 Oct 2009 18:48:20 -0700
Subject: Re: [PATCH 2 of 10] LVM: make log_area a list
In-Reply-To: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
References: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
Message-ID: <20091013014820.GA27349@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow [jbrassow at redhat.com] wrote:
> Patch name: lvm-make-log_area-a-list.patch
> 
> The 'alloc_handle' structure only has space for one log_area.
> We change that to a list to allow an arbitrary number of
> log areas.
> 
> RFC: Jonathan Brassow <jbrassow@redhat.com>
> 
> @@ -1061,10 +1065,14 @@ static int _find_parallel_space(struct a
>  				continue;	/* Next PV */
>  
>  			if (alloc != ALLOC_ANYWHERE) {
> -				/* Don't allocate onto the log pv */
> -				if (ah->log_count &&
> -				    pvm->pv == ah->log_area.pv)
> -					continue;	/* Next PV */
> +				/* Don't allocate onto the log pvs */
> +				dm_list_iterate_items(aa, &ah->log_areas)
> +					if (pvm->pv == aa->pv)
> +						skip = 1;

                                       You can 'break' soon after setting skip.

> @@ -1199,6 +1208,7 @@ static int _allocate(struct alloc_handle
>  	struct dm_list *pvms;
>  	uint32_t areas_size;
>  	alloc_policy_t alloc;
> +	struct alloced_area *aa;
>  
>  	if (allocated >= new_extents && !ah->log_count) {
>  		log_error("_allocate called with no work to do!");
> @@ -1264,12 +1274,13 @@ static int _allocate(struct alloc_handle
>  		goto out;
>  	}
>  
> -	if (ah->log_count && !ah->log_area.len) {
> -		log_error("Insufficient extents for log allocation "
> -			  "for logical volume %s.",
> -			  lv ? lv->name : "");
> -		goto out;
> -	}
> +	dm_list_iterate_items(aa, &ah->log_areas)
> +		if (ah->log_count && !aa->len) {

ah->log_count can be checked outside of the list iterate.

> +			log_error("Insufficient extents for log allocation "
> +				  "for logical volume %s.",
> +				  lv ? lv->name : "");
> +			goto out;
> +		}
>  int lv_add_log_segment(struct alloc_handle *ah, struct logical_volume *log_lv)
>  {
>  	struct lv_segment *seg;
> +	struct alloced_area *log_area;
> +
> +	dm_list_iterate_items(log_area, &ah->log_areas)
> +		break;

        Using the list iterator to get the first element looks odd!
	Should we use dm_list_first and dm_list_item? Or just have
	dm_list_first_item()???


