From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 25 Jun 2010 12:00:30 +0100
Subject: undefined references in lvm2app
In-Reply-To: <201006241930.49495.benscott@nwlink.com>
References: <201006241930.49495.benscott@nwlink.com>
Message-ID: <20100625110030.GI14902@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jun 24, 2010 at 07:30:49PM -0700, ben scott wrote:
> volgroup.cpp:33: undefined reference to `lvm_vg_get_max_pv'
> volgroup.cpp:40: undefined reference to `lvm_vg_get_max_lv'
> volgroup.cpp:48: undefined reference to `lvm_vg_is_exported'

The liblvm/.exported_symbols file looks to be out-dated:
 
> lvm_list_vg_names
> lvm_list_vg_uuids
> lvm_lv_get_tags
< lvm_lv_resize
< lvm_pv_resize
< lvm_vg_get_max_lv
< lvm_vg_get_max_pv
> lvm_vg_get_tags
< lvm_vg_is_clustered
< lvm_vg_is_exported
< lvm_vg_is_partial
> lvm_vg_list_lvs
> lvm_vg_list_pvs

Alasdair


