From: Petr Rockai <prockai@redhat.com>
Date: Mon, 06 Apr 2009 17:04:08 +0200
Subject: [PATCH 1/6] vg mempool: print pool leaks (debug helper)
In-Reply-To: <49D9BDF5.6010205@redhat.com> (Milan Broz's message of "Mon, 06
	Apr 2009 10:31:49 +0200")
References: <49D9BDF5.6010205@redhat.com>
Message-ID: <87r605bz87.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Signed-off-by: Milan Broz <mbroz@redhat.com>
One points needs to be kept in mind wrt. this patch -- it introduces a global
list, making pool creation/destruction thread-unsafe (this *right now* does not
hurt anyone, I believe, but it might so in future). There are some minor
comments inline in the patch, see below.

Other than that,

Acked-By: Petr Ro?kai <prockai@redhat.com>

> diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
> index fe86494..18c2d14 100644
> --- a/libdm/ioctl/libdm-iface.c
> +++ b/libdm/ioctl/libdm-iface.c
> @@ -1817,12 +1817,15 @@ void dm_lib_release(void)
>  	update_devs();
>  }
>  
> +void dm_pools_dump(void);
A better name might be in place. (dm_pools_print_leaks?
dm_pools_announce_leaks? dm_pools_check_leaks? pick your favourite...)

> +
>  void dm_lib_exit(void)
>  {
>  	dm_lib_release();
>  	if (_dm_bitset)
>  		dm_bitset_destroy(_dm_bitset);
>  	_dm_bitset = NULL;
> +	dm_pools_dump();
>  	dm_dump_memory();
>  	_version_ok = 1;
>  	_version_checked = 0;
> diff --git a/libdm/mm/pool-debug.c b/libdm/mm/pool-debug.c
> index 1c3d999..f775dea 100644
> --- a/libdm/mm/pool-debug.c
> +++ b/libdm/mm/pool-debug.c
> @@ -30,7 +30,9 @@ typedef struct {
>  } pool_stats;
>  
>  struct dm_pool {
> +	struct dm_list list;
>  	const char *name;
> +	void *orig_pool;	/* to pair it with first allocation call */
>  
>  	int begun;
>  	struct block *object;
> @@ -65,10 +67,13 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
>  	mem->stats.bytes = 0;
>  	mem->stats.maxbytes = 0;
>  
> +	mem->orig_pool = mem;
> +
>  #ifdef DEBUG_POOL
>  	log_debug("Created mempool %s", name);
>  #endif
>  
> +	dm_list_add(&_dm_pools, &mem->list);
>  	return mem;
>  }
>  
> @@ -103,6 +108,7 @@ void dm_pool_destroy(struct dm_pool *p)
>  {
>  	_pool_stats(p, "Destroying");
>  	_free_blocks(p, p->blocks);
> +	dm_list_del(&p->list);
>  	dm_free(p);
>  }
>  
> diff --git a/libdm/mm/pool-fast.c b/libdm/mm/pool-fast.c
> index 9d9f808..d34cd9a 100644
> --- a/libdm/mm/pool-fast.c
> +++ b/libdm/mm/pool-fast.c
> @@ -21,6 +21,7 @@ struct chunk {
>  };
>  
>  struct dm_pool {
> +	struct dm_list list;
>  	struct chunk *chunk, *spare_chunk;	/* spare_chunk is a one entry free
>  						   list to stop 'bobbling' */
>  	size_t chunk_size;
> @@ -51,6 +52,7 @@ struct dm_pool *dm_pool_create(const char *name, size_t chunk_hint)
>  	while (new_size < p->chunk_size)
>  		new_size <<= 1;
>  	p->chunk_size = new_size;
> +	dm_list_add(&_dm_pools, &p->list);
>  	return p;
>  }
>  
> @@ -65,6 +67,7 @@ void dm_pool_destroy(struct dm_pool *p)
>  		c = pr;
>  	}
>  
> +	dm_list_del(&p->list);
>  	dm_free(p);
>  }
>  
> diff --git a/libdm/mm/pool.c b/libdm/mm/pool.c
> index 3528a91..13c1c06 100644
> --- a/libdm/mm/pool.c
> +++ b/libdm/mm/pool.c
> @@ -15,6 +15,9 @@
>  
>  #include "dmlib.h"
>  
> +static DM_LIST_INIT(_dm_pools);
> +void dm_pools_dump(void);
> +
>  #ifdef DEBUG_POOL
>  #include "pool-debug.c"
>  #else
> @@ -52,3 +55,22 @@ void *dm_pool_zalloc(struct dm_pool *p, size_t s)
>  
>  	return ptr;
>  }
> +
> +void dm_pools_dump(void)
> +{
> +	struct dm_pool *p;
> +
> +	if (dm_list_empty(&_dm_pools))
> +		return;
> +
> +	log_error("You have a pool leak:");
> +	dm_list_iterate_items(p, &_dm_pools) {
> +#ifdef DEBUG_POOL
> +		log_error(" [%lx] %s (%u bytes)",
> +			  (unsigned long)p->orig_pool,
> +			  p->name, p->stats.bytes);
> +#else
> +		log_error(" [%lx]", (unsigned long)p);
> +#endif
Would "%p" format make more sense instead of %lx and the cast here? I believe
unsigned long is not guaranteed to be of the same size as a pointer.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


