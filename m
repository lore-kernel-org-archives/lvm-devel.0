From: Chris Ball <cjb@laptop.org>
Date: Mon, 08 Feb 2010 14:26:37 -0500
Subject: [PATCH 0/3] yum-utils: fs-snapshot support for LVM snapshots
In-Reply-To: <1265653413.2721.10.camel@localhost.localdomain> (David Zeuthen's
	message of "Mon, 08 Feb 2010 13:23:33 -0500")
References: <1265181124-2492-1-git-send-email-snitzer@redhat.com>
	<m3k4uujak6.fsf@pullcord.laptop.org>
	<20100208144010.GA20595@redhat.com>
	<1265653413.2721.10.camel@localhost.localdomain>
Message-ID: <m3k4un4jgy.fsf@pullcord.laptop.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

   > I think some kind of "system restore/rollback point"
   > functionality is a good idea.
   > 
   > I'm not sure, however, that Palimpsest should be the UI (it's a
   > disk utility, first and foremost) for this - it sounds like it
   > might be better to do a dedicated system-config-restorepoint
   > program for this. I don't know. That said, I think we still might
   > want to display a list of snapshots in Palimpsest for both LVM
   > and btrfs - and with good naming maybe that UI is good enough for
   > rollback purposes and we don't need a s-c-restorepoint. I don't
   > know.

Ray Strode's suggestion was to please *not* create a new s-c utility
and instead look into Palimpsest.  :)

The argument for putting it in Palimpsest, which I'm quite convinced
by, is that this is a feature that's being exposed to userspace by
filesystems (btrfs will provide its own command-line interface), and
it's appropriate and useful for Palimpsest to provide a unified GUI
for filesystem operations.  It already does that for label-setting,
fsck, resize, and so on.  Switching or creating an active snapshot
becomes just another operation.

.. but I'm happy to take on creating a system-config-snapshots if it's
preferred -- it was actually part of the first version of the rollback
proposal, before we moved towards g-d-u instead.  (If we did go with
that, I think it would make sense to tell udisks about snapshot
management and then base it on that, perhaps with some new Python
bindings for the udisks dbus interface.  Make sense?)

Thanks,

- Chris.
-- 
Chris Ball   <cjb@laptop.org>
One Laptop Per Child


