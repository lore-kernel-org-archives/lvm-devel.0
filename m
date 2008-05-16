From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 May 2008 15:37:25 +0100
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <Pine.LNX.4.64.0805161010500.27053@engineering.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
	<20080514234308.GQ10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805142017580.12073@engineering.redhat.com>
	<20080515111734.GS10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805161010500.27053@engineering.redhat.com>
Message-ID: <20080516143725.GW10723@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 16, 2008 at 10:21:37AM -0400, Mikulas Patocka wrote:
> The change in the patch is safe because when someone is creating snapshot 
> and simultaneously writing to the origin device, it is unspecified, which 
> write requests trigger reallocations in the snapshot and which not.
 
That isn't relevant: What matters is that any filesystem on the origin
LV is quiesced first.

Sequence is:
  perform necessary memory allocations (snapshot ctr)
  suspend origin LV (quiesce filesystem)
  resume snapshots so that changes start to be tracked (sets active = 1)
  resume origin (resumes filesystem)

> I found another problem --- the lvchange -an is currently safe, but it is 
> unsafe with snapshot merging. Ideally it should suspend all the devices 
> first and then call destructors on the snapshots. I'll look at it.

Again, this points to the interface not being right yet.
 
Alasdair
-- 
agk at redhat.com


