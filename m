From: Miklos Vajna <vmiklos@frugalware.org>
Date: Fri, 18 Feb 2011 18:04:05 +0100
Subject: [PATCH] Add systemd service file
In-Reply-To: <20110218164141.GG28729@agk-dp.fab.redhat.com>
References: <20110218163117.GD5980@genesis.frugalware.org>
	<20110218164141.GG28729@agk-dp.fab.redhat.com>
Message-ID: <20110218170404.GE5980@genesis.frugalware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

On Fri, Feb 18, 2011 at 04:41:41PM +0000, Alasdair G Kergon <agk@redhat.com> wrote:
> Could you explain a bit more how the sequence of activations will work?

Sure - this is for the case of general desktop/server situations, when
there are a few LVs. (Not thousands of it.)

This service file is invoked after udev settled, so all device nodes
area available. An other dependency also makes sure that vgchange is
invoked before we would run fsck on the LVs.

> vgchange -ay is rather crude and not what everyone will require.

Agreed, the service file is just installed, but not enabled, that's up
to the distro packagers / system administrators. However, I think it
suits the general case, I mean for example Fedora has 'vgchange -a y' as
well in its fedora-storage-init script, and we had something similar in
Frugalware's lvm2 sysv init script. The patch is to avoid every
distribution have its own custom service file.

> - Where do people configure (or have auto-detected) the LVs they want activated
> at boot?

Just like the fedora-storage-init script, this unconditionally enables
all LVs.

> - How do clustered VGs fit in?  (look at the existing init script)
> 
> - How do stacked devices fit in? 

This service file does not replace all existing init scripts - at least
service files for lvm2-monitor, clvmd and cmirrord can be added in the
future.

What it does is move part of the distro-specific scripts (in Fedora's
case, fedora-storage-init) to a native systemd service, so that distro
packager won't reinvent the wheel.

Sorry in case it seemed that this patch intents to replace all sysv init
scripts at once. :)

Thanks,

Miklos
-------------- next part --------------
A non-text attachment was scrubbed...
Name: not available
Type: application/pgp-signature
Size: 198 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20110218/ae9c17da/attachment.sig>
