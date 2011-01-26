From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 26 Jan 2011 12:05:57 +0100
Subject: [PATCH 04/17] Add format_instance support for pv_read.
In-Reply-To: <87lj29ru07.fsf@twilight.int.mornfall.net.>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>	<1295867048-21558-5-git-send-email-prajnoha@redhat.com>
	<87lj29ru07.fsf@twilight.int.mornfall.net.>
Message-ID: <4D400015.5040908@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/25/2011 02:30 PM +0100, Petr Rockai wrote:
> Peter Rajnoha <prajnoha@redhat.com> writes:
> 
>> We don't need to store metadata areas in a separate "mdas" parameter
>> since it is in the pv->fid now. If the fid is not defined yet and is
>> NULL, pv_read code will create a new one (if there's no VG fid yet
>> where the metadata areas read off of a PV should be attached to).
> 
> This is somewhat hairy... With this patch, it's starting to seem that PV
> will sometimes point to a VG FID and other times to PV FID. Is there a
> good reason for that? Is the PV FID only used with orphan PVs?
> 

Well, we have plain PVs that are not part of any real VG yet, the orphan. BUT
we don't want to group them into an orphan VG (that would require collecting
all mdas from all orphan VGs). In this case, we have a pure PV fid defined
(this fid will include *only* the mdas on that PV).

Then we have plain PVs that are not part of any real VG yet, but are grouped
together into a virtual "orphan" VG. From fid's point of view, this is a VG
like any other, so the pv->fid references the VG-based pv->vg->fid.

Then we have PVs that are part of a real VG. These also have the pv->fid
referencing the pv->vg->fid.

This way, we can use the pv->fid transparently - we don't actually care
whether it is PV-based or VG-based fid, we only need to access the
mdas. Whether these mdas are store together in a pool with mdas from
other PVs (when in a VG) or they are just standalone mdas from that
one PV, we don't care. It makes writing the code easier. We don't
need to check that anymore...

> I think this is something that really needs to be documented. If nothing

..OK, I'll try to add some comments.

> else, the format_instance type value (as suggested in an earlier
> comment) should read ORPHAN_PV_FID and VG_FID. It also does raise the

Actually, ORPHAN_VG_FID, VG_FID and PV_FID. But since ORPHAN_VG_FID == VG_FID
from fid's point of view, we have the separation PV_FID and VG_FID only
(which is exactly what the format_instance->pv_only flag is about)

> question, why we don't always use VG_FID even for orphans, given how we

E.g. creating a new PV, modifying just one PV etc. - there's no need to group
and store all the other mdas that are in that "virtual" orphan VG.
If we want to group that for some complex situations, OK. But it's useless
for simple modification done only on one PVs (iow, creating orphan VG fid
means collecting all mdas from all PVs not in a VG yet. And that could
be uselessly time-consuming for simple PV-only operations since we would
throw all that information away anyway).

> have an orphans VG? Would simply using the orphans VG FID be more
> consistent overall?
> 

Please, let's not group into orphan VG where it's not really needed...

>> +	if (fid)
>> +		fid_add_mdas(fid, &info->mdas, (const char *) &pv->id, ID_LEN);
>> +	else {
>> +		if (!(pv->fid = pv->fmt->ops->create_instance(pv->fmt,
>> +						(const char *) &pv->id,
>> +						NULL, NULL, NULL))) {
>> +			log_error("_pv_read: Couldn't create format instance "
>> +				  "for PV %s", pv_name);
>> +			goto bad;
>> +		}
>> +	}
>> +
> 
> The code above is certainly confusing. A comment is needed, explaining
> what is going on. Please explain that non-NULL "fid" means that this PV
> belongs to a VG, and the fid variable points to that VG's fid.
> 

It's because this _pv_read could be part of a vg_read (e.g. _vg_read_orphans).
So creating a standalone PV fid that would be destroyed immediately and
replaced by orphan VG fid would be useless, so it's better to pass the existing
fid in. So if it's defined already, we just merge PVs mdas into the fid and if
not, we create the new PV-based fid.

> Also, why mdas are added to the VG fid, but the (orphan) PV fid is left
> empty? Should the code read
> 
> if (!fid) {
>     if (!(fid = pv->fid = ...
> }
> 
> fid_add_mdas(fid, ...)
> 

The fid_add_mdas is part of the create_instance fn, so you would call that
code twice... (but this is related to the next patch also and I've seen the
comment briefly, so I'll reply there :) )

> ?
> 
> If, as I suspect, it's because create_instance adds the MDA's itself,
> please add a comment to that effect. (Also, is it necessary that
> create_instance does this? I am not sure it is entirely intuitive...)
> 

...

Peter


