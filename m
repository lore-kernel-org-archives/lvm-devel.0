From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 11 May 2009 12:42:52 +0100
Subject: [PATCH 3/7] Remove snapshot_count from VG and use function instead.
In-Reply-To: <a015c94d4f5d34699e100b182f539812543b883e.1241620083.git.mbroz@redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>
	<a015c94d4f5d34699e100b182f539812543b883e.1241620083.git.mbroz@redhat.com>
Message-ID: <20090511114252.GF7680@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 06, 2009 at 04:43:00PM +0200, Milan Broz wrote:
> -	 * The following relationship should always hold:
> -	 * dm_list_size(lvs) = lv_count + 2 * snapshot_count
> +	 * logical volumes count

Please leave the description of dm_list_size(lvs).
  "Number of snapshots" instead of snapshot_count?
  (Or the new function?)

> +unsigned snapshot_lvs_in_vg(const struct volume_group *vg)
> +{
> +	struct lv_list *lvl;
> +	unsigned lv_count = 0;

A confusing alternative use for a variable called lv_count?
'unsigned snapshot_count'?

Ack.

Alasdair.


