From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 14 Dec 2010 09:51:19 +0100
Subject: [PATCH] vg_validate support for pvmove LVs (BZ 662669)
In-Reply-To: <87ipyx74dd.fsf@twilight.int.mornfall.net.>
References: <87ipyx74dd.fsf@twilight.int.mornfall.net.>
Message-ID: <4D073007.2090806@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.12.2010 22:24, Petr Rockai napsal(a):
> Hi,
> 
> I am attaching patch that revs up vg_validate somewhat, to catch some
> malformed (internal) pvmoveN LVs. Currently, it checks that the segments
> in there are either linear or mirrored with 2 legs. Unfortunately, I
> haven't been able to come up with any further restrictions that wouldn't
> break the existing tests on some count. It seems that vg_validate is
> called on VGs where linear segments exist (although I have been unable
> to capture them at vg_commit time), and they are interspersed with
> mirrored segments in the same LV. I have already spent a lot of time on
> this, so if someone wants to come up with a stricter check, please feel
> free to do so.
> 
> Anyway, the attached patch does catch the bug triggered by kabi's test
> attached to BZ 654447. For the other bug (dangling reference) I will
> submit a separate BZ and a separate patch, hopefully tomorrow.
> 
> Yours,

>  
> +	dm_list_iterate_items(lvl, &vg->lvs) {
> +		if (!(lvl->lv->status & PVMOVE))
> +			continue;

Optionally - it could be put as call of local function into the same
dm_list_iterate_items() few lines above ?

i.e.
  if ((lvl->lv->status & PVMOVE) && !_validate_pvmove(lvl->lv))
	r = 0;

> +		dm_list_iterate_items(seg, &lvl->lv->segments) {
> +			if (seg_is_mirrored(seg)) {
> +				if (seg->area_count != 2) {
> +					log_error(INTERNAL_ERROR
> +						  "Segment %d in %s is not 2-way.",
> +						  loop_counter1, lvl->lv->name);
> +					r = 0;
> +				}
> +			} else if (seg->area_count != 1) {
> +				log_error(INTERNAL_ERROR
> +					  "Segment %d in %s has wrong number of areas: %d.",
> +					  loop_counter1, lvl->lv->name, seg->area_count);
> +				r = 0;
> +			}
> +		}

and move this into static _validate_pvmove().

Zdenek


