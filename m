From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 8 Feb 2010 09:40:10 -0500
Subject: [PATCH 0/3] yum-utils: fs-snapshot support for LVM snapshots
In-Reply-To: <m3k4uujak6.fsf@pullcord.laptop.org>
References: <1265181124-2492-1-git-send-email-snitzer@redhat.com>
	<m3k4uujak6.fsf@pullcord.laptop.org>
Message-ID: <20100208144010.GA20595@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 03 2010 at  4:04pm -0500,
Chris Ball <cjb@laptop.org> wrote:

> Hi Mike,
> 
>    > It is my hope that these changes can still make F13 as part of
>    > the "System Rollback" feature.  The existing project Feature page
>    > could be extended to include LVM snapshot information:
>    > http://fedoraproject.org/wiki/Features/SystemRollbackWithBtrfs
>    
> Sounds fine to me.

What steps should we be taking now?

For starters we need to get rawhide's yum-utils updated to include the
latest fs-snapshot plugin updates that are now upstream.

Who should update the SystemRollbackWithBtrfs page?  Or should we create
a new SystemRollbackWithLvm page that is linked to from
SystemRollbackWithBtrfs?

> It'd be good to have your input on the gnome-disk-utility UI for
> snapshots too, now that we'll have more than one user for it -- we're
> discussing at:
> 
> https://bugzilla.gnome.org/show_bug.cgi?id=608204
> http://bugs.freedesktop.org/show_bug.cgi?id=26258

I'm open to helping answer any questions David might have, and making
any lvm changes needed to assist his effort, once he has time to look at
gnome-disk-utility's snapshot integration (via lvm and btrfs).

It would be nice if gnome-disk-utility knew to treat LVM snapshot LVs
that have a "yum_<date>" tag as being part of a "system rollback point"
or some such.  But I'm not sure of the best way for David to
programatically (or via lvm utility) access a snapshot LV's lvm tag(s).
A stop-gap would be to just rely on the suffix of the LV name to end
with: "_yum_<date>" (but that is fairly crude!)

Mike


