From: Oliver Rath <rath@mglug.de>
Date: Thu, 07 Aug 2014 21:40:19 +0200
Subject: vgrename omit renaming hidden volumes if vg is inactive -> thinpools will be inconsistent
Message-ID: <53E3D623.7040606@mglug.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi list,

ive probably found a bug in lvm2 (testet on commit hash
6320c3b9052004397faf1687198756ac7914fecc):

if i rename an inactive vg (vgchange -an vg), then the hidden volumes
like /dev/mapper/vg-mypool_tdata ..tmeta ..tpool arent renamed in
/dev/mapper/..

If this is fixed in 2.02.109, Im sorry, wasnt able to test this at the
moment.

Regards
Oliver


