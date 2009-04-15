From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 15 Apr 2009 19:07:03 +0100
Subject: [PATCH] Udev integration: udev rules 1/3
In-Reply-To: <49DC99BA.8000205@redhat.com>
References: <49DC99BA.8000205@redhat.com>
Message-ID: <20090415180703.GJ7843@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Apr 08, 2009 at 02:34:02PM +0200, Peter Rajnoha wrote:
> # udev rules for DM devices
> # This will create nodes in /dev/mapper directory.
 
/dev and mapper are (separately) configurable, so this script should perhaps
be generated from a template for consistency.
(DM_DIR is fixed at compile time and must match the kernel - set in dm-ioctl.h)
(/dev gets interesting if people invoked lvm with a private lvm.conf with a
private devices/dir - as a minimum assumptions made by the script should be
noted in comments.)

> # "dm" sysfs subdirectory is available in newer DM versions only.

"newer" ?  Be precise - give the version.

> # You can define your own permissions for DM devices here.
> # ENV{DM_NAME}=="my_device", OWNER="peter", GROUP="peter", MODE="0644"
 
Can that be read from a separate file to avoid the need for manual editing
when updating?  (Otherwise add markers so that a postinstall script
can automatically update the file.)

> # We won't send notifications for known subsystems since
> # these have their own dedicated rules and the notification
> # will be done after they finish their own actions.
> ENV{DM_UUID}=="LVM-?*", GOTO="dm_end"
 
Again, how are these prefixes defined?
- Each package will want to install it's own prefix handler.
  Can that be done without having to edit files?

> ENV{COOKIE}=="[0-9]*", RUN+="/sbin/dmsetup notify $env{COOKIE}", OPTIONS+="last_rule"
 
Since this is external input being passed to a trusted program, what is validating it?
- Does that regex have implicit ^ and $ anchors around it?  (If not, add them.)
- What if the variable is defined but empty?  (Change * to +) ?

Alasdair
-- 
agk at redhat.com


