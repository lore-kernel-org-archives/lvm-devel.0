From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Wed, 23 Jan 2013 12:55:06 +0530
Subject: [RFC/PATCH 0/2] lvm2app: Adding lv creation support
Message-ID: <1358925908-32347-1-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Hello,

We added Block Device(BD) backend capability to GlusterFS last year. BD
backend takes volume group as the input for GlusterFS volume and exports
all logical volumes under it as regular files to the GlusterFS client.
Now we are planning to export thin LVs as also regular files through
GlusterFS. In order to support thin LVs, we need thin lv creation
support in the lvm-devel.

I am posting RFC patches for adding various lv target creation
support and thin(pool) lv creation support in lvm library.

First approach (Add thin and thin pool lv creation) adds two interfaces
lvm_lv_thinpool and lvm_lv_thin (similar to lvm_vg_create_lv_linear())
to create thin-pool LV and thin LV respectively.

Second approach (Add LV creation support) adds interface
lvm_vg_create_lv() that can be used to create LV of any target type
(stripe, mirror, raid, thin etc). As part of this interface a new
structure lv_params_t is addded which is similar to lvcreate_params
exposing all parameters (such as chunk size, stripe size etc) to the end
user. Advantage with this approach is that it gives the user to control
properties of new LVs such as if the minor number of new lv should be
persistent, allocation policy, permission mode, stripe size etc. But
problem with this approach is that lots of code (parameter parsing,
setting default value for LV properties etc) from tools is duplicated
and it needs to be made as a library so that both tools and lvm-devel
can consume them.

In the long run, lvm-devel may need to provide finer control to the user
when creating LVs. In that case second approach is more suitable.

M. Mohan Kumar (2):
  lvm2app: Add thin and thin pool lv creation
  lvm2app: Add LV creation support

 liblvm/lvm2app.h | 102 +++++++
 liblvm/lvm_lv.c  | 835 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 937 insertions(+)

-- 
1.7.11.7


