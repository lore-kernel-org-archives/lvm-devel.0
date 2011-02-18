From: Miklos Vajna <vmiklos@frugalware.org>
Date: Fri, 18 Feb 2011 18:09:35 +0100
Subject: [PATCH] Add systemd service file
In-Reply-To: <20110218165845.GB27449@agk-dp.fab.redhat.com>
References: <20110218163117.GD5980@genesis.frugalware.org>
	<20110218164141.GG28729@agk-dp.fab.redhat.com>
	<20110218165845.GB27449@agk-dp.fab.redhat.com>
Message-ID: <20110218170935.GG5980@genesis.frugalware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Feb 18, 2011 at 04:58:45PM +0000, Alasdair G Kergon <agk@redhat.com> wrote:
> What I'm suggesting is that a udev-rule-based solution should work
> better than a service file.   In the mean time, you'll probably need to
> add several service files with various dependencies to cover the
> different possibilities.  (lvchange must run after md is activated;
> lvchange must run before md is activate; lvchange must run before
> cluster is activated; lvchange must run after cluster is activated; same
> for other block-device creating components like cryptsetup, loop  etc.)

My udev-fu is quite low - if that's possible, I'm happy with it as well.
The goal is to avoid distro-specific init scripts.

However, vgchange is at the very end of fedora-storage-init, so we could
simply add dependencies to run mdadm (when later someone writes service
files for that) before vgchange and that would work as well.

A fixed execution order is already there with the current shell scripts,
as far as I understand.

Thanks.


