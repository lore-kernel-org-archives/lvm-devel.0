From: Oliver Rath <rath@mglug.de>
Date: Sun, 29 Sep 2013 00:35:42 +0200
Subject: compile error with lvm2: '_raid_target_present' undeclared
Message-ID: <524759BE.9070203@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

my compilation of the last git (today) results a compiling error:

raid/raid.c:384:20: error: '_raid_target_percent' undeclared here (not
in a function)
raid/raid.c:385:20: error: '_raid_target_present' undeclared here (not
in a function)

The complete compile step:

http://paste.ubuntu.com/6168893/

The thin-provisioning-tools are from today, too.

my configure-line from lvm is:

./configure --enable-udev_sync --enable-udev_rules --with-thin=internal


Whats wrong here?

Tfh!

Oliver


