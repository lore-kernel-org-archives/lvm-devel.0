From: Mike Snitzer <snitzer@redhat.com>
Date: Tue, 22 Dec 2009 18:14:38 -0500
Subject: latest LVM2 snapshot-merge patches in quilt tree
Message-ID: <20091222231438.GA24696@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair,

I decided to leave the LVM2 patches in the quilt tree I've been
maintaining rather than post them all to lvm-devel.

The main reason for this is that the first 10 patches aren't _really_
pure snapshot-merge changes.  But the series builds on them.  Anyway I
figured you could pull the patches out of my quilt tree just fine.

The quilt tree is available here:
http://people.redhat.com/msnitzer/patches/snapshot-merge/lvm2/LVM2-2.02.57/

lvm-background-poll-flag.patch still has a TODO in the patch header; but
I never got any feedback on this RFC patch.

If you'd rather I post the patches to lvm-devel just let me know.


