From: Christian Motschke <christian@motschke.de>
Date: Tue, 26 Apr 2011 11:18:06 +0200
Subject: clustered snapshots
Message-ID: <618B4C17-4670-4CDF-9476-7B4EF7A8675E@motschke.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I tried the unstable packages of lvm2 in debian with support for clustered snapshots (2.02.84) (I looked at the sources, the patch is included). It is unusable (at least for me ;-).
I have corosync and clvm with openais support running. Locking type is set to 3 in lvm.conf. I have only 1 server with clvm in this test setup. I hope this is not the problem.

What I did:
gcc:~# vgchange -cy vgtest
  Volume group "vgtest" successfully changed
gcc:~# vgdisplay -C
  VG     #PV #LV #SN Attr   VSize VFree
  vgtest   1   1   0 wz--nc 4.00g 3.00g
gcc:~# lvdisplay -C
  LV      VG     Attr   LSize Origin Snap%  Move Log Copy%  Convert
  test-lv vgtest -wi-a- 1.00g                                      
gcc:~# 

gcc:~# lvchange -aey vgtest/test-lv
gcc:~# lvcreate -s -n test-lv-snap -L 100m vgtest/test-lv
  Logical volume "test-lv-snap" created
gcc:~# lvdisplay -C
  LV           VG     Attr   LSize   Origin  Snap%  Move Log Copy%  Convert
  test-lv      vgtest owi-a-   1.00g                                       
  test-lv-snap vgtest swi-a- 100.00m test-lv 100.00                        

So, after I created the snapshot it is immediately disabled and 100% full. What am I doing wrong?

With kind regards.
Christian Motschke





