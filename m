From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 29 May 2010 12:19:02 +0100
Subject: md_component_detection bug
In-Reply-To: <Pine.LNX.4.64.1005290111560.15553@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1005290111560.15553@hs20-bc2-1.build.redhat.com>
Message-ID: <20100529111902.GZ30283@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

1) The basic rule is you should run 'vgscan' after changing devices
underneath LVM.

2) The code tries to detect problems but doesn't find every case.
It's a trade-off between complete correctness scanning everything all
the time and speed.

For this new example where it doesn't do what you would expect,
write up a bugzilla (fedora rawhide) listing the sequence of commands
someone could run to demonstrate the problem.
Perhaps also show the contents of '.cache' in between the commands
that change it.

In particular, is .cache holding *both* /dev/md0 *and* /dev/sdc1 +
/dev/sdd1 even though md_component_detection is enabled?    If so,
that's what we should fix I think.

The device cache is very old code.

Alasdair


