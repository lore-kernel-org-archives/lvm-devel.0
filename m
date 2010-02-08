From: David Zeuthen <david@fubar.dk>
Date: Mon, 08 Feb 2010 13:23:33 -0500
Subject: [PATCH 0/3] yum-utils: fs-snapshot support for LVM snapshots
In-Reply-To: <20100208144010.GA20595@redhat.com>
References: <1265181124-2492-1-git-send-email-snitzer@redhat.com>
	<m3k4uujak6.fsf@pullcord.laptop.org>
	<20100208144010.GA20595@redhat.com>
Message-ID: <1265653413.2721.10.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-02-08 at 09:40 -0500, Mike Snitzer wrote:
> > It'd be good to have your input on the gnome-disk-utility UI for
> > snapshots too, now that we'll have more than one user for it -- we're
> > discussing at:
> > 
> > https://bugzilla.gnome.org/show_bug.cgi?id=608204
> > http://bugs.freedesktop.org/show_bug.cgi?id=26258
> 
> I'm open to helping answer any questions David might have, and making
> any lvm changes needed to assist his effort, once he has time to look at
> gnome-disk-utility's snapshot integration (via lvm and btrfs).
> 
> It would be nice if gnome-disk-utility knew to treat LVM snapshot LVs
> that have a "yum_<date>" tag as being part of a "system rollback point"
> or some such.  But I'm not sure of the best way for David to
> programatically (or via lvm utility) access a snapshot LV's lvm tag(s).
> A stop-gap would be to just rely on the suffix of the LV name to end
> with: "_yum_<date>" (but that is fairly crude!)

I think some kind of "system restore/rollback point" functionality is a
good idea. 

I'm not sure, however, that Palimpsest should be the UI (it's a disk
utility, first and foremost) for this - it sounds like it might be
better to do a dedicated system-config-restorepoint program for this. I
don't know. That said, I think we still might want to display a list of
snapshots in Palimpsest for both LVM and btrfs - and with good naming
maybe that UI is good enough for rollback purposes and we don't need a
s-c-restorepoint. I don't know.

Regarding the LVM tags (which we'd also like to display and allow the
user to edit), I've already filed a bug asking for something like

 char **lvm_vg_get_tags(const vg_t vg);
 char **lvm_lv_get_tags(const lv_t lv);
 char **lvm_pv_get_tags(const pv_t pv);

in liblvm2app.

Thanks,
David



