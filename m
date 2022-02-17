From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 17 Feb 2022 14:20:42 +0100
Subject: [PATCH] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
In-Reply-To: <e8720e3f8734cbad1af34d5e54afc47ba3ef1b8f.camel@suse.com>
References: <20220216205914.7575-1-mwilck@suse.com>
	<164504936873.10228.7361167610237544463@noble.neil.brown.name>
	<e8720e3f8734cbad1af34d5e54afc47ba3ef1b8f.camel@suse.com>
Message-ID: <20220217132042.dmmkhecvvylnyc3b@alatyr-rpi.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu 17 Feb 2022 11:58, Martin Wilck wrote:
> The main reason is that SYSTEMD_READY=0 is set too late, in 99-systemd-
> rules, and only on "add" events:
> https://github.com/systemd/systemd/blob/bfae960e53f6986f1c4d234ea82681d0acad57df/rules.d/99-systemd.rules.in#L18
> 
> I guess the device-mapper rules themselves could be setting
> SYSTEMD_READY="0". @Peter Rajnoha, do you want to comment on that? My
> concern wrt such a change would be possible side effects. Setting
> SYSTEMD_READY=0 on "change" events could actually be wrong, see below.

We need to be very careful with SYSTEMD_READY as switching that from 1
to 0 would cause the systemd device unit to stop. And services can be
bound to device existence (that is, systemd device unit). If we just
temporarily suspend a DM device and not completely removing it, then
we might get out-of-sync easily when it comes to notion of device
presence in various parts of the system.

One thing is device presence, the other are various sub-states that
a single SYSTEMD_READY is not covering, like the suspended state...

-- 
Peter


