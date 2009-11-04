From: Bastian Blank <bastian@waldi.eu.org>
Date: Wed, 4 Nov 2009 12:25:38 +0100
Subject: [PATCH] Do not support dmsetup udev{flags, complete, complete_all, cookies} when udev_sync is disabled and tiny fix for udevcomplete
In-Reply-To: <4AF15D87.5010507@redhat.com>
References: <4AF15D87.5010507@redhat.com>
Message-ID: <20091104112538.GA17814@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Nov 04, 2009 at 11:55:03AM +0100, Peter Rajnoha wrote:
> Just a tiny cleanup - we should be consistent here and disable dmsetup udev{flags,complete,
> complete_all,cookies} commands if udev_sync is disabled, not udevcomplete_all and
> udevcookies only.

What exactly are you trying to do? udevflags and udevcomplete is used in
your udev rules, which can be used without udev sync enabled at all.

Bastian

-- 
Our missions are peaceful -- not for conquest.  When we do battle, it
is only because we have no choice.
		- Kirk, "The Squire of Gothos", stardate 2124.5


