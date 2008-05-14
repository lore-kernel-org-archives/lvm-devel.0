From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 14 May 2008 19:30:17 -0400 (EDT)
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <20080514223205.GM10723@agk.fab.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
Message-ID: <Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Wed, 14 May 2008, Alasdair G Kergon wrote:

> On Wed, May 14, 2008 at 04:28:09PM -0400, Mikulas Patocka wrote:
>> Now you mount one of the snapshots. And then, type:
>> lvchange -an volume
>> --- the result is, that the volume and all the snapshots except the
>> mounted one are deactivated. The mounted snapshot is still active.
>
>> It looks like a bug to me --- it was never indented to have some snapshots
>> active and some not.
>
> This does *not* of course lead to corruption: it's a constraint we
> chose to have LVM2 impose, not device-mapper.

With merging, it will cause corruption --- if one snapshot is merging and 
you don't have all the other snapshots loaded, the non-active snapshots 
won't be updated as the merging goes on. So they'll be corrupted.

> It's not a perfect constraint as you discovered because it would be
> impossible to prevent this from ever happening in our current model.

Currently the contstraint is "if the device is open, you can't deactivate 
it". I'd like change it to "if the device is open or some of its snapshots 
are open, you can't deactivate it".

Even without merging, the current approach is not perfect, as you will end 
up with a device that you can't deactivate (the origin is deactivated, the 
snapshot is active; lvchange -an on the snapshot will return error; 
lvchange -an on the origin will see that it is already inactive and do 
nothing)

> The code "does its best" to do what you asked.  Sure, we could try to
> add more checks before deactivating and make the process more
> robust, but I'd draw the line at attempting to reactivate already-deactivated
> devices in the event of a failure part way through.
>
> Alasdair
> -- 
> agk at redhat.com

Mikulas


