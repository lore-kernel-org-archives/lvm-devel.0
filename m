From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 1 Mar 2022 08:53:49 +0100
Subject: [dm-devel] [PATCH] udev-md-raid-assembly.rules: skip if DM_UDEV_DISABLE_OTHER_RULES_FLAG
In-Reply-To: <CALTww2-_rJDyVh2GLehJ8Yg9LOy4MnkvDeJnF2uunaOy6ONu7g@mail.gmail.com>
References: <20220216205914.7575-1-mwilck@suse.com>
	<164504936873.10228.7361167610237544463@noble.neil.brown.name>
	<e8720e3f8734cbad1af34d5e54afc47ba3ef1b8f.camel@suse.com>
	<20220217130934.lh2b33255kyx2pax@alatyr-rpi.brq.redhat.com>
	<CALTww2-_rJDyVh2GLehJ8Yg9LOy4MnkvDeJnF2uunaOy6ONu7g@mail.gmail.com>
Message-ID: <20220301075349.ao7a2rbjqn627oq4@alatyr-rpi.brq.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi!

On Mon 28 Feb 2022 23:28, Xiao Ni wrote:
> Hi Peter
> 
> In rhel, we have a rhel only udev rule that checks
> DM_UDEV_DISABLE_OTHER_RULES_FLAG. Maybe it's the reason why you don't
> notice this. Besides DM_UDEV_DISABLE_OTHER_RULES_FLAG, it still checks
> other flags.
> 

Ah yes, that's it! I've been still recalling this to be patched once.
So looks like it just didn't get propagated upstream :-/

> # Next make sure that this isn't a dm device we should skip for some reason
> ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_change_end"
> ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}=="1", GOTO="dm_change_end"
> ENV{DM_SUSPENDED}=="1", GOTO="dm_change_end"
> KERNEL=="dm-*", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="linux_raid_member", \
>         ACTION=="change", RUN+="/sbin/mdadm -I $env{DEVNAME}"
> LABEL="dm_change_end"
> 
> In 10-dm.rules, if DM_SUSPENDED is 1, it sets
> DM_UDEV_DISABLE_OTHER_RULES_FLAG to 1. So we don't need the check of
> DM_SUSPENDED. But how DM_UDEV_RULES_VSN? Do we need to check it?
> 

Yes, right, the check for DM_SUSPENDED is superfluous here so we don't
actually need that one. The single check for DM_UDEV_DISABLE_OTHER_RULES_FLAG
covers it.

The DM_UDEV_RULES_VSN - this was meant for future changes in case a new
set of DM udev variables is used or existing set changed so the other rules
know what exact variable set is available for checking. But I think the rules
are settled down for a few years now and I don't expect any more radical
changes here, so we can remove that check for DM_UDEV_RULES_VSN as well.

-- 
Peter


