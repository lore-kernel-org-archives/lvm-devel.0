From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 12 Oct 2007 17:18:43 -0400
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
In-Reply-To: <20071012183720.31244.qmail@sourceware.org>
References: <20071012183720.31244.qmail@sourceware.org>
Message-ID: <470FE4B3.7040205@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Dave,

Thanks for committing the patches to CVS.

I found a comment below:

wysochanski at sourceware.org wrote:
> +	 * FIXME: leak pv->vg_name
> +	 * Adding dm_pool_free(mem, pv->vg_name) - causes warning w/'const'

since 'pv->vg_name' is allocated after 'pv' from the same pool,
freeing 'pv' will free 'pv->vg_name' as well.
So we don't have to do dm_pool_free(mem, pv->vg_name) here.

However,

> +	 * Perhaps pv->vg_name should be initialized to ORPHAN, not alloc'd
> +	 * memory?

I agree moving pv->vg_name allocation outside of _alloc_pv() is better.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


