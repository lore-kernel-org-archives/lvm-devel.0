From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 28 Jun 2010 09:03:07 -0500
Subject: [RFC][PATCH] lvm2: adjust region size of mirrored log
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A5922886497@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A5922886497@USINDEVS02.corp.hds.com>
Message-ID: <E3763991-94F0-4531-9356-E356042805FB@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

ACK.  I'll check this in today.

  brassow

On Jun 25, 2010, at 12:25 PM, Takahiro Yasui wrote:

> Fix bz608048
>
> The same region size is used for both mirror volume and mirrored
> log volume, but when physical extent size is bigger than region size,
> the size of mirror leg for mirrored log is smaller than the region  
> size
> and lvcreate command fails.
>
> This patch adjusts a region size of mirrored log to a smaller value of
> region size or physical extent size.
>
>
> Signed-off-by: Takahiro Yasui <takahiro.yasui@hds.com>
> ---
> lib/metadata/mirror.c |    4 +++-
> 1 file changed, 3 insertions(+), 1 deletion(-)
>
> Index: LVM2-2.02.68/lib/metadata/mirror.c
> ===================================================================
> --- LVM2-2.02.68.orig/lib/metadata/mirror.c
> +++ LVM2-2.02.68/lib/metadata/mirror.c
> @@ -1816,7 +1816,9 @@ int add_mirror_images(struct cmd_context
> 	 * create and initialize mirror log
> 	 */
> 	if (log_count &&
> -	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,  
> region_size,
> +	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
> +					  (region_size > lv->vg->extent_size) ?
> +					  lv->vg->extent_size : region_size,
> 					  alloc, mirror_in_sync()))) {
> 		stack;
> 		goto out_remove_images;
>
> -- 
> Takahiro Yasui
> Hitachi Data Systems
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


