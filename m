From: David Teigland <teigland@redhat.com>
Date: Tue, 26 Mar 2013 12:59:13 -0400
Subject: pvresize problem
Message-ID: <20130326165913.GA12503@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm trying to verify shrinking with pvresize --setphysicalvolumesize

When the pv is an orphan, it works as expected, but when the pv is
not an orphan, the resulting size is always 8192S less than the
requested size.

Getting the same result with the latest git code and from tag v2_02_98.

--

test_description='pvresize setphysicalvolumesize'

. lib/test

aux prepare_devs 2

# non-orphan
vgcreate $vg1 "$dev1"

# orphan
pvcreate "$dev2"

size1=$(get pv_field "$dev1" pv_size --units s)
size2=$(get pv_field "$dev2" pv_size --units s)

pvresize --setphysicalvolumesize 57344S $dev2
check pv_field $dev2 pv_size "57344S" --units s

pvresize --setphysicalvolumesize 57344S $dev1
check pv_field $dev1 pv_size "57344S" --units s

--

pvresize -vv --setphysicalvolumesize 57344S $dev1
#pvresize.sh:30+ pvresize -vv --setphysicalvolumesize 57344S @TESTDIR@/dev/mapper/@PREFIX at pv1
      Setting activation/monitoring to 0
      Setting global/locking_type to 1
      global/wait_for_locks not found in config: defaulting to 1
      File-based locking selected.
      Setting global/locking_dir to @TESTDIR@/var/lock/lvm
      global/prioritise_write_locks not found in config: defaulting to 1
    Using physical volume(s) on command line
      @TESTDIR@/dev/mapper/@PREFIX at pv1: size is 68608 sectors
      @TESTDIR@/dev/mapper/@PREFIX at pv1: lvm2 label detected at sector 1
      @TESTDIR@/dev/mapper/@PREFIX at pv1: size is 68608 sectors
      @TESTDIR@/dev/mapper/@PREFIX at pv1: size is 68608 sectors
      @TESTDIR@/dev/mapper/@PREFIX at pv2: size is 68608 sectors
      @TESTDIR@/dev/mapper/@PREFIX at pv2: lvm2 label detected at sector 1
      Locking @TESTDIR@/var/lock/lvm/V_ at PREFIX@vg1 WB
      @TESTDIR@/dev/mapper/@PREFIX at pv1: lvm2 label detected at sector 1
      @TESTDIR@/dev/mapper/@PREFIX at pv1: size is 68608 sectors
      @TESTDIR@/dev/mapper/@PREFIX at pv1: size is 68608 sectors
    @TESTDIR@/dev/mapper/@PREFIX at pv1: Pretending size is 57344 not 68608 sectors.
    Resizing volume "@TESTDIR@/dev/mapper/@PREFIX at pv1" to 68608 sectors.
    Resizing physical volume @TESTDIR@/dev/mapper/@PREFIX at pv1 from 0 to 6 extents.
    Updating physical volume "@TESTDIR@/dev/mapper/@PREFIX at pv1"
  WARNING: This metadata update is NOT backed up
  Physical volume "@TESTDIR@/dev/mapper/@PREFIX at pv1" changed
      Unlocking @TESTDIR@/var/lock/lvm/V_ at PREFIX@vg1
  1 physical volume(s) resized / 0 physical volume(s) not resized
check pv_field $dev1 pv_size "57344S" --units s
#pvresize.sh:31+ check pv_field @TESTDIR@/dev/mapper/@PREFIX at pv1 pv_size 57344S --units s
pv_field: PV="@TESTDIR@/dev/mapper/@PREFIX at pv1", field="pv_size", actual="49152S", expected="57344S"


