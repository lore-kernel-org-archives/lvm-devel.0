From: Takahiro Yasui <tyasui@redhat.com>
Date: Wed, 17 Feb 2010 18:20:38 -0500
Subject: [PATCH 13 of 13] LVM: 2 mirrored log monitor fixes
In-Reply-To: <201002171757.o1HHvnpB005275@hydrogen.msp.redhat.com>
References: <201002171757.o1HHvnpB005275@hydrogen.msp.redhat.com>
Message-ID: <4B7C79C6.6090908@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
> Patch name: lvm2-mirrored-log-monitor-fixes.patch
> 
> If an event is received on a mirrored LV which also happens to
> be the log of a mirror, strip off the '_mlog' component extension
> of the name and pass the encapsulating LV to 'lvconvert --repair'.
> 
> 
> Index: LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
> ===================================================================
> --- LVM2.orig/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
> +++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c
> @@ -148,6 +148,11 @@ static int _remove_failed_devices(const 
>  		return -ENOMEM;	/* FIXME Replace with generic error return - reason for failure has already got logged */
>  	}
>  
> +	/* strip off the mirror component designations */
> +	layer = strstr(lv, "_mlog");
> +	if (layer)
> +		layer = '\0';

Typo? :)
		*layer = '\0';

Thanks,
Taka



