From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 07 Dec 2009 13:24:08 +0100
Subject: [PATCH] Disable udev rules on change event with DISK_RO=1
In-Reply-To: <4B152425.4090506@redhat.com>
References: <4B152425.4090506@redhat.com>
Message-ID: <4B1CF3E8.7010509@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/01/2009 03:11 PM, Peter Rajnoha wrote:
> We need to detect this and disable the rule application so the
> meaning of this change event is not interchanged with the regular
> change event used while resuming/renaming DM devices.

Just for the record so we know about this...

Disabling the rules is not quite without any consequences. When we skip the rules for
symlink creation then udevd removes existing ones by default. That's very similar to a
problem with running "udevadm trigger" which generates ADD events and we suppress
the rules for this event unless ENV{STARTUP}=1 is defined.

But for now, we're OK in the situation with DISK_RO change event - this one is always
followed by regular change event (do_resume fn in kernel - we call set_disk_ro which
generates this DISK_RO change event and then we generate our own regular change event
afterwards). So we always have our nodes/symlinks in place as a result of such action.

If such events (events not originated in device-mapper code) were used anytime then
we would have a problem and that would need a fix from udev side as well.

(I think udev should not remove those nodes/events even when the rules are skipped on
add/change events - it should remove them on regular remove events only. That's exactly
what I tried to ask udev people about two months ago - whether this default behaviour
could be changed but I did not get any clear answer till now :) )

Peter


