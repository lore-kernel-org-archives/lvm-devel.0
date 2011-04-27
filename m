From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 27 Apr 2011 19:24:20 +0100
Subject: [PATCH] Refactor lib/ code to allow deferred PV labelling
In-Reply-To: <87oc3rhp66.fsf@aldalome.int.mornfall.net.>
References: <87oc3rhp66.fsf@aldalome.int.mornfall.net.>
Message-ID: <20110427182420.GD32370@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 27, 2011 at 02:08:49PM +0200, Peter Rockai wrote:
> --- old-lvmlib-pvcreate/lib/format1/format1.c	2011-04-27 14:02:11.000000000 +0200
> +++ new-lvmlib-pvcreate/lib/format1/format1.c	2011-04-27 14:02:11.000000000 +0200

> @@ -444,12 +452,18 @@ static int _format1_pv_write(const struc

> +	pv->pe_size = pe_size;
> +	pv->pe_count = pe_count;
> +	pv->pe_start = pe_start;

How does this interact with pvchange --uuid, pvresize etc.?
Is it tested with non-default settings?
Are further simplifications possible now, or is this even unmasking 
an existing bug where code forgets that pv_write update those fields?
(Needs an audit before this goes in.)

> +++ new-lvmlib-pvcreate/lib/metadata/metadata-exported.h	2011-04-27 14:02:11.000000000 +0200
> +#define UNLABELLED_PV           0x80000000U     /* PV -this PV had no label written yet */

(Internal only but best to add to flags.c anyway?)

> @@ -51,6 +51,9 @@ struct physical_volume {

> +	/* NB. Only useful/used when status & UNLABELLED_PV! */
> +	int64_t label_sector;

> @@ -59,6 +65,13 @@ struct volume_group {
> +	struct dm_list pvs_to_create;

These are really just temporary places to store things - not used as an intrinsic
part of the structs themselves.  How difficult is it to handle them
separately outside the structs?  Or can we enforce rules that they are always
cleared before the relevant metadata is cached or written?

There should be an internal consistency check that the appropriate orphan
lock is still held before the PV is written to in this manner.

Any vg_validation checks possible?

How easy is it to convert the other vg-based instances of pv_write over
to the new method?

Alasdair


