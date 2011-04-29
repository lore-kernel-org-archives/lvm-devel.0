From: Petr Rockai <prockai@redhat.com>
Date: Fri, 29 Apr 2011 19:55:04 +0200
Subject: [PATCH] Refactor lib/ code to allow deferred PV labelling
In-Reply-To: <4DB92CD9.1060508@redhat.com> (Peter Rajnoha's message of "Thu,
	28 Apr 2011 11:01:13 +0200")
References: <87oc3rhp66.fsf@aldalome.int.mornfall.net.>
	<20110427182420.GD32370@agk-dp.fab.redhat.com>
	<4DB92CD9.1060508@redhat.com>
Message-ID: <87bozpj62v.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(resending with the hopefully correct recipient list)

Peter Rajnoha <prajnoha@redhat.com> writes:
>> These are really just temporary places to store things - not used as an intrinsic
>> part of the structs themselves.  How difficult is it to handle them
>> separately outside the structs?
>
> Well, normally, we store that in PV-based format instance context
> (the 'struct text_fid_pv_context' that is stored in 'private' field in
> 'struct format_instance). But if that PV is part of the VG, we use a
> common VG-based format instance - so we can't store that PV info there
> separately for each PV...

Indeed, which is why I didn't use that (although I initially tried).

> So how about using 'struct pvcreate_params' we attach to 'struct pv_to_create'
> in add_pv_to_vg fn:
>
>   if (pv->status & UNLABELLED_PV) {
>                 if (!(pvc = dm_pool_zalloc(mem, sizeof(*pvc)))) {
>                         log_error("pv_to_create allocation for '%s' failed", pv_name);
>                         return 0;
>                 }    
>                 pvc->pv = pv;
>                 pvc->pp = pp;
>                 ...
>   ...
>
>
> Can we use that to store that label sector info? Would that work?

Probably, although it would make things somewhat more complicated yet. I
don't see anything wrong with storing that inside PV: it is per-PV
anyway. I agree that the PV struct could use some reorganisation, but
there is absolutely no problem in storing these things inside. They may
need to be clearly marked (maybe relegated into a sub-structure) but
that's all.

And if the info does not belong to the PV, it even less belongs to
pvcreate_params. So while it (in practice) can go in either, it belongs
more rightly to PV.

> If we don't find a place for that label sector other than the struct
> PV itself as proposed in this patch, we can also remove the 'struct
> text_fid_pv_context'.  The text_fid_pv_context is here to store the
> label_sector info only. At least for now.  I wanted to use the PV
> struct for that as well the other day, like you do here... ;) It's
> useless to store that in two places at the same time.

Right, I was wondering if moving the thing out of the PV is worth the
big pile of code that does the text_fid_pv_context bookkeeping. I would
say not. And I need it in the PV anyway. So I vote for removing
text_fid_pv_context.

Yours,
   Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined

