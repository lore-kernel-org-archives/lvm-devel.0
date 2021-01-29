From: David Teigland <teigland@redhat.com>
Date: Fri, 29 Jan 2021 11:34:44 -0600
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
	<fb6bb401-8641-1d3b-800b-b35fd1acf04d@redhat.com>
	<968c9f098c342091aa041a61caadcffb3e2434d4.camel@suse.com>
Message-ID: <20210129173444.GB7644@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 29, 2021 at 02:02:11PM +0100, Martin Wilck wrote:
> LVM filters are hard to get right, even for experienced admins. Not
> because of the regexes, but because of the many different names under
> which devices appear under /dev. Telling admins that they need to
> fiddle with filter rules just to make multipath work sounds like
> something I'd have said 10 years ago, but not in 2021.

I agree.

> > There will be also a new 'filtering' introduced in a form a basic
> > acceptance 
> > list of devices - that may be seen in some cases as more simple to
> > use.
> 
> Perhaps this will improve matters, perhaps it'll add more confusion.?
> I don't know enough to tell.

The filter problems, among many others, were the motivation to create a
new feature "devices file" which I'm planning to merge into lvm soon.

Latest devel branch (see latest -N suffix):
https://sourceware.org/git/?p=lvm2.git;a=shortlog;h=refs/heads/dev-dct-devicesid-22

The basic idea is that a new lvm config file (the devices file) lists the
devices that lvm can use, and lvm will not even look at devices outside
that list.  So the user tells lvm which devices it should use, and that's
all lvm sees.  (With an optional allowance for pvcreate to implicitly mean
"use this device", to make it easier for people to begin using this.)

The devices are primarily identified by a WWID, or other similar
identifier.  lvm commands are used manage that file, but it can be
manually edited also.  It replaces filters, and will make a number of hard
problems in lvm just go away:  the problem of unstable dev names in
filters goes away, mpath/md component detection goes away (you wouldn't
include component devs in the device file), the system mistakenly
activating PVs belonging to VMs goes away.

This is obviously not an immediate solution to the problems you're having,
but it's what we have in mind as the best solution, available fairly soon.
For immediate fixes I still think native detection supplemented with udev
or other info is ideal.  Don't feel constrained by the old definitions of
config settings - those config settings can be superceded by new ones.

The new devices file code, even when the devices file is not enabled, will
make it easier to consume /etc/multipath/wwids (since the devices file is
using wwids itself).  So we can begin improving mpath component detection
before users enable the devices file.

Dave


