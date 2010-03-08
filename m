From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 08 Mar 2010 00:54:35 -0500
Subject: [PATCH 10 of 10] LVM: rework lvconvert_mirrorsuil
In-Reply-To: <201003052359.o25Nxeg5012728@hydrogen.msp.redhat.com>
References: <201003052359.o25Nxeg5012728@hydrogen.msp.redhat.com>
Message-ID: <4B94911B.8030707@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
> +static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
> +				  struct logical_volume *lv,
> +				  struct lvconvert_params *lp,
> +				  struct dm_list *operable_pvs,
> +				  uint32_t new_mimage_count,
> +				  uint32_t new_log_count,
> +				  int allocation_failures_ok)
> +{
> +	uint32_t region_size;
> +	struct lv_segment *seg;
...
> +		/* Insert a temporary layer for syncing,
> +		 * only if the original lv is using disk log. */
> +		if (seg->log_lv && !_insert_lvconvert_layer(cmd, lv)) {
> +			log_error("Failed to insert resync layer");
> +			return 0;
> +		}

"seg" seems to be used uninitialized here.

> +static int _lvconvert_mirrors_orig(struct cmd_context *cmd,
> +				   struct logical_volume *lv,
> +				   struct lvconvert_params *lp)
> +{

This function is not used anywhere...

Thanks,
Taka


