From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 15 Oct 2009 23:47:27 +0100
Subject: [PATCH 2 of 10] LVM: make log_area a list
In-Reply-To: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
References: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
Message-ID: <20091015224727.GC16950@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 04:18:36PM -0500, Jon Brassow wrote:
> +	int skip = 0;

> +				dm_list_iterate_items(aa, &ah->log_areas)
> +					if (pvm->pv == aa->pv)
> +						skip = 1;
> +				if (skip) {
> +					skip = 0;
> +					continue;
> +				}

If 'skip' is just to break out of nested loops, please use something
like 'goto next_pv' instead.

Alasdair


