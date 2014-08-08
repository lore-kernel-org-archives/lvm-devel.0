From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 08 Aug 2014 08:26:07 +0200
Subject: vgrename omit renaming hidden volumes if vg is inactive -> thinpools will be inconsistent
In-Reply-To: <53E3D623.7040606@mglug.de>
References: <53E3D623.7040606@mglug.de>
Message-ID: <53E46D7F.10203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 08/07/2014 09:40 PM, Oliver Rath wrote:
> Hi list,
> 
> ive probably found a bug in lvm2 (testet on commit hash
> 6320c3b9052004397faf1687198756ac7914fecc):
> 
> if i rename an inactive vg (vgchange -an vg), then the hidden volumes
> like /dev/mapper/vg-mypool_tdata ..tmeta ..tpool arent renamed in
> /dev/mapper/..
> 

Inactive VG should not have any /dev/ content. If it remained after
deactivation, it seems to be a bug in node/symlink handling under /dev.

A few questions then:

  - what distro is this?
  - are you using udev rules from lvm2 git repo too?
  - what are the lvm.conf values for these settings:
      - activation/udev_sync
      - activation/udev_rules
      - activation/verify_udev_operations
  - what udev (or systemd+udev) version is being used
  - are all the items found in /dev/mapper symlinks (not direct block dev nodes)?
  - are there dangling symlinks found in /dev/mapper for the LVs from deactivated VG?

-- 
Peter


