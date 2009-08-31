From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 31 Aug 2009 18:08:35 -0400
Subject: rebased snapshot-merge patches
Message-ID: <20090831220834.GA15126@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've updated both the DM and LVM2 snapshot-merge patches to the latest
upstream Linux and LVM2.

All patches (both Linux and LVM2) have been tested to pass the LVM2
testsuite.  There is more work to be done on these patches but I wanted
to make others aware of them sooner rather than later.

The basis for the DM snapshot-merge patches is Linux 2.6.31-rc8 + the
remaining DM fixes that Alasdair should be pushing to Linus this week:
http://people.redhat.com/msnitzer/patches/dm-2.6.31-rc-fixes/

The DM snapshot-merge patches are here:
http://people.redhat.com/msnitzer/patches/snapshot-merge/kernel/2.6.31/

The LVM2 snapshot-merge patches are here:
http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.52-cvs/

I threw some real work at snapshot-merge by taking a snap _before_
formatting a 100G LV with ext3.  Then merged all the exceptions.  One
observation is that the merge process is _quite_ slow in comparison to
how long it took to format the LV (with associated snapshot exception
copy-out).  Will need to look at this further shortly... it's likely a
function of using minimal system resources during the merge via kcopyd;
whereas the ext3 format puts excessive pressure on the system's page
cache to queue work for mkfs's immediate writeback.

# lvcreate -n testlv -L 100G test
# lvcreate -n testlv_snap -s -L 20G test/testlv
# lvs
  LV          VG   Attr   LSize   Origin Snap%  Move Log Copy%  Convert
  testlv      test owi-a- 100.00G
  testlv_snap test swi-a-  20.00G testlv   0.00
# mkfs.ext3 /dev/test/testlv
# lvs
  LV          VG   Attr   LSize   Origin Snap%  Move Log Copy%  Convert
  testlv      test owi-a- 100.00G
  testlv_snap test swi-a-  20.00G testlv   8.52
# lvconvert -M test/testlv_snap
  Merging of volume testlv_snap started.
  testlv: Merged: 8.5%
  testlv: Merged: 8.4%
  testlv: Merged: 8.4%
  testlv: Merged: 8.3%
  ...
  testlv: Merged: 7.2%
  ...
  testlv: Merged: 0.0%
  testlv: Merged: 0.0%
  testlv: Merged: 0.0%
  Merge into logical volume testlv finished.
  Logical volume "snapshot1" successfully removed


