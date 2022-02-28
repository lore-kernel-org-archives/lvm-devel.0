From: Martin Wilck <mwilck@suse.com>
Date: Mon, 28 Feb 2022 09:48:28 +0100
Subject: [PATCH] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
In-Reply-To: <164557016782.28944.17731814770525408828@noble.neil.brown.name>
References: <20220216205914.7575-1-mwilck@suse.com>
	, <164504936873.10228.7361167610237544463@noble.neil.brown.name>
	, <e8720e3f8734cbad1af34d5e54afc47ba3ef1b8f.camel@suse.com>
	, <20220217130934.lh2b33255kyx2pax@alatyr-rpi.brq.redhat.com>
	, <164548656531.8827.3365536065813085321@noble.neil.brown.name>
	, <4b61ca1eafb35e3fdfbc9bb260dc89d56d181499.camel@suse.com>
	<164557016782.28944.17731814770525408828@noble.neil.brown.name>
Message-ID: <ff8030340e30963a1772f43e8bdfb6b610219887.camel@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2022-02-23 at 09:49 +1100, NeilBrown wrote:
> 
> But if libdevmapper.h is the best you have, then maybe it'll have to
> do.
> It is up to Jes what he accepts of course.

Jes, have you made up your mind on this patch yet?
Please contact me if you have remarks or questions.

Note that the patch that started this thread is broken; the v2 is
correct. With the v2, I was able to reach 1000 consecutive reboots on
a system with MD on top of multipath that would otherwise hang during
boot about once every 50-100 reboots.

Regards
Martin



