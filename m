From: Martin Wilck <mwilck@suse.com>
Date: Fri, 29 Jan 2021 11:07:12 +0100
Subject: [PATCH] config: set external_device_info_source=none if udev isn't running
In-Reply-To: <7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
References: <20210127172859.956-1-mwilck@suse.com>
	<f671d5ea-5cb0-a690-f393-c1f733ffdd14@redhat.com>
	<cdf7d365c12b9cac29be22a12392e3f9860b1560.camel@suse.com>
	<7e4ceb01-953b-abbd-cab1-f77374d9d37e@gmail.com>
Message-ID: <e45a5da341edd2593dce5ef087039f84c20338f4.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Zdenek,

On Thu, 2021-01-28 at 23:56 +0100, Zdenek Kabelac wrote:
> Dne 28. 01. 21 v 11:27 Martin Wilck napsal(a):
> > On Thu, 2021-01-28 at 11:10 +0100, Zdenek Kabelac wrote:
> > > Dne 27. 01. 21 v 18:28 mwilck at suse.com?napsal(a):
> > > > From: Martin Wilck <mwilck@suse.com>
> > > > 
> > > > LVM2 has several configuration options related to device
> > > > detection
> > > > and udev. In particular, we have
> > > > obtain_device_list_from_udev=(0|1)
> > > > and external_device_info_source=("none"|"udev"). The two
> > > > options
> > > > are
> > > > obviously semantically related, but it's rather unclear if and
> > > > how
> > > > they interact.
> > > > 
> > > > If udev is unavailable, e.g. in containers,
> > > > obtain_device_list_from_udev
> > > > (which defaults to 1) will be automatically reset to 0.
> > > > However,
> > > > if external_device_info_source="udev" is set, this setting is
> > > > not
> > > > reset to "none", leading to error messages like
> > > > 
> > > > ??? Udev database has incomplete information about device
> > > > /dev/vda.
> > > > ??? /dev/vda: Failed to get external handle [udev].
> > > > 
> > > > This patch changes that, treating external_device_info_source
> > > > the
> > > > same way as obtain_device_list_from_udev, thereby making LVM2's
> > > > device detection more consistent.
> > > > 
> > > > The default for external_device_info_source is "none", but I
> > > > believe
> > > > there are very good reasons to change this setting to "udev",
> > > > because
> > > > LVM will get detection of multipath and md devices wrong most
> > > > of
> > > > the
> > > > time otherwise. LVM should follow the same logic as systemd and
> > > > other
> > > 
> > > 
> > > Hi
> > > 
> > > I'm afraid there is no such simple fix for this as you might
> > > think.
> > > 
> > > 
> > But does that mean my patch is wrong? Don't you agree that the
> > different handling of obtain_device_list_from_udev and
> > external_device_info_source in the current code is inconsistent?
> > 
> 
> Hi
> 
> One of the main point probably is? -
> 
> if udev is not working on your main system - and should - you should
> get it working first.
> 

Of course *udev* works "in my main system". But *LVM2* does not: with
the default setting "external_device_info_source=none", it ignores udev
properties of devices. This is the source of lots of subtle errors and
race conditions during device setup. Therefore we changed the setting
to "udev".

How do you handle that in Fedora? I took the liberty to look at the
Fedora 33 package, and it doesn't change default from "none" to
"udev".?So by common sense, Fedora is going to suffer from the same
general problem that (open)SUSE sees: With "none", lvm can detect
multipath or MD components only "after the fact", i.e. after multipathd
or mdadm have grabbed them already. If pvscan and multipathd start up
simultaneously, it's anyones guess who "wins" (*). With "udev", that
can't happen, and that's why "udev" should be made the default.

(I'm cc'ing Ben Marzinski, as he should know this problem very well,
and knows Fedora, too).

> Side case can be - you run lvm2 command - and someone 'restarts' udev
> (i.e. via upgrade...)

That shouldn't a problem AFAICS, because libudev only looks at the udev
data base, which is unaffected by updates.

> So in general - this fallback should be only like new configurable
> option - since normally you do not want lvm2 to ever touch /dev
> dir which is under udev control.

IIUC you argue for disallowing the fallback by default.?
I'm ok with that.

But that would also mean that you would have to change the default to
"udev", and *remove* both options "external_device_info_source" and
"obtain_device_list_from_udev". The former should be hard coded to
"udev" and the latter to 1, end of story. If you don't remove these
options, how would the new option interact with the existing two? Which
would take precedence?

> Adding your 'fallback' adds some level of randomness and diggers
> possibly bigger hole of troubles in system.

Explain that, please. The fallback does nothing in the current default
case (external_device_info_source="none"). And in the "udev" case, it
avoids an error condition in special situations, simply by falling back
to the current default. What's wrong about that?

> > Still, I think the patch is not a hack, but generally correct, and
> > has
> > the pleasant side effect to fix our issue.
> 
> It would need some 'new' mode - but IMHO that's then equivalent
> to setting correct mode directly.
> 
> What can likely work better is to add some 'detection' of being
> executed
> in container -? scream at user and do maybe that 'udev' hack fallback
> ;)

Again, this is not only about containers, but any environment where 
the udev data base is not available.

If you can provide a better solution than my patch, we'll happily
take it. But we need *something* to fix the current breakage.

Best regards,
Martin



(*) The problem is mitigated on modern distros by the fact that pvscan
is started by systemd, which of course honors SYSTEMD_READY. This is
the reason actual problems are encountered rarely, and only on sytems
with complex storage setup and lots of LUNs and PVs. But races can
occur, because pvscan, once started, tries to build up a device data
base, and while doing that, it relies on its own device detection
scheme, which is inconsistent with systemd's unless
"external_device_info_source" is set to "udev".




