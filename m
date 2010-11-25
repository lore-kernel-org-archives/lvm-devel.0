From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 14:28:18 +0100
Subject: [PATCH 05/11] Add pv_initialise to format_handler interface.
In-Reply-To: <1290115945-27419-6-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
	<1290115945-27419-6-git-send-email-prajnoha@redhat.com>
Message-ID: <4CEE6472.5020803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.11.2010 22:32, Peter Rajnoha napsal(a):

> diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
> index bc58744..38cb34d 100644
> --- a/lib/format1/disk-rep.c
> +++ b/lib/format1/disk-rep.c
> @@ -337,6 +337,13 @@ static void __update_lvmcache(const struct format_type *fmt,
>  

Interesting - we should not use  '__' as prefix in our code - though not
directly related to our code.



>  	info->device_size = xlate32(dl->pvd.pv_size) << SECTOR_SHIFT;
>  	dm_list_init(&info->mdas);
> +	if (info->mda_slots)
> +		dm_free(info->mda_slots);
> +	if (!(info->mda_slots = dm_zalloc(FMT_LVM1_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
> +		/* FIXME: Add revert of cache info! */
> +		stack;
> +		return;

This is yet another reason why we should not play with cache internally - we
may introduce internal consistency problem and may get into the moment when
our cache will represent different data than does we would read from disk.


> +
> +	if (!(info->mda_slots = dm_zalloc(FMT_TEXT_MAX_MDAS_PER_PV * sizeof(struct metadata_area *)))) {
> +		/* FIXME: Add revert of cache info! */

again quite important case...

> +		return 0;
> +	}
> +
> +	return 1;
> +}
> +
>  static void _text_destroy_instance(struct format_instance *fid __attribute__((unused)))
>  {
>  }


Zdenek


