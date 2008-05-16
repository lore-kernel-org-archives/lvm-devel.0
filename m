From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 16 May 2008 10:21:37 -0400 (EDT)
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <20080515111734.GS10723@agk.fab.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
	<20080514234308.GQ10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805142017580.12073@engineering.redhat.com>
	<20080515111734.GS10723@agk.fab.redhat.com>
Message-ID: <Pine.LNX.4.64.0805161010500.27053@engineering.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Thu, 15 May 2008, Alasdair G Kergon wrote:

> On Wed, May 14, 2008 at 08:33:27PM -0400, Mikulas Patocka wrote:
>> Basically, lvm suspends all the devices, then loads the dm table for all
>> of them and then resumes them.
>
> Not strictly accurate.
>
> You need to consider each case separately:
>
>  taking existing LV and adding/removing first snapshot
>  adding/removing a subsequent snapshot
>  activating/deactivating LV plus pre-existing snapshots
>
> and note the sequence of significant events in each case:
>  table loaded
>  snapshot metadata read from disk
>  filesystem quiesced
>  snapshot becoming active
>  etc.
>
> Then you'd need to show that removing 'active = 1' retains correctness
> in every case.  I am not convinced: Consider the case of adding a
> subsequent snapshot: preload table does mem allocations, then suspend
> existing LV & quiesce fs, then resume snapshot (active = 1 now) etc.
>
> Alasdair
> -- 
> agk at redhat.com

I put a printk points at ctr/dtr/suspend/resume functions into origin and 
snapshot and observed their calls when activating/deactivating, 
adding/removing a snapshot and adding/removing the first/last snapshot.

Because "active" variable was never reset to zero, it had effect only 
between snapshot ctr (set to 0) and snapshot resume (set to 1). When it 
was set to 0, the snapshot didn't allocate exceptions. After the patch, 
the snapshot always allocates exceptions (between snapshot ctr and 
snapshot dtr calls).

The change in the patch is safe because when someone is creating snapshot 
and simultaneously writing to the origin device, it is unspecified, which 
write requests trigger reallocations in the snapshot and which not.


I found another problem --- the lvchange -an is currently safe, but it is 
unsafe with snapshot merging. Ideally it should suspend all the devices 
first and then call destructors on the snapshots. I'll look at it.

Mikulas


lvchange -ay:
origin ctr: 254:4
snapshot ctr 254:4 254:6
snapshot ctr 254:4 254:8
origin resume: 254:4 254:6
origin resume: 254:4 254:8
origin resume: 254:4

lvchange -an:
origin suspend: 254:4
origin dtr: 254:4
snapshot suspend: 254:4 254:6
snapshot dtr 254:4 254:6
snapshot suspend: 254:4 254:8
snapshot dtr 254:4 254:8

lvcreate snapshot:
snapshot ctr 254:4 254:11
origin suspend: 254:4
snapshot suspend: 254:4 254:6
snapshot suspend: 254:4 254:8
snapshot resume: 254:4 254:6
snapshot resume: 254:4 254:8
snapshot resume: 254:4 254:11
origin resume: 254:4

lvremove snapshot:
snapshot suspend: 254:4 254:11
snapshot dtr 254:4 254:11

lvcreate, adding the first snapshot:
origin ctr: 254:12
snapshot ctr 254:12 254:13
snapshot resume: 254:12 254:13
origin resume: 254:12

lvremove, removing the last snapshot:
snapshot suspend: 254:12 254:13
snapshot dtr 254:12 254:13
origin suspend: 254:12
origin dtr: 254:12


