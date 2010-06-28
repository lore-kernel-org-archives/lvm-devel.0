From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 28 Jun 2010 14:34:47 +0100
Subject: [PATCH 36/38] Allow 'all' and 'unmanaged' values for --vgmetadatacopies.
In-Reply-To: <1277520789-6808-37-git-send-email-dwysocha@redhat.com>
References: <1277520789-6808-28-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-29-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-30-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-31-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-32-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-33-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-34-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-35-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-36-git-send-email-dwysocha@redhat.com>
	<1277520789-6808-37-git-send-email-dwysocha@redhat.com>
Message-ID: <20100628133447.GA14902@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 25, 2010 at 10:53:07PM -0400, Dave Wysochanski wrote:
> +++ b/lib/metadata/metadata-exported.h

> +#define VGMETADATACOPIES_ALL UINT32_MAX
> +#define VGMETADATACOPIES_UNMANAGED 0

Exported.


> @@ -1075,6 +1075,14 @@ static int _vg_metadata_balance(struct volume_group *vg)
>  			count = vg->mda_copies - mda_copies;
>  		ret = _vg_unignore_mdas(vg, count);
>  	}
> +	/*
> +	 * 'All' is really a special cmdline value that means 2 things:
> +	 * 1. clear all ignore bits in all mdas in this vg
> +	 * 2. set the "unmanaged" policy going forward for metadata balancing
> +	 */
> +	if (vg->mda_copies == VGMETADATACOPIES_ALL)
> +		vg->mda_copies = VGMETADATACOPIES_UNMANAGED;

Can we be clear that _ALL will never hit disk?
There are no paths that reach disk bypassing that if test?

Alasdair


