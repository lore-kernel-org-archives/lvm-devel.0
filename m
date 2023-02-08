From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 8 Feb 2023 14:06:49 +0100
Subject: [PATCH] vgimportdevices: LOCK_EX requires <sys/file.h> include
In-Reply-To: <20230207132712.32616-1-soap@gentoo.org>
References: <20230207132712.32616-1-soap@gentoo.org>
Message-ID: <fbd7e8b3-c49c-b7f9-35df-6c0544bd40db@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 07. 02. 23 v 14:27 David Seifert napsal(a):
> From: Jory Pratt <anarchy@gentoo.org>
> 
> https://linux.die.net/man/2/flock
> 
> Bug: https://bugs.gentoo.org/887259
> ---
>   tools/vgimportdevices.c | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
> index ab359d31c..d8260c731 100644
> --- a/tools/vgimportdevices.c
> +++ b/tools/vgimportdevices.c
> @@ -15,6 +15,7 @@
>   #include "tools.h"
>   #include "lib/cache/lvmcache.h"
>   #include "lib/device/device_id.h"
> +#include <sys/file.h>
>   
>   struct vgimportdevices_params {
>   	uint32_t added_devices;

Hi & thanks

I'll apply

Regards

Zdenek
