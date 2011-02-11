From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Feb 2011 11:08:46 +0100
Subject: [PATCH 0/2] PV_MIN_SIZE
Message-ID: <cover.1297418304.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Patch which adds parameter for minimal size of device to
be usable as PV.

Milan suggested other option to add new filter filter_pv_min_size
and keep the rest of the code as is. So pv_min_size() would be
used only in filter.c and pvresize & lib/metadata/metadata.c
would still use hardcoded define 512KB.

But IMHO this could lead to user confusion as user would be able
to create PV which is then invisible because of filter settings.
Looks to me more consistent to refuse any operation on such device.

But both ways are valid - we need decision which way to go.

Zdenek Kabelac (2):
  Add find_config_tree_int64 function
  Replace PV_MIN_SIZE with function pv_min_size()

 doc/example.conf.in              |    5 +++++
 lib/commands/toolcontext.c       |   11 ++++++++++-
 lib/config/config.c              |    6 ++++++
 lib/config/config.h              |    2 ++
 lib/filters/filter.c             |    2 +-
 lib/metadata/metadata-exported.h |    1 -
 lib/metadata/metadata.c          |    6 +++---
 lib/metadata/metadata.h          |    1 -
 lib/misc/lvm-globals.c           |   12 ++++++++++++
 lib/misc/lvm-globals.h           |    5 ++++-
 tools/pvresize.c                 |    6 +++---
 11 files changed, 46 insertions(+), 11 deletions(-)

--
1.7.4


