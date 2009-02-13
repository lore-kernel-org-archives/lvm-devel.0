From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 13 Feb 2009 06:23:12 -0500
Subject: [PATCH 12/13] First cut at adding pv_obj_* APIs.
In-Reply-To: <874ozc75n1.fsf@eriador.mornfall.net>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-8-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-9-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-10-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-11-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-12-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-13-git-send-email-dwysocha@redhat.com>
	<874ozc75n1.fsf@eriador.mornfall.net>
Message-ID: <1234524192.2731.19.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-02-03 at 00:58 +0100, Petr Rockai wrote:
> Hi,
> 
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > Impelemnt pv_obj_get(), pv_obj_get_list(), pv_obj_get_attr_list() and
> > pv_obj_get_attr_value().
> >
> > This is a first attempt at adding pv_obj_* APIs as outlined by
> > http://fedoraproject.org/wiki/LVM/liblvm/api
> >
> > Why add another structure when we could use struct physical_volume
> > and other internal structs?  At this point it is not clear but would
> > provide us with the ability to more easily allocate and free handles,
> > and would allow places to store things like the access mode and API
> > errors without polluting the internal structures.
> I don't say this is completely wrong, but the naming seems very baroque to me,
> and not at all clear what it means, in relation to pv_t, lv_t and such. Also,
> how does this relate to the idea that we want to push back the concept of a PV
> as away from users as possible? I think Alasdair mentioned that on several
> occasions -- PVs should become implicit, as opposed to explicit. Although it
> might be a stretch for library. Not sure. What do you think?
> 

We discussed removing the PV concept from the API earlier this week on a
concall.  From my notes/recollection, here is what we concluded:
1. We should aim to ensure a PV is always in a VG, even if it is just
the orphan VG.
2. To obtain a PV object, you must first obtain a VG object.
3. If you want to change a PV attribute, you must first do a
vg_read/vg_open and obtain WRITE permission.
Thomas is going to update the API document.

I agree it is not desirable to introduce another set of structures
unless there is good reason for it.  It was an initial implementation
and something Thomas and I were discussing.  The reason we were leaning
towards a new structure was we needed a place to store the options for
the create functions (e.g. pvcreate, vgcreate, lvcreate).  In some cases
these are attributes of the actual PV, VG, or LV.  But in other cases
they are options to control the create behavior.  We should probably
think about each of the options specifically and see what the best way
to handle them.  I know this wasn't apparent from my patchset here but
as I recall this is why we were adding a new structure.


> As for internal structures, I suppose the major hurdle is the way we allocate
> those in the toolcontext pool (and then maybe their complex interlinked
> nature). I wouldn't say that another layer of, especially
> heap-or-pool-allocated indirection will do any good. I think we already have
> more than is good for us: the lvmcache is keeping a shadow copy of everything
> already in an incompatible format from the struct volume_group and
> friends. This happens to be the on-disk text format in a string buffer. I
> believe this is also due to allocation and linking issues of the current struct
> volume_group representation. So improving the situation with the struct
> volume_group etc. would probably help the lvmcache, as well as the lvmlib
> API. Maybe that would be a worthy investment then, instead of building up
> another incompatible shadow structure?
> 

Agreed the internal structures are a bit confusing with various
partially done abstractions, etc.  If we can clean them up it would be
great.

> Also, the patch seems to be duplicating a lot of code from previous patches? Or
> were those for different kind of object (listing and checking attributes, eg.)?
> 

Probably so - patches were just a first stab.

Thanks for the comments.


