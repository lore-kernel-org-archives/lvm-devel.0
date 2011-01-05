From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 01:59:05 +0000
Subject: [PATCH 23/23] Remove dead assignment in vg_split_mdas
In-Reply-To: <9c9444b0a208344231b42cb5197d45a377452304.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<9c9444b0a208344231b42cb5197d45a377452304.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105015905.GO10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:55PM +0100, Zdenek Kabelac wrote:
> 'common_mda' is assigned again with next code line.
 
>  	mdas_from_in_use = &vg_from->fid->metadata_areas_in_use;
>  	mdas_from_ignored = &vg_from->fid->metadata_areas_ignored;
>  	mdas_to_in_use = &vg_to->fid->metadata_areas_in_use;
>  	mdas_to_ignored = &vg_to->fid->metadata_areas_ignored;
>  
> -	common_mda = _move_mdas(vg_from, vg_to,
> -				mdas_from_in_use, mdas_to_in_use);
> +	_move_mdas(vg_from, vg_to, mdas_from_in_use, mdas_to_in_use);
>  	common_mda = _move_mdas(vg_from, vg_to,
>  				mdas_from_ignored, mdas_to_ignored);

Not immediately obvious how this code is correct.

The function returns 0 (giving user error message and aborting the split
operation) if common_mda is 0 i.e. if after the split there'll be no mdas
in the 'from' VG and there was no 'common' mda on the 'mdas_from_ignored'
list.

I'd guess the two lines should be in the opposite order, ignoring
the result from the 'ignored' move, but I don't understand why
the 'common_mdas' are not also taken into account (ignored) in
_vg_adjust_ignored_mdas.

_move_mdas() uses '!mda->ops->mda_in_vg' to detect a common_mda -
why are the functions that manipulate which mdas are ignored
not also doing this?  (This seems to be being used as a flag
to indicate 'This mda must always be used and cannot be ignored'.)

Even if the code is correct, it needs to be made clearer what
it is doing.

Alasdair


