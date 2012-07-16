From: dongsu.park@profitbricks.com <dongsu.park@profitbricks.com>
Date: Mon, 16 Jul 2012 23:18:36 +0200
Subject: [RFC PATCH 0/3] optimize detection of MD devices
Message-ID: <1342473519-2853-1-git-send-email-dongsu.park@profitbricks.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Dongsu Park <dongsu.park@profitbricks.com>

This patchset optimizes the detection mechanism of MD devices, as well
as introduces a possibility to turn off detections of the legacy
metadata versions.

In order to detect MD device, LVM has been trying to find MD magic string
from every underlying device. For that purpose, LVM2 must seek to a specific
offset for each MD metadata version, i.e. 0.9, 1.0, 1.1, 1.2, meaning
four operations per device. Being quite inefficient, those cause
performance problems when creating a certain amount of logical volumes.

As shown in the second patch, a solution to the problem is reading block
area only 2 times for each MD device. First, try to read several bytes from
the beginning of device. (This is the case of MD metadata version 1.2 or 1.1)
If MD magic is found there, return immediately.
If not found, then try again to read from the end of device.
(That's the case of MD metadata version 1.0 or 0.9)

In addition, the third patch introduces a new config option
md_detect_metadata_legacy under devices section in lvm.conf, to be able to
switch on (or off) detection of legacy metadata versions, i.e. 0.9 or 1.0.
By turning off the option, the checksum can only be searched for v1.2 and
v1.1 from the beginning of each device. This can dramatically improve
performance of most LVM2 tools.

Dongsu Park (3):
  lvm-wrappers: implement wrappers to get min/max u64 values
  dev-md: optimize detection of MD devices
  a new config option devices/md_detect_metadata_legacy

 doc/example.conf.in        |   10 +++
 lib/commands/toolcontext.c |    5 ++
 lib/config/defaults.h      |    1 +
 lib/device/dev-md.c        |  159 ++++++++++++++++++++++++++++++++++++++++----
 lib/misc/lvm-globals.c     |   11 +++
 lib/misc/lvm-wrappers.c    |   10 +++
 lib/misc/lvm-wrappers.h    |    3 +
 man/lvm.conf.5.in          |    8 +++
 8 files changed, 193 insertions(+), 14 deletions(-)

-- 
1.7.10


