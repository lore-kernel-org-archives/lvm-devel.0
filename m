From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 3 Aug 2010 12:18:58 +0100
Subject: Bug? in allocation of pvs in a striped mirror using lvcreate
In-Reply-To: <201008021918.15547.benscott@nwlink.com>
References: <20100802210742.27320.qmail@sourceware.org>
	<201008021918.15547.benscott@nwlink.com>
Message-ID: <20100803111858.GF18149@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 02, 2010 at 07:18:15PM -0700, ben wrote:
> I was experimenting with lvs and ran the following lvcreate command. The issue is 
> that at least two physical volumes are spread between mirrors. Devices /dev/sdb5 
> and /dev/sdb6 are part of both lvol0_mimage_0 and lvol0_mimage_1. I tried diffent
> "-alloc" values but nothing changed. In my testing I had all the pvs on one drive
> but of course I wouldn't do that on a real server.
 
It's going to take a while to improve the layouts it picks.  There are some
missing policies we still need.

But it's worth experimenting with different ways of creating the device.
E.g. Starting with a shorter device and extending it; or starting with a
striped device and turning it into a mirror; specifying which PVs to use on the
command line.

There's normally a way to get the layout you want, but if all else fails,
you can fix it up by hand (backup, edit, restore).

Alasdair


