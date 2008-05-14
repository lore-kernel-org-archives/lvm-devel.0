From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 14 May 2008 23:32:05 +0100
Subject: Re: Deactivating volume with mounted snapshot
In-Reply-To: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
References: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
Message-ID: <20080514223205.GM10723@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 14, 2008 at 04:28:09PM -0400, Mikulas Patocka wrote:
> Now you mount one of the snapshots. And then, type:
> lvchange -an volume
> --- the result is, that the volume and all the snapshots except the 
> mounted one are deactivated. The mounted snapshot is still active.

> It looks like a bug to me --- it was never indented to have some snapshots 
> active and some not. 

This does *not* of course lead to corruption: it's a constraint we
chose to have LVM2 impose, not device-mapper.

It's not a perfect constraint as you discovered because it would be
impossible to prevent this from ever happening in our current model.

The code "does its best" to do what you asked.  Sure, we could try to
add more checks before deactivating and make the process more
robust, but I'd draw the line at attempting to reactivate already-deactivated
devices in the event of a failure part way through.

Alasdair
-- 
agk at redhat.com


