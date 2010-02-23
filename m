From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 23 Feb 2010 15:39:02 -0500
Subject: [PATCH 1/2] Always query device by uuid only.
In-Reply-To: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
References: <1266932816-5621-1-git-send-email-mbroz@redhat.com>
Message-ID: <20100223203902.GA31973@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 23 2010 at  8:46am -0500,
Milan Broz <mbroz@redhat.com> wrote:

> lvm2 devices have always UUID set even if imported from lvm1 metadata.
> 
> Patch removes name argument from dev_manager_info call and converts
> all activation related calls to use query by UUID.
> 
> Also it simplifies mknode call (which is the only user on mknodes parameter).

Looks good, I have few questions though.

> diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
> index bbf95a3..84f94ff 100644
> --- a/lib/activate/dev_manager.c
> +++ b/lib/activate/dev_manager.c
> @@ -235,20 +237,29 @@ static int _info_by_dev(uint32_t major, uint32_t minor, struct dm_info *info)
>  	return _info_run(NULL, NULL, info, NULL, 0, 0, 0, major, minor);
>  }
>  
> -int dev_manager_info(struct dm_pool *mem, const char *name,
> -		     const struct logical_volume *lv, int with_mknodes,
> -		     int with_open_count, int with_read_ahead,
> +int dev_manager_info(struct dm_pool *mem, const struct logical_volume *lv,
> +		     int with_mknodes, int with_open_count, int with_read_ahead,
>  		     struct dm_info *info, uint32_t *read_ahead)
>  {
> -	const char *dlid;
> +	const char *dlid, *name;
> +	int r;
> +
> +	if (!(name = build_dm_name(mem, lv->vg->name, lv->name, NULL))) {
> +		log_error("name build failed for %s", lv->name);
> +		return 0;
> +	}
>  
>  	if (!(dlid = _build_dlid(mem, lv->lvid.s, NULL))) {
>  		log_error("dlid build failed for %s", lv->name);
>  		return 0;
>  	}
>  
> -	return _info(name, dlid, with_mknodes, with_open_count, with_read_ahead,
> -		     info, read_ahead);
> +	log_debug("Getting device info for %s", name);
> +	r = _info(NULL, dlid, with_mknodes, with_open_count,
> +		  with_read_ahead, info, read_ahead);
> +
> +	dm_pool_free(mem, (char*)name);
> +	return r;
>  }

So the debugging benefit of having 'name' here outweighs the (small)
cost of build_dm_name/dm_pool_free?  Really not a big deal but figured
I'd ask.

Also, _add_dev_to_dtree() is the only remaining caller of _info() that
passes 'name'.  Passing a NULL 'name' to _info() from _add_dev_to_dtree()
still allows the testsuite to pass.  What are the benefit(s) of
preserving _info()'s info-by-name fallback for _add_dev_to_dtree()?

Mike


