From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 8 Feb 2010 10:09:11 -0500
Subject: Suppress locking initialisation failure messages when --ignorelockingfailure is used
In-Reply-To: <4B7027F4.6090307@redhat.com>
References: <4B700EDC.7020505@redhat.com> <4B701284.1030606@redhat.com>
	<20100208134605.GA16433@redhat.com> <4B702169.2000405@redhat.com>
	<20100208145515.GB20595@redhat.com> <4B7027F4.6090307@redhat.com>
Message-ID: <20100208150911.GA24305@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 08 2010 at 10:04am -0500,
Milan Broz <mbroz@redhat.com> wrote:

> On 02/08/2010 03:55 PM, Mike Snitzer wrote:
> > On Mon, Feb 08 2010 at  9:36am -0500,
> > Peter Rajnoha <prajnoha@redhat.com> wrote:
> > 
> >> On 02/08/2010 02:46 PM, Mike Snitzer wrote:
> >>>
> >>> Dracut is rw but we (dracut's lvm hooks) impose read-only locking
> >>> through dracut's lvm.conf.  This was done so no metadata updates could
> >>> occur within the initramfs environment.
> >>
> >> Yes, dracut environment is rw but the root fs itself is mounted ro first.
> >> The "vgchange -a y --ignorelockingfailure" (that is called after the pivotroot)
> >> is run just before the rw remount happens (..looking at Fedora/RHEL6 rc.sysinit).
> >>
> >> We didn't notice that directly before, because init_locking silently "failed"
> >> (but returned with OK status from init_locking fn, since --ignorelockingfailure is set).
> > 
> > Shouldn't rc.sysinit's "vgchange -a y --ignorelockingfailure" come
> > _after_ root's rw remount?
> 
> Exactly. It should also start volume monitoring etc.
> 
> Note that monitoring need rw access (at least for status log to syslog,
> but also if it triggers some change, it will require real lock - to perform
> repair, snapshot resize or other action; metadata backups etc).

The monitoring gets started, by the "lvm2-monitor" service, after
rc.sysinit.  So we should be fine there.

> I think that the sequence is broken and we should not paper over it by
> disabling the error message.

Agreed, the sequence is broken in rc.sysinit.

Mike


