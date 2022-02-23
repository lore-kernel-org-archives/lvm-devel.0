From: Martin Wilck <mwilck@suse.com>
Date: Wed, 23 Feb 2022 10:47:38 +0100
Subject: [PATCH] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
In-Reply-To: <164557016782.28944.17731814770525408828@noble.neil.brown.name>
References: <20220216205914.7575-1-mwilck@suse.com>
	, <164504936873.10228.7361167610237544463@noble.neil.brown.name>
	, <e8720e3f8734cbad1af34d5e54afc47ba3ef1b8f.camel@suse.com>
	, <20220217130934.lh2b33255kyx2pax@alatyr-rpi.brq.redhat.com>
	, <164548656531.8827.3365536065813085321@noble.neil.brown.name>
	, <4b61ca1eafb35e3fdfbc9bb260dc89d56d181499.camel@suse.com>
	<164557016782.28944.17731814770525408828@noble.neil.brown.name>
Message-ID: <d3aab8f2318f1438a1f0085eddf9713217d52391.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Neil,

On Wed, 2022-02-23 at 09:49 +1100, NeilBrown wrote:
> > 
> > Peter has provided a link to libdevmapper.h in his previous post in
> > this thread. Is this a request for me to include that link in the
> > patch
> > description?
> 
> If libdevmapper.h is the best documentation there is for this
> variable,
> then hopefully you can see why it feels to an outsider like a hack.
> 

There's also some documentation in the form of comments in the device-
mapper rules files themselves:

https://github.com/lvmteam/lvm2/blob/8dccc2314e2482370bc6e5cf007eb210994abdef/udev/10-dm.rules.in#L137

In general, 10-dm.rules is one of the most extensively commented rule
files. I've always found these comments quite helpful.

> It isn't even immediately clear that the text there is talking about
> environment variables visible in udev.
> If there is an expectation that tools outside of lvm2 will use these,
> then they really should be documented properly.? SYSTEMD_READY is
> documented in "man systemd.device".? How hard would it be to write a
> "dm-udev" man page which explains all this.

I agree that the documentation could be improved. OTOH, the text in
systemd.device(5) only explains how systemd itself interprets
SYSTEMD_READY. It doesn't say a word about how other udev rules are
supposed to deal with the device. IOW, SYSTEMD_READY is part of an API
between udev rules and systemd, and not between different udev rule
sets.

In particular the "don't probe this iff SYSTEMD_READY==0" semantics
that are frequently used in rules files can't be inferred from this
documentation. It makes sense most of the time, but there are some
cases where it doesn't. Here, we have a case where probing should be
skipped, even though SYSTEMD_READY is not 0.

Regards,
Martin

PS: The big issue remains that there is no "official" API in which udev
rule sets can transport information between each other. I guess the
original idea was that every rule set would be self-contained, which
isn't the case any more. If anyone makes an effort redesign udev, they
should consider creating such an API somehow.



