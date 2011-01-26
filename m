From: Petr Rockai <prockai@redhat.com>
Date: Wed, 26 Jan 2011 14:59:29 +0100
Subject: [PATCH 02/17] Add supporting functions for metadata areas stored in format instance.
In-Reply-To: <4D3FF9BC.9080401@redhat.com> (Peter Rajnoha's message of "Wed,
	26 Jan 2011 11:38:52 +0100")
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>
	<1295867048-21558-3-git-send-email-prajnoha@redhat.com>
	<87pqrlrune.fsf@twilight.int.mornfall.net.>
	<4D3FF9BC.9080401@redhat.com>
Message-ID: <877hdrr9la.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha <prajnoha@redhat.com> writes:
>>> +	void *metadata_areas_index;
>> 
>> I don't currently expect that we would need as much genericity as void *
>> offers (and that we could use a little extra safety). Would an union be
>> better here, with an explicit list of types that can go in?
>> 
>
> Well, my incentive here was to keep this for any future changes so the
> format-specific code can decide and use any type of index we can imagine.
> We have this "metadata.c" layer and then the "format-specific" layer
> underneath that. So adding any new format with a brand new indexing
> scheme that is fine-tuned and suitable for that one new format would
> require breaking the abstraction layer (so defining a new type of index
> used in new format in the "metadata.c" layer above). So my incentive was
> to make the index transparent for the "metadata.c" layer.
>
> (I know, we have these "fid_{add,remove,get}_mda" functions that work
> directly with the index in "metadata.c" now, but that may eventually
> evolve into format-specific "fid" functions later. But since we have
> only one format that actually make real use of the format instance,
> I kept it in that metadata.c layer for now...)
>
> But if we expect to use the same index scheme all the time for all
> possible formats, not changing it too much, then sure, we can use a
> union there... But I'd like to avoid too much editing in the future :)

Well, I think you are deluding yourself about that. Plenty of other such
things is hard-coded all over the place and I am fairly sure adding an
union member is going to be the least of your worries at that point.

I wouldn't say anything if this came for free, but you are obviously
trading code safety and maintainability (which are fairly concrete) for
easier extendability (which is fairly hypothetical). I would opt for the
first, if faced with this kind of a tradeoff. YAGNI (You Aren't Gonna
Need It), anyway.

Yours,
   Petr

PS: If you want to make the format instance actually opaque, you should
move it out of metadata.{h,c} completely, into format_text, and only
have an opaque pointer (void * typedef) in VG/PV.


