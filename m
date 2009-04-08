From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 08 Apr 2009 14:41:14 +0200
Subject: [PATCH] Udev integration: udev rules 3/3
Message-ID: <49DC9B6A.7040206@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is used for exceptional situations -- if the notification in the
rules before were not defined (so it's a simple fallback). This is
to prevent the hang of processes waiting for this notification.
Or, for example, for some reason, the user doesn't have LVM package
installed (and so he doesn't have LVM udev rules installed as well),
just the basic libdm/dmsetup and unfortunately creates a device with
the LVM (or any other subsystem) prefix. This could happen...

(this rule should be defined with the least priority)

Peter


# These rules are used to send any residual DM cookie notifications.

SUBSYSTEM!="block", GOTO="dm_end"
KERNEL!="dm-[0-9]*", GOTO="dm_end"
ACTION!="change|remove", GOTO="dm_end"

ENV{COOKIE}=="[0-9]*", RUN+="/sbin/dmsetup notify $env{COOKIE}", OPTIONS+="last_rule"

LABEL="dm_end"


