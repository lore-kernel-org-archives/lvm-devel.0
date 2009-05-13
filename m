From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 13 May 2009 08:55:09 -0400
Subject: Re: vgimportclone: script to import SAN snapshots and clones
In-Reply-To: <20090513023333.GD10652@agk-dp.fab.redhat.com>
References: <1242168445-30898-1-git-send-email-snitzer@redhat.com>
	<20090513023333.GD10652@agk-dp.fab.redhat.com>
Message-ID: <20090513125508.GB2267@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, May 12 2009 at 10:33pm -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Tue, May 12, 2009 at 06:47:25PM -0400, Mike Snitzer wrote:
> > Revised vgimportclone that should be ready for inclussion in the LVM2
> > tree.

I was certainly mistaken with that statement :)

I'll sort out all of your comments and repost.

> > +            exec 2> ./${SCRIPTNAME}.log
> 
> Errr ./ ???  What directory are we in and what file might we be clobbering?
> (Security blocker.)  Better to retain output from earlier runs too and
> ensure there's a timestamp of the run somewhere (cf. lvmdump).

Yes, this DEBUG functionality is not safe at all; not sure how I missed
this.

Mike


