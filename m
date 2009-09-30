From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 29 Sep 2009 20:28:06 -0400
Subject: [RFC][PATCH 0/5] dmeventd device filtering
Message-ID: <4AC2A616.9060705@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

This is a prototype patch to add device filtering function to dmeventd.
I aprreciate any comments on the idea or implementation.


PATCH SET
=========
    1/5: support command string with space
    2/5: add device list registering interface
    3/5: add filtering function to dmeventd
    4/5: dmeventd filtering failed devices
    5/5: update device lists by lvm commands


BACKGROUND
==========

Most part of an error recovery of LVM mirror is processed in userspace,
especially dmeventd. dmeventd calls lvconvert and vgreduce internally
and those lvm commands remove failed devices.

However, a lvm command scans all devices managed by lvm every time it
is executed, and it will take for a long time if there are many devices
in the system.

Also, a failed device which triggered the error recovery is also accessed.
When the error is related to timeout, accesses to the failed device may
cause another timeout and the error recovery could take for a long time.
The error recovery time is also affected by failed devices which are not
associated with a volume group which a mirror volume belongs to.

FYI: This issue is also described in the following post.
   Introduce metadata cache feature
   https://www.redhat.com/archives/lvm-devel/2009-April/msg00014.html


SOLUTION
========

Device filtering feature is added to dmeventd so that dmeventd calls
a LVM command with a filter option to limit accessing devices as follows:

   - Allow access to devices associated with the volume group
   - Deny access to the failed devices which triggered the error recovery

For example, when mimage0 broke in the following environment, the current
implementation accesses all devices (pv0 ... pv8), but access to pv1 and
pv2 are enough to remove mimage0.

    vg0 { pv0, pv1, pv2 }, vg1 { pv3, pv4, pv5 }, vg2 { pv6, pv7, pv8 }

        lv0(mirror) --+-- mimage0 { pv0 }
                      +-- mimage1 { pv1 }
                      +-- mlog    { pv2 }

This patch set limits devices to be accessed during error recovery.


DESIGN OVERVIEW
===============

The key idea is executing lvconvert and vgreduce with "filter" options
from dmeventd and override filtering rule defined in the config file
(lvm.conf). When an error is reported to dmeventd, dmeventd automatically
generates filtering option and call lvm commands with it as follows.

   vgreduce --removemissing --config \
     devices{filter=["a|/dev/sda", "a|/dev/sdb", ...,"r|.*|"]} VG/LV

To generate filter option, dmeventd requires a list of devices included
in the VG. When a LV is registered as a monitoring device, a device list
of the VG are passed to dmeventd. This information needs to be updated if
the VG structure is changed by adding or removing devices to/from the VG
by vgextend, vgreduce or other lvm commands, dmeventd gets a new device
list.

A failed device list is generated when an error is notified. dmeventd gets
devices included in failed mirror leg or log from kernel through device-mapper
interface.


FUTURE WORKS
============

  - To make the filtering function configurable (e.g. lvm.conf)
  - More tests
  - Code cleanup (including adjusting the size of static array)
  - Evaluation together with mirroredlog which malahal posted

Regards,
-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


