From: Gang He <ghe@suse.com>
Date: Sun, 02 Dec 2018 19:43:34 -0700
Subject: master - scan: md metadata version 0.90 is at the end of disk
In-Reply-To: <201811291836.wATIaSVc015670@lists01.pubmisc.prod.ext.phx2.redhat.com>
References: <201811291836.wATIaSVc015670@lists01.pubmisc.prod.ext.phx2.redhat.com>
Message-ID: <5C049856020000F9000458D1@prv1-mh.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello David,

This patch can be used to fix this problem, or not?
https://www.redhat.com/archives/linux-lvm/2018-October/msg00049.html 


Thanks
Gang


>>> On 2018/11/30 at 2:36, in message
<201811291836.wATIaSVc015670@lists01.pubmisc.prod.ext.phx2.redhat.com>, David
Teigland <teigland@sourceware.org> wrote:
> Gitweb:        
> https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb04b84c79f10e6b3f1b376 
> cf7611d0afed26c39
> Commit:        cb04b84c79f10e6b3f1b376cf7611d0afed26c39
> Parent:        cd0fb0846db0d0bc04469914f6866a04af377548
> Author:        Peter Rajnoha <prajnoha@redhat.com>
> AuthorDate:    Thu Nov 29 12:35:54 2018 -0600
> Committer:     David Teigland <teigland@redhat.com>
> CommitterDate: Thu Nov 29 12:35:54 2018 -0600
> 
> scan: md metadata version 0.90 is at the end of disk
> 
> commit de28637
>   scan: use full md filter when md 1.0 devices are present
> 
> missed the fact that md superblock version 0.90 also puts
> metadata at the end of the device, so the full md filter
> needs to be used when either 0.90 or 1.0 is present.
> ---
>  lib/device/dev-md.c     |    2 +-
>  lib/filters/filter-md.c |    6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
> index ac99f42..9c626dd 100644
> --- a/lib/device/dev-md.c
> +++ b/lib/device/dev-md.c
> @@ -422,7 +422,7 @@ int dev_is_md_with_end_superblock(struct dev_types *dt, 
> struct device *dev)
>  	log_very_verbose("Device %s %s is %s.",
>  			 dev_name(dev), attribute, version_string);
>  
> -	if (!strcmp(version_string, "1.0"))
> +	if (!strcmp(version_string, "1.0") || !strcmp(version_string, "0.90"))
>  		return 1;
>  	return 0;
>  }
> diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
> index 2214986..0275923 100644
> --- a/lib/filters/filter-md.c
> +++ b/lib/filters/filter-md.c
> @@ -46,7 +46,7 @@
>   * 3. use udev to detect components
>   *
>   * mode 1 will not detect and exclude components of md devices
> - * that use superblock version 1.0 which is at the end of the device.
> + * that use superblock version 0.9 or 1.0 which is at the end of the 
> device.
>   *
>   * mode 2 will detect these, but mode 2 doubles the i/o done by label
>   * scan, since there's a read at both the start and end of every device.
> @@ -59,11 +59,11 @@
>   *
>   * - the command is pvcreate/vgcreate/vgextend, which format new
>   *   devices, and if the user ran these commands on a component
> - *   device of an md device 1.0, then it would cause problems.
> + *   device of an md device 0.9 or 1.0, then it would cause problems.
>   *   FIXME: this would only really need to scan the end of the
>   *   devices being formatted, not all devices.
>   *
> - * - it sees an md device on the system using version 1.0.
> + * - it sees an md device on the system using version 0.9 or 1.0.
>   *   The point of this is just to avoid displaying md components
>   *   from the 'pvs' command.
>   *   FIXME: the cost (double i/o) may not be worth the benefit
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com 
> https://www.redhat.com/mailman/listinfo/lvm-devel



