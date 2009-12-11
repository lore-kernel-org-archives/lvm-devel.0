From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Dec 2009 17:13:00 +0100
Subject: [PATCH 0/3] Fix and cleanups
Message-ID: <cover.1260547761.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset fixed  'dmsetup info -c -o all'
Update one log error message
And makes lvm compilable with clang by using standard offsetof() macro.

Zdenek Kabelac (3):
  Fix reporting  dmsetup info -c -o all
  Report unrecognised key instead of field
  Use standard C macro offsetof()

 lib/report/report.c  |   25 ++++++++++++-------------
 libdm/libdm-report.c |    6 ++++--
 2 files changed, 16 insertions(+), 15 deletions(-)


