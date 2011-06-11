From: Amir G. <amir73il@users.sourceforge.net>
Date: Sat, 11 Jun 2011 07:01:36 +0300
Subject: LVM vs. Ext4 snapshots (was: [PATCH v1 00/30] Ext4 snapshots)
In-Reply-To: <20110610150129.GA17585@ubuntu>
References: <BANLkTimyBGfg4+ovGsiGqpCz345qVmU_7A@mail.gmail.com>
	<BANLkTik20iYN4c9faKD9dzerehazWTwTFw@mail.gmail.com>
	<BANLkTikKRuPu_NX49vr0w-XeN0ZnWo+9vg@mail.gmail.com>
	<alpine.LFD.2.00.1106101101020.4502@dhcp-27-109.brq.redhat.com>
	<20110610101142.GA10144@ubuntu>
	<BANLkTi=zjU3-FV3AVpYsknzKFgaS7byb_Q@mail.gmail.com>
	<20110610150129.GA17585@ubuntu>
Message-ID: <BANLkTikUZadpVJRcfX_MLMZ-p_G0bT_8uQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jun 10, 2011 at 6:01 PM, Joe Thornber <thornber@redhat.com> wrote:
> On Fri, Jun 10, 2011 at 05:15:37PM +0300, Amir G. wrote:
>> On Fri, Jun 10, 2011 at 1:11 PM, Joe Thornber <thornber@redhat.com> wrote:
>> > FUA/flush allows us to treat multisnap devices as if they are devices
>> > with a write cache. ?When a FUA/FLUSH bio comes in we ensure we commit
>> > metadata before allowing the bio to continue. ?A crash will lose data
>> > that is in the write cache, same as any real block device with a write
>> > cache.
>> >
>>
>> Now, here I am confused.
>> Reducing the problem to write cache enabled device sounds valid,
>> but I am not yet convinced it is enough.
>> In ext4 snapshots I had to deal with 'internal ordering' between I/O
>> of origin data and snapshot metadata and data.
>> That means that every single I/O to origin, which overwrites shared data,
>> must hit the media *after* the original data has been copied to snapshot
>> and the snapshot metadata and data are secure on media.
>> In ext4 this is done with the help of JBD2, which anyway holds back metadata
>> writes until commit.
>> It could be that this problem is only relevant to _extenal_ origin, which
>> are not supported for multisnap, but frankly, as I said, I am too confused
>> to figure out if there is yet an ordering problem for _internal_ origin or not.
>
> Ok, let me talk you through my solution. ?The relevant code is here if
> you want to sing along:
> https://github.com/jthornber/linux-2.6/blob/multisnap/drivers/md/dm-multisnap.c
>
> We use a standard copy-on-write btree to store the mappings for the
> devices (note I'm talking about copy-on-write of the metadata here,
> not the data). ?When you take an internal snapshot you clone the root
> node of the origin btree. ?After this there is no concept of an
> origin or a snapshot. ?They are just two device trees that happen to
> point to the same data blocks.
>
> When we get a write in we decide if it's to a shared data block using
> some timestamp magic. ?If it is, we have to break sharing.
>
> Let's say we write to a shared block in what was the origin. ?The
> steps are:
>
> i) plug io further to this physical block. (see bio_prison code).
>
> ii) quiesce any read io to that shared data block. ?Obviously
> including all devices that share this block. ?(see deferred_set code)
>
> iii) copy the data block to a newly allocate block. ?This step can be
> missed out if the io covers the block. (schedule_copy).
>
> iv) insert the new mapping into the origin's btree
> (process_prepared_mappings). ?This act of inserting breaks some
> sharing of btree nodes between the two devices. ?Breaking sharing only
> effects the btree of that specific device. ?Btrees for the other
> devices that share the block never change. ?The btree for the origin
> device as it was after the last commit is untouched, ie. we're using
> persistent data structures in the functional programming sense.
>
> v) unplug io to this physical block, including the io that triggered
> the breaking of sharing.
>
> Steps (ii) and (iii) occur in parallel.
>
> The main difference to what you described is the metadata _doesn't_
> need to be committed before the io continues. ?We get away with this
> because the io is always written to a _new_ block. ?If there's a
> crash, then:
>
> - The origin mapping will point to the old origin block (the shared
> ?one). ?This will contain the data as it was before the io that
> ?triggered the breaking of sharing came in.
>
> - The snap mapping still points to the old block. ?As it would after
> ?the commit.
>

OK. Now I am convinced that there is no I/O ordering issue,
since you are never overwriting shared data in-place.

Now I also convinced that the origin will be so heavily fragmented,
to the point that the solution will not be practical for performance
sensitive applications. Specifically, applications that use spinning
media storage and require consistent and predictable performance.

I do have a crazy idea, though, how to combine the power of the
multisnap features with the speed of a raw ext4 fs.

In the early days of next3 snapshots design I tried to mimic
the generic JBD APIs and added generic snapshot APIs
to ext3, so that some day an external snapshot store
implementation could use this API.

Over time, as the internal snapshots store implementation grew
to use many internal fs optimizations, I neglected the option to
ever support an external snapshots store.

Now that I think about it, it doesn't look so far fetched after all.
The concept is that multisnap can register as a 'snapshot store
provider' and get called by ext4 directly (not via device mapper)
to copy a metadata buffer on write (snapshot_get_write_access),
get ownership over fs data blocks on delete and rewrite
(snapshot_get_delete/move_access) and to commit/flush the store.

ext4 will keep track of blocks which are owned by the external
snapshot store (in the exclude bitmap) and provide a callback
API from the snapshots store to free those blocks on snapshot
delete.

The ext4 snapshot APIs are already working that way with
the internal store implementation (the store is a sparse file).

There is also the step of creating the initial metadata btree
when creating the multisnap volume with __external__ origin.
This is just a simple translation of the ext4 block bitmap to
a btree. After that, changes to the __external__ btree can
be made on changes to the ext4 block bitmap - an API already
being used by internal implementation (snapshot_get_bitmap_access).

What do you think?
Does this plan sound too crazy?
Do you think it is doable for multisnap to support this kind of
__external__ origin?

Amir.


