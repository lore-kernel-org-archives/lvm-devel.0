From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 15 May 2008 00:43:08 +0100
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
	<20080514223205.GM10723@agk.fab.redhat.com>
	<Pine.LNX.4.64.0805141919200.843@engineering.redhat.com>
Message-ID: <20080514234308.GQ10723@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 14, 2008 at 07:30:17PM -0400, Mikulas Patocka wrote:
> With merging, it will cause corruption --- if one snapshot is merging and 
> you don't have all the other snapshots loaded, the non-active snapshots 
> won't be updated as the merging goes on. So they'll be corrupted.
 
If that can happen it suggests the detailed set of activation steps needs
further refining and is not correct yet.

> Currently the contstraint is "if the device is open, you can't deactivate 
> it". I'd like change it to "if the device is open or some of its snapshots 
> are open, you can't deactivate it".

Catch-22 then.  Which do you deactivate first?  We cannot handle that
at kernel level with the current interface.

But by all means add that extra protection to the userspace code.
The userspace code should not assume it happened though.

> Even without merging, the current approach is not perfect, as you will end 
> up with a device that you can't deactivate (the origin is deactivated, the 
> snapshot is active; lvchange -an on the snapshot will return error; 
> lvchange -an on the origin will see that it is already inactive and do 
> nothing)

That can be fixed: lvchange -an on the origin should complete the process.
(It probably used to do that before some optimisation got added.)
 
Alasdair
-- 
agk at redhat.com


