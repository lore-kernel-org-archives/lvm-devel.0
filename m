From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Nov 2010 14:15:44 +0100
Subject: [PATCH 01/11] Add mda_slots field for PV info in the cache.
In-Reply-To: <1290115945-27419-2-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
	<1290115945-27419-2-git-send-email-prajnoha@redhat.com>
Message-ID: <4CEE6180.6000706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.11.2010 22:32, Peter Rajnoha napsal(a):
> The code further needs to access the information about metadata areas
> directly quite often without checking the relative position to other
> metadata areas or data areas. IOW, we need to know directly whether
> there is any metadata area at the start of the disk or at the end of the
> disk or any other position we can think of in the future. This way, I
> know exactly which slots are free, which are occupied and I know the
> relative position to other metadata areas without checking any offsets
> etc.
> 
> Using the original list would be quite painful here - either I'd need to
> store the position somewhere or I'll just use this array which seems
> better. Though, the list itself is still there - this is something I'd
> like to discuss... (So I haven't tried to remove the mda_list completely
> yet).
> 
> Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
> ---
>  lib/cache/lvmcache.c |    1 +
>  lib/cache/lvmcache.h |    2 ++
>  2 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
> index 60edcec..d1b6dea 100644
> --- a/lib/cache/lvmcache.c
> +++ b/lib/cache/lvmcache.c
> @@ -1357,6 +1357,7 @@ static void _lvmcache_destroy_entry(struct lvmcache_info *info)
>  	_vginfo_detach_info(info);
>  	strcpy(info->dev->pvid, "");
>  	label_destroy(info->label);
> +	dm_free(info->mda_slots);
>  	dm_free(info);
>  }
>  
> diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
> index 28f8541..32b4579 100644
> --- a/lib/cache/lvmcache.h
> +++ b/lib/cache/lvmcache.h
> @@ -33,6 +33,7 @@
>  struct cmd_context;
>  struct format_type;
>  struct volume_group;
> +struct metadata_area;


I'm not really sure where we are heading with out  lvmcache.

I'd like to see rather complete removal of this part of code - once we will
start work on thing like Petr's  lvmetad  - which would probably completely
eliminate need of any cache.

I think we should keep our lvmcache as simple as we can only to skip repeated
open & read from device -  everything else should be kept in higher level.
That could make future removal of this code much easier.

I guess we already break this concept in few place - but we should rather fix
those areas instead of add more hardwired functionality into cache level.


Zdenek


