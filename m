From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 10 Sep 2010 11:28:25 +0200
Subject: [PATCH 01/12] Add vg_attr() and lv_attr() functions.
In-Reply-To: <1284063189-4908-2-git-send-email-dwysocha@redhat.com>
References: <1284063189-4908-1-git-send-email-dwysocha@redhat.com>
	<1284063189-4908-2-git-send-email-dwysocha@redhat.com>
Message-ID: <4C89FA39.8010107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 9.9.2010 22:12, Dave Wysochanski napsal(a):
> Move the creating of the 'attr' strings into a common function so
> they can be called from the 'disp' functions as well as the new
> 'get' property functions.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  lib/metadata/metadata.c |  171 +++++++++++++++++++++++++++++++++++++++++++++++
>  lib/metadata/metadata.h |    2 +
>  lib/report/report.c     |  157 +------------------------------------------
>  3 files changed, 175 insertions(+), 155 deletions(-)
> 
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index d14c33c..094ffc1 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c

Yep - this file is already quite large (~4600 lines)

> @@ -4544,6 +4544,177 @@ uint32_t vg_mda_used_count
> +
> +	if (vg->status & LVM_WRITE)
> +		repstr[0] = 'w';
> +	else
> +		repstr[0] = 'r';

Shorter:

repstr[0] = (vg->status & LVM_WRITE) ? 'w' : 'r';

(similar to other places)


Zdenek


