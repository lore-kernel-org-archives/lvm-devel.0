From: Mathias Krause <mathias.krause@secunet.com>
Date: Wed, 19 Aug 2015 15:42:18 +0200
Subject: [PATCHv2] libdm: mark control fd as close-on-exec
In-Reply-To: <1436945698-18193-1-git-send-email-mathias.krause@secunet.com>
References: <1436945698-18193-1-git-send-email-mathias.krause@secunet.com>
Message-ID: <55D487BA.6030504@secunet.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 15.07.2015 09:34, Mathias Krause wrote:
> The control fd should be marked as close-on-exec to avoid file
> descriptor leaks in forking applications executing other programs.
> 
> Signed-off-by: Mathias Krause <mathias.krause@secunet.com>
> 
> ---
> v2: fix return value mix-up (should be 1 on success)
> ---
>  libdm/ioctl/libdm-iface.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
> index e3b33b805e93..0f9e98a4a061 100644
> --- a/libdm/ioctl/libdm-iface.c
> +++ b/libdm/ioctl/libdm-iface.c
> @@ -385,11 +385,24 @@ static void _close_control_fd(void)
>  #ifdef DM_IOCTLS
>  static int _open_and_assign_control_fd(const char *control)
>  {
> +#ifdef O_CLOEXEC
> +	/*
> +	 * O_CLOEXEC is supported since v2.6.23, so this may fail on old
> +	 * kernels. Nonetheless favour it to a two staged approach as it's
> +	 * atomic.
> +	 */
> +	if ((_control_fd = open(control, O_RDWR | O_CLOEXEC)) >= 0)
> +		return 1;
> +#endif
> +
>  	if ((_control_fd = open(control, O_RDWR)) < 0) {
>  		log_sys_error("open", control);
>  		return 0;
>  	}
>  
> +	if (fcntl(_control_fd, F_SETFD, FD_CLOEXEC))
> +		log_sys_error("fcntl", "setting FD_CLOEXEC");
> +
>  	return 1;
>  }
>  #endif

Ping? Any objections to the patch?

Regards,
Mathias


