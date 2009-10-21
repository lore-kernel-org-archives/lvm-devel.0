From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 21 Oct 2009 17:05:42 -0500
Subject: [PATCH] Enable (already implemented?) snapshots of mirrors
In-Reply-To: <20091021130847.GB10165@agk-dp.fab.redhat.com>
References: <1255637948.16495.26.camel@hydrogen.msp.redhat.com>
	<20091021130847.GB10165@agk-dp.fab.redhat.com>
Message-ID: <13B333BC-2DD2-4176-8AD9-73FE0AFC2A27@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Oct 21, 2009, at 8:08 AM, Alasdair G Kergon wrote:

> On Thu, Oct 15, 2009 at 03:19:08PM -0500, Jon Brassow wrote:
>> I just wanted to get a feel for where things were at WRT snapshots of
>> mirrors.  Pulling out the prevention check (patch provided below),
>> things seem to work just fine.  Is there something I am missing?
>
> Well the check was inserted because the code was untested.
>
> All the newly-possible combinations of commands need to be tested  
> before
> it can be removed, and other 'unsupported' messages can be placed
> where things don't work correctly.
>
> (Basically you check through all the options of all the commands
> one-by-one and test every aspect which might behave differently
> in respect of snapshots of mirrors.  This includes checking the  
> dmeventd
> plugins as well as 'partial' VGs, and ensuring there are no ways of
> manipulating the 'in-use' mirror that conflict with the fact it is
> an origin, and ensuring display tools remain comprehensible.)

Ok, I'll get things started.  You can tell me if I miss anything.(?)

lvcreate:
+ snapshot of mirror

lvresize:
+ grow the mirror origin (but only if inactive)
+ grow the snapshot exception store
+ Warning message given when trying to shrink origin
+ able to shrink exception store (warning is given and asks to proceed)

lvchange:
+ '-an <origin>' deactivates origin and all snapshots
+ '-ay <origin>' activates origin and all snapshots

lvconvert:
+ Error message notifying you cannot convert an LV under a snapshot  
(this could be removed?)

dmeventd:
- since you can't convert an lv under a snapshot, you cannot repair a  
mirror when a device fails

So far, it seems like the 'dmeventd' issue must be fixed before a  
possible check-in.

  brassow


