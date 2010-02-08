From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 8 Feb 2010 09:55:15 -0500
Subject: Suppress locking initialisation failure messages when --ignorelockingfailure is used
In-Reply-To: <4B702169.2000405@redhat.com>
References: <4B700EDC.7020505@redhat.com> <4B701284.1030606@redhat.com>
	<20100208134605.GA16433@redhat.com> <4B702169.2000405@redhat.com>
Message-ID: <20100208145515.GB20595@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 08 2010 at  9:36am -0500,
Peter Rajnoha <prajnoha@redhat.com> wrote:

> On 02/08/2010 02:46 PM, Mike Snitzer wrote:
> > 
> > Dracut is rw but we (dracut's lvm hooks) impose read-only locking
> > through dracut's lvm.conf.  This was done so no metadata updates could
> > occur within the initramfs environment.
> 
> Yes, dracut environment is rw but the root fs itself is mounted ro first.
> The "vgchange -a y --ignorelockingfailure" (that is called after the pivotroot)
> is run just before the rw remount happens (..looking at Fedora/RHEL6 rc.sysinit).
> 
> We didn't notice that directly before, because init_locking silently "failed"
> (but returned with OK status from init_locking fn, since --ignorelockingfailure is set).

Shouldn't rc.sysinit's "vgchange -a y --ignorelockingfailure" come
_after_ root's rw remount?

Dracut has already taken care of activating any LVs needed for the root
FS.  What advantage is there in trying to activate other (non-root) LVs
before root is rw?

Mike


