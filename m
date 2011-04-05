From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 05 Apr 2011 19:23:20 +0900
Subject: snapshot in shared disk environment
Message-ID: <4D9AED98.1080900@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Is it possible or is there on-going work to use snapshot in shared disk
environment?


In virtualization context, snapshotting is useful for quickly
creating a guest image from a template disk image.
(Fast creation and space efficiency with a cost of runtime performance)

LVM snapshot can be used for such a purpose, but there is a problem
if we are in shared disk environment:
  a) Clustered snapshot is not yet supported.
  b) Origin and snapshots are activated/deactivated as a whole set.
     We can't individually activate/deactivate different snapshots on
     different nodes.

a) might be ok.
A snapshot is accessed on a host at a time, not simultaneously on multiple
hosts. Also the origin is read-only.
So snapshot itself need not be cluster aware, I think.
If there are thousands of nodes sharing the disk, but only one of them
accesses the snapshot, clustered snapshot seems overkill.

I wonder whether we could relax the restriction in b) and allow individual
activation of snapshots.
Then, we can use snapshots in shared disk environment without clustered
snapshot support?

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation


