From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 14 May 2008 20:33:27 -0400 (EDT)
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <20080514234308.GQ10723@agk.fab.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
	<20080514234308.GQ10723@agk.fab.redhat.com>
Message-ID: <Pine.LNX.4.64.0805142017580.12073@engineering.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 15 May 2008, Alasdair G Kergon wrote:

> On Wed, May 14, 2008 at 07:30:17PM -0400, Mikulas Patocka wrote:
>> With merging, it will cause corruption --- if one snapshot is merging and
>> you don't have all the other snapshots loaded, the non-active snapshots
>> won't be updated as the merging goes on. So they'll be corrupted.
>
> If that can happen it suggests the detailed set of activation steps needs
> further refining and is not correct yet.

I think I have it already correct. The patch that corrects it is 
http://lacrosse.redhat.com/~mpatocka/patches/kernel/dm-snapshot-remove-active-variable.patch

Basically, lvm suspends all the devices, then loads the dm table for all 
of them and then resumes them.

I start merging at preresume method. When I start merging, all the other 
snapshots are already loaded in the table and can allocate new exceptions. 
The patch changes it so that they can accept new exceptions always.

>> Currently the contstraint is "if the device is open, you can't deactivate
>> it". I'd like change it to "if the device is open or some of its snapshots
>> are open, you can't deactivate it".
>
> Catch-22 then.  Which do you deactivate first?  We cannot handle that
> at kernel level with the current interface.

You are right. The possible solutions:

* block opening of suspended device until the device is resumed (or 
deleted) --- easiest, but most scary. Theoretically it should be OK --- 
you already should not open a file while there is something suspended (the 
memory-allocation deadlock) --- but it may make some of these deadlocks 
very visible. Maybe making the deadlocks visible is a good thing, it's 
much easier to solve reproducible deadlock than nonreproducible.

* undo the deactivation if one of the devices can't be removed because it 
is open --- probably the hardest.

* replace the open device's table with error target --- if it has 
journaled filesystem, it will recover fine. And it won't damage other 
snapshots.

* let it be, hoping that admin won't simultaneously open and deactivate a 
device :-/

> But by all means add that extra protection to the userspace code.
> The userspace code should not assume it happened though.
>
>> Even without merging, the current approach is not perfect, as you will end
>> up with a device that you can't deactivate (the origin is deactivated, the
>> snapshot is active; lvchange -an on the snapshot will return error;
>> lvchange -an on the origin will see that it is already inactive and do
>> nothing)
>
> That can be fixed: lvchange -an on the origin should complete the process.
> (It probably used to do that before some optimisation got added.)
>
> Alasdair
> -- 
> agk at redhat.com

BTW. Tomorrow I'm going to Brno to medical exam at Red Hat on Thursday and 
meeting on Friday, so I won't be on IRC and email much.

Mikulas


