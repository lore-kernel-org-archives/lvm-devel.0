From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun, 30 Nov 2008 09:31:47 -0500
Subject: [PATCH 4/4] Update vgcreate and vgextend to allow uninitialized devices as input.
In-Reply-To: <20081130041850.GE13235@agk.fab.redhat.com>
References: <1227992553-4381-1-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-2-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-3-git-send-email-dwysocha@redhat.com>
	<1227992553-4381-4-git-send-email-dwysocha@redhat.com>
	<20081130041850.GE13235@agk.fab.redhat.com>
Message-ID: <1228055507.3315.14.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Sun, 2008-11-30 at 04:18 +0000, Alasdair G Kergon wrote:
> Why not just add all the relevant pvcreate parameters to those commands?

I thought it would clutter the commands unnecessarily for options that
were seldom used.  I will work on a patch for adding the parameters
though since it sounds like that is what you would like.

> And any prompting should be identical to how pvcreate itself behaves.
> - If you want a prompt to say 'we are running pvcreate implcitly here'
> until people get used to the new behaviour, then make it a config option that
> people can disable.
> 
So you don't think there is danger in just switching to the new behavior
(used to be an error to vgcreate/vgextend with non-initialized disk, now
will initialized the disk) without a transition period?  The case I was
thinking of was a user that inadvertently specified the wrong disk.  The
pvcreate code will catch at least some of the cases but perhaps not
others.  It is now a destructive operation whereas before it was not.

> This *will* be the default in future - most people will not use pvcreate
> at all.  Think of it from the point of view of a newcomer to lvm - no need
> to learn about PVs in order to set up and use lvm.
> 
Right.  I was just wondering about the transition period and whether we
would deprecate pvcreate in the future.  If not, then why not just leave
vgextend/vgcreate without the pvcreate options and make the less-likely
user pay the penalty?


