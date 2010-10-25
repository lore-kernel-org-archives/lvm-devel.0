From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:45:59 +0100
Subject: [PATCH 30/30] __attribute__((nonnull(1)))
In-Reply-To: <1b064186142b16fc847ae31ed99eecd92e59b3b8.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<1b064186142b16fc847ae31ed99eecd92e59b3b8.1287994530.git.zkabelac@redhat.com>
Message-ID: <87tyka4kk8.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:37 +0200,
Zdenek Kabelac wrote:
> 
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  lib/device/dev-cache.h |    2 +-
>  libdm/regex/ttree.c    |    3 ++-
>  2 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
> index c1c86d6..772d28e 100644
> --- a/lib/device/dev-cache.h
> +++ b/lib/device/dev-cache.h
> @@ -41,7 +41,7 @@ int dev_cache_has_scanned(void);
>  
>  int dev_cache_add_dir(const char *path);
>  int dev_cache_add_loopfile(const char *path);
> -struct device *dev_cache_get(const char *name, struct dev_filter *f);
> +struct device *dev_cache_get(const char *name, struct dev_filter *f) __attribute__((nonnull(1)));
>  
>  void dev_set_preferred_name(struct str_list *sl, struct device *dev);
>  
> diff --git a/libdm/regex/ttree.c b/libdm/regex/ttree.c
> index 0ad40bd..fc24c96 100644
> --- a/libdm/regex/ttree.c
> +++ b/libdm/regex/ttree.c
> @@ -28,7 +28,8 @@ struct ttree {
>  	struct node *root;
>  };
>  
> -static struct node **_lookup_single(struct node **c, unsigned int k)
> +static __attribute__((nonnull (1)))
> +struct node **_lookup_single(struct node **c, unsigned int k)

Ack.  Verbose, isn't it.


