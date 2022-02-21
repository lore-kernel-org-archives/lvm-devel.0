From: NeilBrown <neilb@suse.de>
Date: Tue, 22 Feb 2022 10:36:05 +1100
Subject: [PATCH] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
In-Reply-To: <20220217130934.lh2b33255kyx2pax@alatyr-rpi.brq.redhat.com>
References: <20220216205914.7575-1-mwilck@suse.com>,
	<164504936873.10228.7361167610237544463@noble.neil.brown.name>,
	<e8720e3f8734cbad1af34d5e54afc47ba3ef1b8f.camel@suse.com>,
	<20220217130934.lh2b33255kyx2pax@alatyr-rpi.brq.redhat.com>
Message-ID: <164548656531.8827.3365536065813085321@noble.neil.brown.name>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


> The flags that DM use for udev were introduced before systemd project
> even existed. We needed to introduce the DM_UDEV_DISABLE_OTHER_RULES_FLAG
> to have a possibility for all the "other" (non-dm) udev rules to check
> for if there's another subsystem stacking its own devices on top of DM
> ones.

If this is an established API that DM uses, then presumably it is
documented somewhere.  If a link to that documentation were provided, it
would look a a whole lot less like a hack.

Thanks,
NeilBrown


