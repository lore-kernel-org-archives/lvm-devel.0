From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 23 Feb 2011 16:48:36 +0000
Subject: [PATCH 1/3] Refactor vg allocation code
In-Reply-To: <95e375249a799ab7c5cb4d2f8ebf63e446c5364a.1298466569.git.zkabelac@redhat.com>
References: <cover.1298466569.git.zkabelac@redhat.com>
	<95e375249a799ab7c5cb4d2f8ebf63e446c5364a.1298466569.git.zkabelac@redhat.com>
Message-ID: <20110223164836.GA3626@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 23, 2011 at 02:52:15PM +0100, Zdenek Kabelac wrote:
> Usure about naming strategy - we use  i.e. alloc_lv,
> but most the new function have now operation prefix.
 
alloc_vg for now...because it's paired with free_vg and vg_free is already used
for something else:)

> Also the location after Dave's refactoring patches is unclear.
 
vg.c  - move free_vg there too.

> +	if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) ||

The code is now shared - "alloc_vg" will have to do, or if that makes
the log too hard to understand, pass the existing strings into the function.

Ack.

Alasdair


