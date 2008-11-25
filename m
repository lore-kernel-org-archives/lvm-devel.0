From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 25 Nov 2008 16:14:36 -0500
Subject: [PATCH] (6/11) re-introduce vg_read
In-Reply-To: <87vdud6sdm.fsf@eriador.mornfall.net>
References: <87abcm3qi3.fsf@eriador.mornfall.net>
	<1227499182.6608.20.camel@localhost.localdomain>
	<87vdud6sdm.fsf@eriador.mornfall.net>
Message-ID: <1227647676.8335.63.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Mon, 2008-11-24 at 16:44 +0100, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> > It is a little confusing have a vg_read_for_update() (only intended for
> > WRITE) and a generic vg_read() (that allows both READ/WRITE) in the same
> > API.  Should we have "vg_read_for_update()" (WRITE) and
> > vg_read_for_query()" (READ) or something like that?
> Well, is it? I tend to think about it like "select", and "select for update" in
> SQL, although the analogy is not 100 % correct, I know. But I intended
> vg_read_for_update as a convenience function that obviously points out that you
> intend to update the VG (as opposed to just read it).
> 
> But, I suppose it's a bikeshed point. We however still want a generic vg_read,
> for the iterator functions (in toollib) which need to pass a flag to
> differentiate the read/write case.
> 

I liked the explicit read_for_update idea.

My main concern is app writer confusion.  Shouldn't they expect a
uniform API (one API for obtaining read access, one for write access)?
Don't you think someone not familiar with internals of LVM will ponder
this?




