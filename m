From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 03 Aug 2011 09:30:44 -0500
Subject: [PATCH 0 of 5] LVM RAID: new features
Message-ID: <1312381844.1169.8.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The next five patches expand the available operations for LVM RAID
devices.

- Basic monitoring support is added - only reporting on RAID kernel
events
- Ability to down-convert RAID1 arrays (similar to the current mirroring
target)
- Add '--splitmirrors' support for RAID1 (only 1 device so far)

 brassow


