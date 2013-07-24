From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 24 Jul 2013 13:37:14 -0500
Subject: [PATCH] RFC: Filter LV list
Message-ID: <1374691035-9627-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added function lvm_vg_list_filtered_lvs which allows the
caller to specify all or just visible LVs to return.  Also
allows future filtering possiblities if needed.

This functionality is needed so that we don't expose
hidden LVs in targetd.

Tony Asleson (1):
  lvm2app: Add filtered LV list ability in library.

 liblvm/lvm2app.h | 28 ++++++++++++++++++++++++++++
 liblvm/lvm_vg.c  | 24 ++++++++++++++++++------
 python/liblvm.c  | 26 ++++++++++++++++++++++----
 3 files changed, 68 insertions(+), 10 deletions(-)

-- 
1.8.1.4


