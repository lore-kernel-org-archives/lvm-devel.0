From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 14 May 2009 00:33:32 -0400
Subject: Re: [PATCH v2] vgimportclone: script to import SAN snapshots and clones
In-Reply-To: <20090514002822.GD25793@agk-dp.fab.redhat.com>
References: <1242253944-502-1-git-send-email-snitzer@redhat.com>
	<20090514002822.GD25793@agk-dp.fab.redhat.com>
Message-ID: <20090514043332.GA3032@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, May 13 2009 at  8:28pm -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> > +.I \-n|\-\-basevgname VolumeGroupName
> > +By default the snapshot VG will be renamed to the original name plus a
> > +numeric suffix to avoid duplicate naming (e.g. 'test_vg' would be renamed
> > +to 'test_vg.1').  This option will override the base VG name that is
> 
> I'm not keen on the dot in there.  We don't put dots in any other names.
> I'm not keen on names like /dev/test_vg.1/lvol01

I just went with what Chris provided; didn't have strong feelings but I
agree the dot is somewhat awkward.  I'll drop the dot.

The dot aside; the getvgname() function needs some help as it lacks
self-understanding of the fact that it produces ${BASE}$I names; and
testvg1 will match testvg11 so testvg2 will be tried, testvg2 will match
testvg26 so testvg3 will be tried, etc.

In the expected sequential case of 'vgimportclone'ing N clones it
wouldn't be a problem but...

> I hate to go on about security, but have you tested that the script does not
> misbehave even when you give it a PV with the nastiest set of characters you
> can imagine in it?

I have not personally tested with nasty names but Chris did based on my
feedback that PV names like the following are technically valid:
pv_ugly="__\"!@#\$%^&*,()|@||'\\\"__pv1"

Chris contributed the code that symlinks the specified PV to
$TMP_LVM_SYSTEM_DIR/vgimportX.

But I'll go over it.  Are you concerned about security or functionality?
Or both?

Chris anything to add here?

> Might as well check this in now, anyway, and deal with any more things people file
> in-tree.

OK, I'll fix the other things you mentioned and do so.

Mike


