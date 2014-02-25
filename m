From: Zhang Zhiqing <zhangzq.fnst@cn.fujitsu.com>
Date: Tue, 25 Feb 2014 17:53:55 +0800
Subject: [PATCH] Enhance stripe size validation
In-Reply-To: <530745EB.9040503@redhat.com>
References: <1392961943-1904-1-git-send-email-wangsl.fnst@cn.fujitsu.com>
	<530745EB.9040503@redhat.com>
Message-ID: <000201cf320f$822206c0$86661440$@cn.fujitsu.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In this condition,  (lp->ac_stripesize_value >= (uint64_t) vg->extent_size * 2) equals to (lp->ac_stripesize_value > (uint64_t) vg->extent_size). But the latter is concise, so I'll revise it.

Thanks,
Zhiqing, Zhang

-----Original Message-----
From: lvm-devel-bounces@redhat.com [mailto:lvm-devel-bounces at redhat.com] On Behalf Of Zdenek Kabelac
Sent: Friday, February 21, 2014 8:26 PM
To: LVM2 development
Cc: zhangzq.fnst at cn.fujitsu.com
Subject: Re: [lvm-devel] [PATCH] Enhance stripe size validation

Dne 21.2.2014 06:52, Wang Shilong napsal(a):
> From: Zhiqing Zhang <zhangzq.fnst@cn.fujitsu.com>
>
> While stripe size is twice the physical extent size, the original code 
> will not reduce stripe size to maximum(physical extent size).
>
> Signed-off-by: Zhiqing Zhang <zhangzq.fnst@cn.fujitsu.com>
> ---
>   lib/metadata/lv_manip.c |    2 +-
>   man/lvresize.8.in       |    4 +++-
>   2 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c index 
> 2b1cdcc..14ad884 100644
> --- a/lib/metadata/lv_manip.c
> +++ b/lib/metadata/lv_manip.c
> @@ -3394,7 +3394,7 @@ static int _validate_stripesize(struct 
> cmd_context *cmd,
>
>   	if (!(vg->fid->fmt->features & FMT_SEGMENTS))
>   		log_warn("Varied stripesize not supported. Ignoring.");
> -	else if (lp->ac_stripesize_value > (uint64_t) vg->extent_size * 2) {
> +	else if (lp->ac_stripesize_value >= (uint64_t) vg->extent_size * 2) 
> +{
>   		log_error("Reducing stripe size %s to maximum, "
>   			  "physical extent size %s",
>   			  display_size(cmd,lp->ac_stripesize_value),

I assume the condition should have been:

(lp->ac_stripesize_value > (uint64_t) vg->extent_size)


Let me check  what is in sectors and what has wrong units...


Zdenek



> diff --git a/man/lvresize.8.in b/man/lvresize.8.in index 
> 3606762..f746307 100644
> --- a/man/lvresize.8.in
> +++ b/man/lvresize.8.in
> @@ -88,7 +88,9 @@ Defaults to whatever the last segment of the Logical Volume uses.
>   Not applicable to LVs using the original metadata LVM format, which
>   must use a single value throughout.
>   .br
> -StripeSize must be 2^n (n = 2 to 9).
> +StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
> +For metadata in LVM2 format, the stripe size may be a larger power of 
> +2 but must not exceed the physical extent size.
>   .TP
>   .B \-\-noudevsync
>   Disable udev synchronisation. The
>

--
lvm-devel mailing list
lvm-devel at redhat.com
https://www.redhat.com/mailman/listinfo/lvm-devel




