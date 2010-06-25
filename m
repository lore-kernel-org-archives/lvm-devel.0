From: ben scott <benscott@nwlink.com>
Date: Thu, 24 Jun 2010 19:30:49 -0700
Subject: undefined references in lvm2app
Message-ID: <201006241930.49495.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have run into an odd problem with lvm2app (cvs).

During linking I get:
volgroup.cpp:33: undefined reference to `lvm_vg_get_max_pv'
volgroup.cpp:40: undefined reference to `lvm_vg_get_max_lv'
volgroup.cpp:48: undefined reference to `lvm_vg_is_exported'
etc....

However some of the functions work fine, such as:
lvm_vg_get_extent_size(m_vg);
lvm_vg_get_extent_count(m_vg);

Any idea how this can happen? I have looked for old libraries BTW, everthing 
seems to be up to date.


