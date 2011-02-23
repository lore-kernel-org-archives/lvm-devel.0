From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Feb 2011 14:52:14 +0100
Subject: [PATCH 0/3] Share vg metadata for read only
Message-ID: <cover.1298466569.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Another nice speedup:

1st. patch refactors allocation of VG to one place - so refcounting
is simplier to implement (I'm planning few more cleanup patches for
this)

2nd. patch adds reference counting and caching of VG struct
As Milan suggested - I'll try to add extra code which will try to
check checksum of memory pool used for VG (with DEBUG_MEM option probably)


Some numbers with ~1700 volumes and current default rawhide kernel:
2.6.38-0.rc5.git1.1.fc15.x86_64
lvm2-2.02.84-1.fc15.x86_64
(killed gvfs...  and removed udisk udev rules 
 - as these are currently major performance killers)

vgchange -ay
  real	0m50.097s
  user	0m10.765s
  sys	0m35.481s

vgchange -ay       (here are LVs already actived)
  real	0m10.425s
  user	0m8.240s
  sys	0m2.133s

vgchange -an
  real	0m51.339s
  user	0m10.375s
  sys	0m31.457s

vgchange -an       (here are LVs already deactived)
  real	0m10.288s
  user	0m8.328s
  sys	0m1.901s

and now the same with new lvm2 sharing code (and critical section)

vgchange -ay
  real	0m13.792s  (udev is slowing it down by 3 seconds)
  user	0m0.629s
  sys	0m4.535s

vgchange -ay
  real	0m0.745s
  user	0m0.170s
  sys	0m0.520s

vgchange -an
  real	0m9.886s
  user	0m0.425s
  sys	0m2.418s

vgchange -an
  real	0m0.468s
  user	0m0.158s
  sys	0m0.239s


Zdenek Kabelac (3):
  Refactor vg allocation code
  Add VG refcount and cache created VG structure
  Destroy 'fic' memory in error path

 lib/cache/lvmcache.c          |   55 +++++++++++++++++++++++++++-------------
 lib/cache/lvmcache.h          |    4 ++-
 lib/format_text/import_vsn1.c |   33 +++++++-----------------
 lib/metadata/metadata.c       |   40 ++++++-----------------------
 lib/metadata/vg.c             |   26 +++++++++++++++++++
 lib/metadata/vg.h             |    3 ++
 6 files changed, 88 insertions(+), 73 deletions(-)

--
1.7.4.1


