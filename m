From: Petr Rockai <prockai@redhat.com>
Date: Tue, 05 Oct 2010 12:45:46 +0200
Subject: [PATCH] dmeventd -R (restart; BZ 454618)
Message-ID: <87sk0kncit.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch implements dmeventd -R, which allows us to restart
dmeventd without losing the monitoring state. The version that is
already running needs to support a (new) "get status" command for this
to work. This means that upgrade scripts can't use dmeventd -R if they
are upgrading from a version that does not provide this mechanism,
without losing the monitoring status.

I believe a reasonable solution (for upgrades) is to:

- check the existing version of dmeventd
- if new, use dmeventd -R
- if old, kill dmeventd, start the new one and enable monitoring for all
  devices in the system

IIRC, RPM provides the version number of the package you are upgrading
from to the post-installation script, which would make the above fairly
easy. If no, you can run dmeventd -V in pre-install (and store it
somewhere) and use that in the post-install to decide what to do.

The patch provides an automated test for the -R functionality, in
test/t-dmeventd-restart.sh.

Yours,
   Petr.

PS: The other option is to just use dmeventd -R unconditionally. It
should fail if the running dmeventd is too old, but should not cause any
other harm. This needs some extra testing, though.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-restart.diff
Type: text/x-diff
Size: 11496 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101005/64d94e12/attachment.bin>
