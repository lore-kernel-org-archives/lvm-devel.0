From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 04 Nov 2009 13:32:41 +0100
Subject: [PATCH] Do not support dmsetup udev{flags, complete, complete_all, cookies} when udev_sync is disabled and tiny fix for udevcomplete
In-Reply-To: <20091104112538.GA17814@wavehammer.waldi.eu.org>
References: <4AF15D87.5010507@redhat.com>
	<20091104112538.GA17814@wavehammer.waldi.eu.org>
Message-ID: <4AF17469.9040408@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/04/2009 12:25 PM, Bastian Blank wrote:
> On Wed, Nov 04, 2009 at 11:55:03AM +0100, Peter Rajnoha wrote:
>> Just a tiny cleanup - we should be consistent here and disable dmsetup udev{flags,complete,
>> complete_all,cookies} commands if udev_sync is disabled, not udevcomplete_all and
>> udevcookies only.
> 
> What exactly are you trying to do? udevflags and udevcomplete is used in
> your udev rules, which can be used without udev sync enabled at all.
> 

When udev_sync is disabled, there's no cookie set and propagated and no flags are set
as well (dm_task_set_cookie is just a bogus function in this situation). There's no
DM_COOKIE in the udev environment then. We have tests in the rules if DM_COOKIE exists
and udevcomplete and udevflags is called just in case we have this set since it depends
on it.

However, even without DM_COOKIE env var, the rules themselves try to set the flags
directly (or at least try to mimic that, but we can't do that 100% from within udev
rules only - that's why I added the flag support in libdevmapper directly...).

The same logic applies when using old kernels < 2.6.31 (simply because these kernels
don't set DM_COOKIE@all...)

So this is when libdevmapper is compiled *without* udev_sync.

---

Another situation is when libdevmapper is compiled *with* udev_sync and software
using libdevmapper does not make use of the synchronisation interface - although the
software itself does not call dm_task_set_cookie and does not set any flags, we
can detect this and we set DM_UDEV_DISABLE_DM_RULES_FLAG and DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG
directly in libdevmapper, so we can avoid unexpected udev/libdevmapper races when
dealing with node and symlink creation (this is also the situation in which we happen
to have the base of the cookie zero and the prefix non-zero - which is why I need a tiny
cleanup for udevcomplete I propose within this patch as well :) ).

This applies until someone *directly* says "I'm OK with these races" - this is done by
calling "dm_udev_set_sync_support(0)" (the same happens when using dmsetup/lvm commands
with "--noudevsync" option - it just bypasses udev_sync).

(..sorry for being a little chatty here, but I think this is something that may
be of interest for more people.. So I think it's good to mention the context of this..)

But using the udev rules with udev_sync enabled is the recommended way.

Anyway, thanks for the question - this was a good one, really!

Peter


