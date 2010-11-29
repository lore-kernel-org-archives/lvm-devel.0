From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:17:40 +0000
Subject: [PATCH 15/29] Modify test to catch passing NULL pointer
In-Reply-To: <21ce9b1c3b783c65154252d32f13058c6c99b567.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<21ce9b1c3b783c65154252d32f13058c6c99b567.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129211740.GF29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:19AM +0100, Zdenek Kabelac wrote:
> 'data' is initialized as NULL and if 'dev' would be NULL from info->dev

If we hit that condition we must do a scan.

> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  lib/format1/disk-rep.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
> index bc58744..071b39d 100644
> --- a/lib/format1/disk-rep.c
> +++ b/lib/format1/disk-rep.c
> @@ -471,7 +471,7 @@ int read_pvs_in_vg(const struct format_type *fmt, const char *vg_name,
>  	    vginfo->infos.n) {
>  		dm_list_iterate_items(info, &vginfo->infos) {
>  			dev = info->dev;
> -			if (dev && !(data = read_disk(fmt, dev, mem, vg_name)))
> +			if (!dev || !(data = read_disk(fmt, dev, mem, vg_name)))
>  				break;
>  			_add_pv_to_list(head, data);

This makes it fall through to the scan.
Ack.

Alasdair


