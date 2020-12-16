From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Dec 2020 13:07:25 +0100
Subject: [PATCH] dev_name(): add to judge whether the dev->aliases list is empty
In-Reply-To: <4f9d1853-8980-511e-3431-c0d549b18a5f@huawei.com>
References: <4f9d1853-8980-511e-3431-c0d549b18a5f@huawei.com>
Message-ID: <61d26ea0-0e02-3384-e5c7-f8e1ae5b35cd@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 16. 12. 20 v 10:35 Wu Guanghao napsal(a):
> If dev->aliases linked list is empty, then directly obtain the str address
> of dm_str_list saved in dev->aliases.n, an unknown address will be returned,
> which may cause segfault
> 

Hi


Do you have a triggering example case ?

It seems to me this patch is just hiding bug from other place.

Eventually try to pick-up info how you were able to hit this
coredump.

Zdenek

> Signed-off-by: Wu Guanghao <wuguanghao3@huawei.com>
> ---
>   lib/device/dev-cache.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
> index d5f18ff..9441924 100644
> --- a/lib/device/dev-cache.c
> +++ b/lib/device/dev-cache.c
> @@ -1629,8 +1629,8 @@ int dev_fd(struct device *dev)
> 
>   const char *dev_name(const struct device *dev)
>   {
> -	return (dev && dev->aliases.n) ? dm_list_item(dev->aliases.n, struct dm_str_list)->str :
> -	    unknown_device_name();
> +	return (dev && dev->aliases.n && !dm_list_empty(&dev->aliases)) ? \
> +		dm_list_item(dev->aliases.n, struct dm_str_list)->str : unknown_device_name();
>   }
> 
>   bool dev_cache_has_md_with_end_superblock(struct dev_types *dt)
> 


