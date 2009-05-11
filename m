From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 11 May 2009 02:30:29 +0100
Subject: [PATCH 2/7] Never set mirror log and images directly visible in metadata.
In-Reply-To: <874ovsu5ff.fsf@eriador.mornfall.net>
References: <cover.1241620083.git.mbroz@redhat.com>
	<cover.1241620083.git.mbroz@redhat.com>
	<a3d0392fa15ad5ecbc874cb5419a0177011655ed.1241620083.git.mbroz@redhat.com>
	<87my9ku7t9.fsf@eriador.mornfall.net> <4A07202D.1010903@redhat.com>
	<874ovsu5ff.fsf@eriador.mornfall.net>
Message-ID: <20090511013029.GA7680@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, May 10, 2009 at 09:24:52PM +0200, Peter Rockai wrote:
> Milan Broz <mbroz@redhat.com> writes:
> > Maybe we should display these "invisible" LVs to user (in reporting commands)
> > if no visible LV references them (I mean _mimage, _mlog & Co. devices)
> Sounds like a decent solution to me.

But then - what's our definition of visible? - and we're back to the original
counting problem with multiple confusing definitions.

Can we really not consolidate this into a single definition?

(BTW max_lv etc. is not a factor that skew other policy decisions - it's an 
unimportant feature.)

Alasdair


