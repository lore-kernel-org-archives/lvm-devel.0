From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 16 May 2008 11:00:03 -0400 (EDT)
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <Pine.LNX.4.64.0805161032390.27053@engineering.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
	<20080514234308.GQ10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805142017580.12073@engineering.redhat.com>
	<20080515111734.GS10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805161010500.27053@engineering.redhat.com>
	<Pine.LNX.4.64.0805161032390.27053@engineering.redhat.com>
Message-ID: <Pine.LNX.4.64.0805161051450.7712@engineering.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 16 May 2008, Mikulas Patocka wrote:

>> I put a printk points at ctr/dtr/suspend/resume functions into origin and 
>> snapshot and observed their calls when activating/deactivating, 
>> adding/removing a snapshot and adding/removing the first/last snapshot.
>> 
>> Because "active" variable was never reset to zero, it had effect only 
>> between snapshot ctr (set to 0) and snapshot resume (set to 1). When it was 
>> set to 0, the snapshot didn't allocate exceptions. After the patch, the 
>> snapshot always allocates exceptions (between snapshot ctr and snapshot dtr 
>> calls).
>> 
>> The change in the patch is safe because when someone is creating snapshot 
>> and simultaneously writing to the origin device, it is unspecified, which 
>> write requests trigger reallocations in the snapshot and which not.
>
> Milan said that there is xfs freeze called between that (it is called just 
> before origin suspend) --- and it's fact that dropping an "active" variable 
> would make unclean snapshot on xfs.
>
> So I'll change it so that no exceptions are reallocated if active is zero and 
> the exception store is empty. That will make both xfs freeze and snapshot 
> merging safe.
>
> Mikulas

... or maybe the best method would be to not merge if the origin is not in 
resumed state. That would solve all the possible problems with interaction 
with userspace. It needs some changing of the structures (making the 
snapshots point to the origin device), but I intended to do it anyway. 
Calling read_lock and __lookup_origin each time something needs doesn't 
seem nice to me and I'd like to replace this with a pointer.

Mikulas


