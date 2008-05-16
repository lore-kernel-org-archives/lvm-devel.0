From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 16 May 2008 10:42:04 -0400 (EDT)
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <Pine.LNX.4.64.0805161010500.27053@engineering.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
	<20080514234308.GQ10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805142017580.12073@engineering.redhat.com>
	<20080515111734.GS10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805161010500.27053@engineering.redhat.com>
Message-ID: <Pine.LNX.4.64.0805161032390.27053@engineering.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> I put a printk points at ctr/dtr/suspend/resume functions into origin and 
> snapshot and observed their calls when activating/deactivating, 
> adding/removing a snapshot and adding/removing the first/last snapshot.
>
> Because "active" variable was never reset to zero, it had effect only between 
> snapshot ctr (set to 0) and snapshot resume (set to 1). When it was set to 0, 
> the snapshot didn't allocate exceptions. After the patch, the snapshot always 
> allocates exceptions (between snapshot ctr and snapshot dtr calls).
>
> The change in the patch is safe because when someone is creating snapshot and 
> simultaneously writing to the origin device, it is unspecified, which write 
> requests trigger reallocations in the snapshot and which not.

Milan said that there is xfs freeze called between that (it is called just 
before origin suspend) --- and it's fact that dropping an "active" 
variable would make unclean snapshot on xfs.

So I'll change it so that no exceptions are reallocated if active is zero 
and the exception store is empty. That will make both xfs freeze and 
snapshot merging safe.

Mikulas

> I found another problem --- the lvchange -an is currently safe, but it is 
> unsafe with snapshot merging. Ideally it should suspend all the devices first 
> and then call destructors on the snapshots. I'll look at it.
>
> Mikulas

> lvchange -ay:
> origin ctr: 254:4
> snapshot ctr 254:4 254:6
> snapshot ctr 254:4 254:8
> origin resume: 254:4 254:6
> origin resume: 254:4 254:8
> origin resume: 254:4
>
> lvchange -an:
> origin suspend: 254:4
> origin dtr: 254:4
> snapshot suspend: 254:4 254:6
> snapshot dtr 254:4 254:6
> snapshot suspend: 254:4 254:8
> snapshot dtr 254:4 254:8
>
> lvcreate snapshot:
> snapshot ctr 254:4 254:11
> origin suspend: 254:4
> snapshot suspend: 254:4 254:6
> snapshot suspend: 254:4 254:8
> snapshot resume: 254:4 254:6
> snapshot resume: 254:4 254:8
> snapshot resume: 254:4 254:11
> origin resume: 254:4
>
> lvremove snapshot:
> snapshot suspend: 254:4 254:11
> snapshot dtr 254:4 254:11
>
> lvcreate, adding the first snapshot:
> origin ctr: 254:12
> snapshot ctr 254:12 254:13
> snapshot resume: 254:12 254:13
> origin resume: 254:12
>
> lvremove, removing the last snapshot:
> snapshot suspend: 254:12 254:13
> snapshot dtr 254:12 254:13
> origin suspend: 254:12
> origin dtr: 254:12
>
>


