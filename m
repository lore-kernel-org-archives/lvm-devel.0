From: Martin Wilck <mwilck@suse.com>
Date: Fri, 29 Jan 2021 19:13:11 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <20210129165954.GA7644@redhat.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
	<e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
	<20210129165954.GA7644@redhat.com>
Message-ID: <0a43c2ec60033a0edb0485267bc6ea37d3d9b346.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2021-01-29 at 10:59 -0600, David Teigland wrote:
> 
> Hi Martin, thanks for the patch, it looked obviously correct on first
> glance, but with this discussion perhaps I missed something, so I'll
> have
> to go back and look again.
> 
> On Fri, Jan 29, 2021 at 11:07:12AM +0100, Martin Wilck wrote:
> > Of course *udev* works "in my main system". But *LVM2* does not:
> > with
> > the default setting "external_device_info_source=none", it ignores
> > udev
> > properties of devices. This is the source of lots of subtle errors
> > and
> > race conditions during device setup. Therefore we changed the
> > setting
> > to "udev".
> > 
> > How do you handle that in Fedora? I took the liberty to look at the
> > Fedora 33 package, and it doesn't change default from "none" to
> > "udev".?So by common sense, Fedora is going to suffer from the same
> > general problem that (open)SUSE sees: With "none", lvm can detect
> > multipath or MD components only "after the fact", i.e. after
> > multipathd
> > or mdadm have grabbed them already. If pvscan and multipathd start
> > up
> > simultaneously, it's anyones guess who "wins" (*). With "udev",
> > that
> > can't happen, and that's why "udev" should be made the default.
> 
> You're right that it's extremely fragile, and we rely on the complex
> systemd/udev/rules/etc machinery for all the components to work just
> right.? Obviously they often don't (especially with many devices),
> and
> it's a serious headache to sort out what happened, with few options
> to
> actually fix or workaround problems.? In our experience we've managed
> to
> get external=none to work pretty well, although not perfect.? It
> sounds
> like it's not working quite as well in your case, which I'd guess is
> due
> to slight differences in the udev-related machinery.? We usually end
> up
> adjusting udev rules when problems come up.? As Zdenek has mentioned,
> there are also issues with external=udev (although we don't have as
> much
> experience to give details).? I don't think external=udev would be a
> big
> improvement, at least in our case.? Given my level of disregard for
> udev
> overall (trying to be polite about that), I now prefer that we do
> everything we can natively, without depending on udev.? I think the
> best
> approach is to use native detection *plus* udev info in spots, so we
> get
> all possible info, without relying entirely on udev.? So I think the
> answer is to use any/all sources of info that are available at the
> time we
> need it, and not configure one or the other statically.

I agree with almost everything you say. My line of thinking is that 
modern Linux distros are fundamentally built around udev, the main
reason being the integration of udev and systemd. The advantage of udev
is it's flexibility and the possibility to do almost everything you'd
imagine with udev rules. And that's the biggest disadvantage at the
same time, because it opens up the device handling for any nonsense.
Distros can only hope that users won't mess it up. Not to mention that
it's slow.

multipath-tools has slowly moved from "native" device detection towards
relying almost 100% on udev during the last decade.?The main motivation
were the difficulties of vendor-specific device identification that
could be handled better by the flexibility of udev rules than by
anything we could hard-code. Today, device identification is well
standardized and could well be handled natively. Ben and I already
discussed reverting back from udev to native device detection some time
ago. I doubt it'll happen very soon, though.

Maybe I should re-phrase my point like this: We need to be consistent.
We can't rely on udev here and use something else there. And that's
what lvm2 does by default today with obtain_device_list_from_udev=1 and
external_device_info_source=none.
> 

> Quite a while ago I talked with Ben about making lvm read
> /etc/multipath/wwids to detect mpath components.? I wrote an initial
> patch
> which I never finished since there wasn't interest.? Now things have
> changed, and I also have a new feature (devices file) that will make
> it
> easier to use the mpath wwids.? Ben also mentioned a new library that
> we
> might also look at using to get the the mpath wwids.

Yes, I was involved in that :-)

Martin




