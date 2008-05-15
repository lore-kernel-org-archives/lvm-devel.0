From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 15 May 2008 12:17:35 +0100
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <Pine.LNX.4.64.0805142017580.12073@engineering.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
	<20080514234308.GQ10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805142017580.12073@engineering.redhat.com>
Message-ID: <20080515111734.GS10723@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 14, 2008 at 08:33:27PM -0400, Mikulas Patocka wrote:
> Basically, lvm suspends all the devices, then loads the dm table for all 
> of them and then resumes them.
 
Not strictly accurate.

You need to consider each case separately: 

  taking existing LV and adding/removing first snapshot
  adding/removing a subsequent snapshot
  activating/deactivating LV plus pre-existing snapshots

and note the sequence of significant events in each case:
  table loaded
  snapshot metadata read from disk
  filesystem quiesced
  snapshot becoming active
  etc.

Then you'd need to show that removing 'active = 1' retains correctness
in every case.  I am not convinced: Consider the case of adding a
subsequent snapshot: preload table does mem allocations, then suspend
existing LV & quiesce fs, then resume snapshot (active = 1 now) etc.
 
Alasdair
-- 
agk at redhat.com


