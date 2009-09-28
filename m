From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 28 Sep 2009 10:37:54 -0400
Subject: Re: [PATCH 2/3] differentiate between S.I. and binary units in output
In-Reply-To: <20090928142531.GF5351@agk-dp.fab.redhat.com>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
	<1253979227-28051-2-git-send-email-impulze@impulze.org>
	<20090928124906.GD5351@agk-dp.fab.redhat.com>
	<20090928131758.GA26763@redhat.com>
	<20090928142531.GF5351@agk-dp.fab.redhat.com>
Message-ID: <20090928143753.GA26974@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 28 2009 at 10:25am -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Mon, Sep 28, 2009 at 09:17:59AM -0400, Mike Snitzer wrote:
> > I agree that 500-byte sectors aren't meaningful but I added support for
> > them a few months ago to be consistent, see:
> > http://sources.redhat.com/git/?p=lvm2.git;a=commit;h=69da2ac0
> 
> Where's that in WHATS_NEW?
> 
> I'll probably take it back out: I can't think of any reason for supporting it
> and confusing people.

Right, I agree that confusing people isn't good.. but I thought it
better to allow people to specify 'S' without erroring out.

As for WHATS_NEW; I added the following to the 2.02.49 release:
Update the man pages to document size units uniformly.
Allow commandline sizes to be specified in terms of bytes and sectors.

If you do back it out please still allow 's'; it is needed for pvcreate
--dataalignmentoffset 

But as we discussed, its probably best if both 's' and 'S' mean 512
bytes.

Mike


