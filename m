From: Milan Broz <mbroz@redhat.com>
Date: Tue, 12 May 2009 14:34:19 +0200
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <20090511015448.GC7680@agk-dp.fab.redhat.com>
References: <cover.1241620083.git.mbroz@redhat.com>	<a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
	<20090511015448.GC7680@agk-dp.fab.redhat.com>
Message-ID: <4A096CCB.8070308@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> On Wed, May 06, 2009 at 04:42:59PM +0200, Milan Broz wrote:
>> This can violate VG max_lv restriction on LV.
> 
> I'm not bothered if the code exceeds max_lv temporarily.

It is not temporarily, it is stored in metadata on disk in this case.

That's why I do not want to store VISIBLE flag there.
Even without mentioning max_lv, the proper solution should be properly
revert these invisible volumes if operation fails in the middle.


> I mean, does anyone have a real-world use case for that parameter?
That parameter is mistake for text metadata format IMHO. 

The only real use is to downconvert to lvm1 format (which has limited LVs)

But we have it documented, "supported" so removing it is probably not good way.

> (Perhaps make it so VGs exceeding that limit can still be manipulated
> internally, but users cannot add new LVs until it drops below the
> limit i.e. a soft limit enforced on the user.)

What the internally means here? Not stored in persistent metadata?
Or stored with an internal/temporary flag?

> This comes back to whether we actually need the distinction between
> TOPLEVEL (nothing in lvm uses the LV) and VISIBLE (it's for users/tools
> to open) or not, a distinction we've been eliminating I think.

Which will probably re-complicate again when replicator & crypto segments/LVs
are introduced...

> (If we got automatic clean-up of incomplete multi-step operations
> wouldn't the problem go away?  Might be as simple as flagging LVs as
> temporary/uncommitted in the metadata and having them deleted next time
> the VG lock is taken in the same way as we deal with multiple metadata
> sequence numbers in different VG mdas.)

Is this possible without breaking compatibility with old versions?
(new LV flag?)

Milan


