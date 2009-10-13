From: malahal@us.ibm.com <malahal@us.ibm.com>
Date: Mon, 12 Oct 2009 18:55:43 -0700
Subject: Re: [PATCH 3 of 10] LVM: build log_area list
In-Reply-To: <200910082118.n98LIkFp014360@hydrogen.msp.redhat.com>
References: <200910082118.n98LIkFp014360@hydrogen.msp.redhat.com>
Message-ID: <20091013015543.GB27349@us.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow [jbrassow at redhat.com] wrote:
> Patch name: lvm-build-log_area-list.patch
> 
> Now that we have change the allocation handle structure to be
> able to store a list of log areas, fill them in and utilize
> them based on the 'log_count' parameter.  (log_count will
> be generalized in subsequent patches, but it is still just
> '1' or '0' for now... meaning nothing has changed at this
> point.)
> 
> RFC: Jonathan Brassow <jbrassow@redhat.com>
> @@ -763,12 +763,14 @@ static int _alloc_parallel_area(struct a
>  	for (s = 0; s < ah->area_count; s++)
>  		consume_pv_area(areas[s], area_len);
>  
> -	if (log_area) {
> -		aa[s].pv = log_area->map->pv;
> -		aa[s].pe = log_area->start;
> +	for (i = 0, s = ah->area_count;
> +	     log_areas && (s < ah->area_count + ah->log_count);

log_areas should be set based on log_count, right? Can't we just remove
the log_areas check?

> +	     s++, i++) {
> +		aa[s].pv = log_areas[i]->map->pv;
> +		aa[s].pe = log_areas[i]->start;
>  		aa[s].len = log_len;
>  		dm_list_add(&ah->log_areas, &aa[s].list);
> -		consume_pv_area(log_area, log_len);
> +		consume_pv_area(log_areas[i], log_len);
>  	}
>  
>  	*ix += area_len * ah->area_multiple;


