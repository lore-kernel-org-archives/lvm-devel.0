From: Thuto Moji <thutomj@gmail.com>
Date: Fri, 27 Jan 2012 15:30:01 +0200
Subject: fsadm does not directly support ocfs2 - what to do for extending storage
Message-ID: <CADaWgck99T-n1R+5QUN6HvBZWFpCp2zL=DP54puDXH7-Hjxj3w@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

************FYI*********
Extending storage on SAN.
1. SAN Admin extend storage from SAN
2. pvresize /dev/sdx
3. lvresize -r -L +50G vg/lv
   *error: fsadm: Filesystem "ocfs2" on device " /dev/mapper/bla
4. tunefs.ocfs2 -S /dev/mapper/fs-siebel


Please edit accordingly
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20120127/43a2a5a4/attachment.htm>
