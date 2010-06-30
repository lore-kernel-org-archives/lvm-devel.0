From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 30 Jun 2010 21:59:25 +0100
Subject: [PATCH] restore the "removemissing" behaviour of lvconvert --repair --use-policies
In-Reply-To: <87y6dwjlo6.fsf@twilight.int.mornfall.net.>
References: <87y6dwjlo6.fsf@twilight.int.mornfall.net.>
Message-ID: <20100630205925.GS23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jun 30, 2010 at 10:43:53PM +0200, Peter Rockai wrote:
> -	struct dm_list *failed_pvs = NULL;

> -	if (!(failed_pvs = _failed_pv_list(lv->vg)))
> +	if (!(lp->failed_pvs = _failed_pv_list(lv->vg)))

How does the patch work?

Alasdair


