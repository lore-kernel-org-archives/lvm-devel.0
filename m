From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 16 Sep 2013 12:04:18 +0200
Subject: [PATCH] systemd: lvm2-activation-generator: add missing ordering deps between generated units
In-Reply-To: <201309151311.r8FDBgTB032554@mx1.redhat.com>
References: <201309151311.r8FDBgTB032554@mx1.redhat.com>
Message-ID: <5236D7A2.90501@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/15/2013 02:26 PM, Alexander Tsoy (by way of Alexander Tsoy <alexander@tsoy.me>) wrote:
> If two units run in parrallel, then one of them enter failing
> state because device is busy:
> 
> "device-mapper: create ioctl on <VG-LV> failed: Device or resource
> busy"
> 
> See: https://bugs.gentoo.org/show_bug.cgi?id=480066
> ---
>  scripts/lvm2_activation_generator_systemd_red_hat.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
> index 7e93d7d..cf6da2f 100644
> --- a/scripts/lvm2_activation_generator_systemd_red_hat.c
> +++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
> @@ -134,8 +134,8 @@ static int generate_unit(const char *dir, int unit)
>  	      "DefaultDependencies=no\n", f);
>  
>  	if (unit == UNIT_NET) {
> -		fputs("After=iscsi.service fcoe.service\n"
> -		      "Before=remote-fs.target shutdown.target\n\n"
> +		fputs("After=lvm2-activation-early.service iscsi.service fcoe.service\n"
> +		      "Before=lvm2-activation.service remote-fs.target shutdown.target\n\n"
>  		      "[Service]\n"
>  		      "ExecStartPre=/usr/bin/udevadm settle\n", f);
>  	} else {
> 

Thanks for the patch! However, I've modified it a bit so the ordering is set to:

  lvm2-activation-early.service -> lvm2-activation.service -> lvm2-activation-net.service

This was the originally intended order. The patch applied upstream:
  https://git.fedorahosted.org/cgit/lvm2.git/commit/?id=9742c5192e8871ebde12856170dae70ee861ef40

Peter


