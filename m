From: Petr Rockai <prockai@redhat.com>
Date: Wed, 05 May 2010 15:48:29 +0200
Subject: [PATCH] Provide a new --sysinit switch for vgchange and lvchange
In-Reply-To: <4BE16BD5.7030402@redhat.com> (Peter Rajnoha's message of "Wed,
	05 May 2010 15:00:05 +0200")
References: <4BE16BD5.7030402@redhat.com>
Message-ID: <878w7y1mtu.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Peter Rajnoha <prajnoha@redhat.com> writes:
> In read-only environment, we normally use the same bunch of switches
> to disable several things (--ignoremonitoring, --ignorelockingfailure,
> --poll n, LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1...) This is used
> on system startup mainly. Maybe we could add a new switch that will
> set everything automatically to make things a little bit cleaner and
> more maintainable, so we don't have to bug people around to change
> things if we need to add/change something (it could be used in
> initscripts, dracut, anything similar...).
I don't think one size fits all of the above. E.g. you want monitoring
to be handled by initscripts but not by dracut.

Yours,
   Petr.


