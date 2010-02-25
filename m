From: Mike Snitzer <snitzer@redhat.com>
Date: Thu, 25 Feb 2010 17:13:24 -0500
Subject: userspace patches for shared snapshots
In-Reply-To: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1002101858410.15802@hs20-bc2-1.build.redhat.com>
Message-ID: <20100225221324.GA29946@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 10 2010 at  6:59pm -0500,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> Hi
> 
> I uploaded the current version of userspace shared snapshots here:
> http://people.redhat.com/mpatocka/patches/userspace/new-snapshots/lvm-2.02.60/

I've refreshed these patches to apply against the latest upstream lvm2:
http://people.redhat.com/msnitzer/patches/multisnap/lvm2/LVM2-2.02.62/

Seems these lvm2 patches can be cleaned up a bit to use wrappers much
like was done for the snapshot-merge support:
http://sources.redhat.com/git/gitweb.cgi?p=lvm2.git;a=commit;h=cad03afc54f565c

And I'm wondering whether we _really_ need a distinct 'shared_snapshot'
in 'struct logical_volume'.  I was able to remove 'merging_snapshot'
from the lvm2 snapshot-merge support:
http://sources.redhat.com/git/gitweb.cgi?p=lvm2.git;a=commit;h=fa684a97dae2e36

But I'll be reviewing the code (both kernel and lvm2) much closer in the
coming days.  Will go bottom up (kernel <-> lvm2 metadata -> lvm2).


I've done minimal testing to verify the basics are working; I have some
initial things/questions that I NOTE'd below:

# lvcreate -L 1G --sharedstore mikulas -s test/testlv1
  Logical volume "testlv1-shared" created

# dmsetup targets | grep multisnap
multisnap-snap   v1.0.0
multisnapshot    v1.0.0

# dmsetup ls
test-testlv1    (253, 0)
test-testlv1-cow        (253, 2)
test-testlv1-real       (253, 1)

# lvs
  LV             VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
  testlv1        test owi-a- 4.00g                                       
  testlv1-shared test swi--- 1.00g testlv1 100.00                        

NOTE: strikes me as odd that the testlv1-shared Snap% is 100%.  I've
fixed the same with the snapshot-merge code before; will dig deeper in a
bit.


# lvcreate -L 128M -s -n testlv1_snap test/testlv1
  Logical volume "testlv1_snap" created

# dmsetup ls
test-testlv1    (253, 0)
test-testlv1_snap       (253, 3)
test-testlv1-cow        (253, 2)
test-testlv1-real       (253, 1)

# lvs
  LV             VG   Attr   LSize Origin  Snap%  Move Log Copy%  Convert
  testlv1        test owi-a- 4.00g                                       
  testlv1-shared test swi--- 1.00g testlv1   0.01                        
  testlv1_snap   test swi-a- 4.00g testlv1                               

NOTE: how can we claim the snapshot is 4G when the shared snap store is
only 1G?  Also, why isn't 'testlv1-shared' (a)ctive?


# lvremove -f test/testlv1_snap
  Logical volume "testlv1_snap" successfully removed
# lvremove test/testlv1-shared
  Logical volume "testlv1-shared" successfully removed

# dmsetup ls
test-testlv1    (253, 0)
test-testlv1-cow        (253, 2)

NOTE: 'test-testlv1-cow' is left dangling.  This is certainly a
side-effect of relying on info-by-name to remove 'test-testlv-cow'.
We recently switched to only using info-by-uuid.  I had to adapt the
snapshot-merge deptree code to work with info-by-uuid:
http://sources.redhat.com/git/gitweb.cgi?p=lvm2.git;a=commit;h=eaef92b02f968

test-testlv1-cow has the following uuid:
LVM-bS8vdfSDcqfY0Q2KQDJtKD3UAXbp4cmyEBeX5HhmQ50dqK3tlLAdcATFavfhFM0f-cow

But the attached lvremove -vvvv log shows we're only looking to remove
based on an origin-based uuid (we no longer try to remove by name):
LVM-bS8vdfSDcqfY0Q2KQDJtKD3UAXbp4cmy0R0pTH5hWG79ZDsnhmXTV093McEMF52v-cow

Given that with shared snapshots there is only ever one store: AFAIK it
_should_ be valid to create test-testlv1-cow using the origin's uuid
rather than a cow uuid.  It's somewhat hackish but...


# lvcreate -L 1G --sharedstore mikulas -s test/testlv1
  device-mapper: create ioctl failed: Device or resource busy
  Failed to load snapshot driver for testlv1-shared
  Logical volume "testlv1-shared" successfully removed

NOTE: manually removing 'test-testlv1-cow' obviously fixes this
-------------- next part --------------
A non-text attachment was scrubbed...
Name: remove_shared.log.gz
Type: application/x-gzip
Size: 2825 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100225/0e850bcc/attachment.bin>
