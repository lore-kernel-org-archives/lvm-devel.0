From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Sep 2010 10:44:48 +0200
Subject: [PATCH 02/19] Refactor pvstatus_disp to take pv argument and call common pv_attr function.
In-Reply-To: <1284564971-26060-3-git-send-email-dwysocha@redhat.com>
References: <1284564971-26060-1-git-send-email-dwysocha@redhat.com>
	<1284564971-26060-3-git-send-email-dwysocha@redhat.com>
Message-ID: <4C91D900.2050804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15.9.2010 17:35, Dave Wysochanski napsal(a):
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
>  lib/metadata/metadata.c |   21 +++++++++++++++++++++
>  lib/metadata/metadata.h |    1 +
>  lib/report/columns.h    |    2 +-
>  lib/report/report.c     |   17 +++--------------
>  4 files changed, 26 insertions(+), 15 deletions(-)
> 
> diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
> index 094ffc1..86f07e7 100644
> --- a/lib/metadata/metadata.c
> +++ b/lib/metadata/metadata.c
> @@ -4598,6 +4598,27 @@ char *vg_attr(struct dm_pool *mem, const struct volume_group *vg)
>  	return repstr;
>  }
>  
> +char *pv_attr(struct dm_pool *mem, const struct physical_volume *pv)
> +{
> +	char *repstr;
> +
> +	if (!(repstr = dm_pool_zalloc(mem, 3))) {
> +		log_error("dm_pool_alloc failed");
> +		return NULL;
> +	}
> +
> +	if (pv->status & ALLOCATABLE_PV)
> +		repstr[0] = 'a';
> +	else
> +		repstr[0] = '-';
> +
> +	if (pv->status & EXPORTED_VG)
> +		repstr[1] = 'x';
> +	else
> +		repstr[1] = '-';
> +	return repstr;

when you are moving this code maybe again little shortening could be made:
c = (x) ? a : b;

Zdenek


