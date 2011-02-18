From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 18 Feb 2011 19:43:01 +0100
Subject: [PATCH] Add systemd service file
In-Reply-To: <20110218170404.GE5980@genesis.frugalware.org>
References: <20110218163117.GD5980@genesis.frugalware.org>	<20110218164141.GG28729@agk-dp.fab.redhat.com>
	<20110218170404.GE5980@genesis.frugalware.org>
Message-ID: <4D5EBDB5.30609@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.2.2011 18:04, Miklos Vajna napsal(a):
> Hi Alasdair,
> 
> On Fri, Feb 18, 2011 at 04:41:41PM +0000, Alasdair G Kergon <agk@redhat.com> wrote:
>> Could you explain a bit more how the sequence of activations will work?
> 
> Sure - this is for the case of general desktop/server situations, when
> there are a few LVs. (Not thousands of it.)
> 
> This service file is invoked after udev settled, so all device nodes
> area available. An other dependency also makes sure that vgchange is
> invoked before we would run fsck on the LVs.
> 
>> vgchange -ay is rather crude and not what everyone will require.
> 
> Agreed, the service file is just installed, but not enabled, that's up
> to the distro packagers / system administrators. However, I think it
> suits the general case, I mean for example Fedora has 'vgchange -a y' as
...
> 
> What it does is move part of the distro-specific scripts (in Fedora's
> case, fedora-storage-init) to a native systemd service, so that distro
> packager won't reinvent the wheel.
> 
> Sorry in case it seemed that this patch intents to replace all sysv init
> scripts at once. :)
> 

I think at this moment, systemd init script is way too much 'distro-oriented'
to make it usable from default package installation.

(We do not ship SysV nor Upstart script either)

It's probably for discussion how the 'startup' should be configurable,
where to put configurable parts for startup script and how to handle
dependencies.  Currently I do not see big use for the currently proposed patch
 (I think you are repeating here when initially systemd
automatically mounted all filesystems from fstab...)

Zdenek


