From: Kirby Zhou <kirbyzhou@sogou-inc.com>
Date: Mon, 30 Jan 2012 06:29:54 +0000
Subject: 答复: [linux-lvm] New LVM2 release 2.02.89: Thinly-provisioned logical volumes
In-Reply-To: <20120127025701.GB16767@agk-dp.fab.redhat.com>
References: <20120127025701.GB16767@agk-dp.fab.redhat.com>
Message-ID: <A0D9F519724C4648B433C8FA859E3EBB7CD0390C@EX01.sogou-inc.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Can the thinly-provisioned logical volume automatically return its owned space to the pool?
I mean, if I create a huge file on the logical volume, then delete it, will the logical volume actual space size be reduced automatically?
If not, how can it be shrinked?


Regards
Kirby Zhou
+86 (10) 6272 8261

-----????-----
???: linux-lvm-bounces at redhat.com [mailto:linux-lvm-bounces at redhat.com] ?? Alasdair G Kergon
????: 2012?1?27? 10:57
???: lvm-devel at redhat.com; linux-lvm at redhat.com; dm-devel at redhat.com
??: [linux-lvm] New LVM2 release 2.02.89: Thinly-provisioned logical volumes

After a long break, we've issued a new LVM2 release, 2.02.89.

 394 files changed, 22662 insertions(+), 11614 deletions(-)

This release includes experimental support for thinly-provisioned logical volumes using the new device-mapper thin provisioning target in kernel 3.2.

This is still a *development* release and the new feature is not supported by all the LVM commands yet.

The various interface extensions for thin provisioning are not frozen.
So we might still decide to tweak the command line extensions, library functions, on-disk metadata extensions, tool output, configuration options etc. in ways that make later releases incompatible with this particular release.

Please try it out, test it, and give us feedback preferably on the mailing list lvm-devel at redhat.com.

  ftp://sources.redhat.com/pub/lvm2/WHATS_NEW
  ftp://sources.redhat.com/pub/lvm2/WHATS_NEW_DM

  ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.89.tgz
  ftp://sources.redhat.com/pub/lvm2/LVM2.2.02.89.tgz.asc


Getting started
---------------

Ensure your kernel is at least version 3.2 and compiled with DM_THIN_PROVISIONING.

Add '--with-thin=internal' to your configure line.
You should have --enable-dmeventd too and install dmeventd for automatic extension of nearly-full thin volumes.

Fedora users may use this package:
  lvm2-2.02.89-2.fc17
  http://koji.fedoraproject.org/koji/buildinfo?buildID=295965
  (or a newer one, if we rebuild it)


The basic idea
--------------
You create a logical volume known as the "thin pool" to hold the disk space you want to use inside your volume group.

Then you create "thin" logical volumes which share the space in that pool.

lvs and lvdisplay will tell you "how full" your pool is.

dmeventd will monitor how full your pool is, and automatically use unallocated physical extents to extend it according to the policy in lvm.conf.  Do not allow your pool to fill up!

You can also take snapshots of thin volumes.

There are basic examples in the man pages, and sophisticated examples in the test scripts (e.g. test/shell/lvcreate-thin.sh).

With lvcreate, think of -L as controlling actual disk space and -V as controlling virtual size.  -T is a short-cut indicating the use of something thin.  If not specified, volume names (like lvol0) are generated whenever needed.

Creating a pool needs actual disk space, so use -L.
Creating a thin volume use virtual space, so use -V.

You can have more than one pool in a VG, so to use an existing one you must mention which it is on the command line.

(Of course, we will be producing additional documentation eventually.)

Commands that should mostly work with thin volumes at this stage:

  lvcreate, lvremove, lvresize, lvextend, lvreduce, lvchange, lvdisplay, lvs
  vgscan, vgdisplay, vgs, vgcreate, vgremove, vgextend, vgreduce

Please limit yourself to those commands for now.

Other commands have not been updated and may fail in surprising way.
(If one of them causes you problems, we're unlikely to be interested.)

In particular, be aware that vgcfgrestore only restores the LVM metadata and NOT the in-kernel thin metadata and so can easily cause crashes or corruption at the moment.

Alasdair

_______________________________________________
linux-lvm mailing list
linux-lvm at redhat.com
https://www.redhat.com/mailman/listinfo/linux-lvm
read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO/


