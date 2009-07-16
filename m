From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 16 Jul 2009 17:15:57 -0400
Subject: Re: [PATCH 2/6] Add devices/data_alignment_offset_detection to lvm.conf.
In-Reply-To: <4A5F75CC.8060203@redhat.com>
References: <1247515882-13736-1-git-send-email-snitzer@redhat.com>
	<1247515882-13736-3-git-send-email-snitzer@redhat.com>
	<4A5F75CC.8060203@redhat.com>
Message-ID: <20090716211557.GA9913@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jul 16 2009 at  2:47pm -0400,
Milan Broz <mbroz@redhat.com> wrote:

> Mike Snitzer wrote:
> > +	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/%s",
> > +			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev),
> > +			attribute) < 0) {
> > +		log_error("dm_snprintf %s failed", attribute);
> > +		return 0;
> > +	}
> >
> >   
> this segfaults here on 32bit...
>
> ---
>  lib/device/device.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/device/device.c b/lib/device/device.c
> index 2d01ec8..5330e3c 100644
> --- a/lib/device/device.c
> +++ b/lib/device/device.c
> @@ -296,7 +296,7 @@ int primary_dev(const char *sysfs_dir,
>  
>  	/* check if dev is a partition */
>  	if (dm_snprintf(path, PATH_MAX, "%s/dev/block/%d:%d/partition",
> -			sysfs_dir, MAJOR(dev->dev), MINOR(dev->dev)) < 0) {
> +			sysfs_dir, (int)MAJOR(dev->dev), (int)MINOR(dev->dev)) < 0) {
>  		log_error("dm_snprintf partition failed");
>  		return ret;
>  	}
> @@ -366,7 +366,7 @@ static unsigned long _dev_topology_attribute(const char *attribute,
>  		return_0;
>  
>  	if (dm_snprintf(path, PATH_MAX, sysfs_fmt_str, sysfs_dir,
> -			MAJOR(dev->dev), MINOR(dev->dev),
> +			(int)MAJOR(dev->dev), (int)MINOR(dev->dev),
>  			attribute) < 0) {
>  		log_error("dm_snprintf %s failed", attribute);
>  		return 0;
> 
> 


BTW, Peter was seeing dm_snprintf() segfaults with my patches too.

I'll be sure to cast all MAJOR() and MINOR() calls when used with
dm_snprintf().  Would still like to understand how not using a cast gets
us into trouble... but that is for when I get back from vacation ;)

Mike


